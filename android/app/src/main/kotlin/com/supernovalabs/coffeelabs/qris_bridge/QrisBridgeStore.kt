package com.supernovalabs.coffeelabs.qris_bridge

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

object QrisBridgeStore {
    private const val PREF_NAME = "coffeelabs_qris_bridge_prefs"
    private const val KEY_ENABLED = "bridge_enabled"
    private const val KEY_SECRET = "bridge_hmac_secret"
    private const val KEY_BASE_URL = "bridge_api_base_url"
    private const val KEY_LOGS = "bridge_recent_logs"
    private const val DEFAULT_BASE_URL = "https://coffe-labs-backend.onrender.com"
    private const val MAX_LOGS = 25

    private fun prefs(context: Context) =
        context.applicationContext.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)

    fun isEnabled(context: Context): Boolean = prefs(context).getBoolean(KEY_ENABLED, false)

    fun getSecret(context: Context): String = prefs(context).getString(KEY_SECRET, "") ?: ""

    fun getBaseUrl(context: Context): String {
        val raw = prefs(context).getString(KEY_BASE_URL, DEFAULT_BASE_URL)?.trim()
        return if (raw.isNullOrEmpty()) DEFAULT_BASE_URL else raw.trimEnd('/')
    }

    fun configure(context: Context, enabled: Boolean, secret: String?, apiBaseUrl: String?) {
        val editor = prefs(context).edit()
        editor.putBoolean(KEY_ENABLED, enabled)
        if (secret != null && secret.isNotBlank()) {
            editor.putString(KEY_SECRET, secret.trim())
        }
        if (apiBaseUrl != null && apiBaseUrl.isNotBlank()) {
            editor.putString(KEY_BASE_URL, apiBaseUrl.trim().trimEnd('/'))
        }
        editor.apply()
    }

    @Synchronized
    fun appendLog(
        context: Context,
        amountIdr: Long,
        status: String,
        httpCode: Int,
        snippet: String,
    ) {
        val p = prefs(context)
        val existing = try {
            JSONArray(p.getString(KEY_LOGS, "[]") ?: "[]")
        } catch (_: Exception) {
            JSONArray()
        }
        val entry = JSONObject().apply {
            put("timestamp_ms", System.currentTimeMillis())
            put("amount_idr", amountIdr)
            put("status", status)
            put("http_code", httpCode)
            put("snippet", snippet.take(160))
        }
        val updated = JSONArray()
        updated.put(entry)
        val limit = minOf(existing.length(), MAX_LOGS - 1)
        for (i in 0 until limit) {
            updated.put(existing.get(i))
        }
        p.edit().putString(KEY_LOGS, updated.toString()).apply()
    }

    fun getLogsJson(context: Context): String =
        prefs(context).getString(KEY_LOGS, "[]") ?: "[]"

    fun clearLogs(context: Context) {
        prefs(context).edit().putString(KEY_LOGS, "[]").apply()
    }
}
