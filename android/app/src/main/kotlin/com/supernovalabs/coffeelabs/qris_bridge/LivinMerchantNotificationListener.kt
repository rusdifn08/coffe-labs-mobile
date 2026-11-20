package com.supernovalabs.coffeelabs.qris_bridge

import android.app.Notification
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import org.json.JSONObject
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.Executors
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec

/**
 * Channel A (Primary — < 2s latency): Android Notification Bridge khusus HP Merchant/Admin.
 * Menyaring STRICT `id.bmri.livinmerchant` (Livin' Merchant Bank Mandiri), mengekstrak nominal
 * Rupiah eksak, menandatangani payload dengan HMAC-SHA256 + Timestamp + Nonce, dan mengirim
 * ke Rust Axum `/api/v1/billing/qris/bridge-ingest` dengan retry eksponensial.
 */
class LivinMerchantNotificationListener : NotificationListenerService() {

    companion object {
        const val LIVIN_MERCHANT_PACKAGE = "id.bmri.livinmerchant"
        private val RUPIAH_REGEX = Regex("""(?i)(?:Rp\.?|IDR)\s*([0-9][0-9\.,]{0,18})""")
        private val RRN_REGEX = Regex("""(?i)(?:RRN|Ref|Referensi)[:#\s]*([A-Z0-9\-]{6,32})""")
        private val executor = Executors.newSingleThreadExecutor()
        private val recentDedup = ConcurrentHashMap<String, Long>()

        fun isNotificationAccessEnabled(context: Context): Boolean {
            val enabledListeners = Settings.Secure.getString(
                context.contentResolver,
                "enabled_notification_listeners",
            ) ?: return false
            val target = ComponentName(context, LivinMerchantNotificationListener::class.java)
            return enabledListeners.split(":").any { raw ->
                val cn = ComponentName.unflattenFromString(raw)
                cn != null && cn.packageName == target.packageName && cn.className == target.className
            }
        }

        fun openNotificationAccessSettings(context: Context) {
            val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
        }

        fun parseRupiahAmount(text: String): Long? {
            val match = RUPIAH_REGEX.find(text) ?: return null
            val raw = match.groupValues.getOrNull(1)?.trim() ?: return null
            val whole = when {
                raw.endsWith(",00") -> raw.dropLast(3)
                raw.endsWith(".00") -> raw.dropLast(3)
                raw.contains(",") && raw.substringAfterLast(",").length <= 2 ->
                    raw.substringBeforeLast(",")
                else -> raw
            }
            val digits = whole.filter { it.isDigit() }
            return digits.toLongOrNull()?.takeIf { it > 0L }
        }

        fun computeHmacSha256Hex(secret: String, message: String): String {
            val mac = Mac.getInstance("HmacSHA256")
            mac.init(SecretKeySpec(secret.toByteArray(Charsets.UTF_8), "HmacSHA256"))
            val bytes = mac.doFinal(message.toByteArray(Charsets.UTF_8))
            return bytes.joinToString("") { "%02x".format(it) }
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        if (sbn == null) return
        if (sbn.packageName != LIVIN_MERCHANT_PACKAGE) return
        if (!QrisBridgeStore.isEnabled(applicationContext)) return

        val secret = QrisBridgeStore.getSecret(applicationContext)
        if (secret.isBlank()) return

        val extras = sbn.notification?.extras ?: return
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString()?.trim().orEmpty()
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()?.trim().orEmpty()
        val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString()?.trim().orEmpty()
        val bodyText = if (bigText.length >= text.length && bigText.isNotEmpty()) bigText else text
        val combined = listOf(title, bodyText).filter { it.isNotEmpty() }.joinToString(" — ")
        if (combined.isBlank()) return

        val amountIdr = parseRupiahAmount(combined) ?: return
        val dedupKey = "${sbn.key}:$amountIdr"
        val nowMs = System.currentTimeMillis()
        val prevMs = recentDedup[dedupKey]
        if (prevMs != null && (nowMs - prevMs) < 12_000L) {
            return
        }
        recentDedup[dedupKey] = nowMs
        if (recentDedup.size > 100) {
            recentDedup.entries.removeIf { (nowMs - it.value) > 60_000L }
        }

        val rrn = RRN_REGEX.find(combined)?.groupValues?.getOrNull(1)
        val payloadJson = JSONObject().apply {
            put("package_name", LIVIN_MERCHANT_PACKAGE)
            put("title", title)
            put("raw_notification_text", bodyText)
            put("amount_idr", amountIdr)
            if (!rrn.isNullOrBlank()) put("bank_rrn_ref", rrn)
            put("received_at_ms", sbn.postTime.takeIf { it > 0L } ?: nowMs)
        }.toString()

        val baseUrl = QrisBridgeStore.getBaseUrl(applicationContext)
        val ctx = applicationContext
        executor.execute {
            postWithBackoff(ctx, baseUrl, secret, payloadJson, amountIdr, combined)
        }
    }

    private fun postWithBackoff(
        context: Context,
        baseUrl: String,
        secret: String,
        jsonBody: String,
        amountIdr: Long,
        snippet: String,
    ) {
        val backoffMs = longArrayOf(0L, 2_500L, 6_000L)
        var lastCode = 0
        for (attempt in backoffMs.indices) {
            if (backoffMs[attempt] > 0L) {
                try {
                    Thread.sleep(backoffMs[attempt])
                } catch (_: InterruptedException) {
                    return
                }
            }
            try {
                val tsMs = System.currentTimeMillis()
                val nonce = UUID.randomUUID().toString()
                val signature = computeHmacSha256Hex(secret, "$tsMs.$nonce.$jsonBody")

                val conn = (URL("$baseUrl/api/v1/billing/qris/bridge-ingest").openConnection() as HttpURLConnection).apply {
                    requestMethod = "POST"
                    connectTimeout = 10_000
                    readTimeout = 12_000
                    doOutput = true
                    setRequestProperty("Content-Type", "application/json; charset=utf-8")
                    setRequestProperty("X-Bridge-Timestamp", tsMs.toString())
                    setRequestProperty("X-Bridge-Nonce", nonce)
                    setRequestProperty("X-Bridge-Signature", signature)
                }

                OutputStreamWriter(conn.outputStream, Charsets.UTF_8).use { it.write(jsonBody) }
                lastCode = conn.responseCode
                conn.disconnect()

                if (lastCode in 200..299) {
                    QrisBridgeStore.appendLog(context, amountIdr, "FORWARDED_OK", lastCode, snippet)
                    return
                }
                if (lastCode in 400..499) {
                    QrisBridgeStore.appendLog(context, amountIdr, "REJECTED_4XX", lastCode, snippet)
                    return
                }
            } catch (_: Exception) {
                lastCode = -1
            }
        }
        QrisBridgeStore.appendLog(context, amountIdr, "RETRY_FAILED", lastCode, snippet)
    }
}
