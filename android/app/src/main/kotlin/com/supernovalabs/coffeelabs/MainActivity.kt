package com.supernovalabs.coffeelabs

import android.content.Intent
import android.view.KeyEvent
import com.supernovalabs.coffeelabs.kiosk.KioskDirectBootStore
import com.supernovalabs.coffeelabs.kiosk.KioskManager
import com.supernovalabs.coffeelabs.qris_bridge.QrisBridgeStore
import com.supernovalabs.coffeelabs.qris_bridge.QrisNotificationGatewayProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // Channel "apk_installer" DIHAPUS PERMANEN.
    // Alasannya: aplikasi yang bisa memicu instalasi APK lain
    // (REQUEST_INSTALL_PACKAGES + ACTION_VIEW package-archive) adalah signature
    // dropper di classifier Play Protect. Channel itu juga tidak pernah dipanggil
    // dari sisi Dart — 100% dead code. Update aplikasi sekarang lewat browser
    // (download manual) atau Play In-App Updates, bukan self-install.
    private val KIOSK_CHANNEL = "com.coffeelabs.app/kiosk_engine"
    private val QRIS_BRIDGE_CHANNEL = "com.coffeelabs.app/qris_bridge"

    private lateinit var kioskManager: KioskManager
    private var kioskMethodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        kioskManager = KioskManager(this)

        // 1. Channel Strict Kiosk Engine & Direct-Boot
        val kChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, KIOSK_CHANNEL)
        kioskMethodChannel = kChannel
        kChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getKioskBootState" -> {
                    val isLocked = KioskDirectBootStore.isKioskLocked(this)
                    val bootIntoAod = intent?.getBooleanExtra("boot_into_aod_kiosk", false) ?: false
                    result.success(
                        mapOf(
                            "isLocked" to isLocked,
                            "bootIntoAod" to (isLocked && bootIntoAod),
                            "cachedMenu" to kioskManager.getCachedMenuJson(),
                            "cachedConfig" to kioskManager.getCachedConfigJson(),
                            "isDeviceOwner" to kioskManager.isDeviceOwner(),
                            "hasOverlayPermission" to kioskManager.hasOverlayPermission()
                        )
                    )
                }
                "enableStrictKiosk" -> {
                    val pinSha256 = call.argument<String>("pinSha256") ?: ""
                    val storeId = call.argument<String>("storeId") ?: ""
                    try {
                        val res = kioskManager.enableStrictKioskMode(pinSha256, storeId)
                        result.success(res)
                    } catch (e: Exception) {
                        result.error("KIOSK_ENABLE_ERROR", e.localizedMessage, null)
                    }
                }
                "disableStrictKiosk" -> {
                    try {
                        kioskManager.disableStrictKioskMode()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("KIOSK_DISABLE_ERROR", e.localizedMessage, null)
                    }
                }
                "hasOverlayPermission" -> {
                    result.success(kioskManager.hasOverlayPermission())
                }
                "requestOverlayPermission" -> {
                    try {
                        kioskManager.requestOverlayPermission()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("OVERLAY_ERROR", e.localizedMessage, null)
                    }
                }
                "promptSelectHomeLauncher" -> {
                    try {
                        kioskManager.promptSelectHomeLauncher()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("HOME_SELECTOR_ERROR", e.localizedMessage, null)
                    }
                }
                "cacheMenuForDirectBoot" -> {
                    val menuJson = call.argument<String>("menuJson") ?: "[]"
                    val configJson = call.argument<String>("configJson") ?: "{}"
                    kioskManager.cacheMenuForDirectBoot(menuJson, configJson)
                    result.success(true)
                }
                "verifyPinOffline" -> {
                    val pinSha256 = call.argument<String>("pinSha256") ?: ""
                    result.success(kioskManager.verifyPinOffline(pinSha256))
                }
                "applyImmersiveStickyBars" -> {
                    kioskManager.applyImmersiveStickyBars()
                    result.success(true)
                }
                "isDeviceOwner" -> {
                    result.success(kioskManager.isDeviceOwner())
                }
                else -> result.notImplemented()
            }
        }

        // 3. Channel Zero-Gateway Livin' Merchant QRIS Notification Bridge (Admin/Owner Only)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, QRIS_BRIDGE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBridgeStatus" -> {
                    result.success(
                        mapOf(
                            "enabled" to QrisBridgeStore.isEnabled(this),
                            "hasNotificationAccess" to QrisNotificationGatewayProvider.get().isNotificationAccessEnabled(this),
                            "apiBaseUrl" to QrisBridgeStore.getBaseUrl(this),
                            "hasSecret" to QrisBridgeStore.getSecret(this).isNotBlank(),
                            "recentLogsJson" to QrisBridgeStore.getLogsJson(this),
                        )
                    )
                }
                "configureBridge" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    val secret = call.argument<String>("bridgeSecret")
                    val apiBaseUrl = call.argument<String>("apiBaseUrl")
                    QrisBridgeStore.configure(this, enabled, secret, apiBaseUrl)
                    result.success(true)
                }
                "openNotificationAccessSettings" -> {
                    try {
                        QrisNotificationGatewayProvider.get().openNotificationAccessSettings(this)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("NOTIF_SETTINGS_ERROR", e.localizedMessage, null)
                    }
                }
                "clearLogs" -> {
                    QrisBridgeStore.clearLogs(this)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        if (::kioskManager.isInitialized && KioskDirectBootStore.isKioskLocked(this)) {
            kioskManager.applyImmersiveStickyBars()
        }
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        // Sub-40ms Focus-Loss Watchdog:
        // Jika notifikasi ditarik ke bawah atau user mencoba membuka Recent Apps,
        // seketika re-hide System UI Bars dan bawa kembali MainActivity ke depan!
        if (!hasFocus && ::kioskManager.isInitialized && KioskDirectBootStore.isKioskLocked(this)) {
            kioskManager.applyImmersiveStickyBars()
            val bringToFront = Intent(this, MainActivity::class.java).apply {
                addFlags(
                    Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_NO_ANIMATION
                )
            }
            startActivity(bringToFront)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (intent.getBooleanExtra("boot_into_aod_kiosk", false)) {
            kioskMethodChannel?.invokeMethod("onDirectBootTriggered", null)
        }
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (::kioskManager.isInitialized && KioskDirectBootStore.isKioskLocked(this)) {
            when (keyCode) {
                KeyEvent.KEYCODE_VOLUME_UP,
                KeyEvent.KEYCODE_VOLUME_DOWN,
                KeyEvent.KEYCODE_VOLUME_MUTE,
                KeyEvent.KEYCODE_HOME,
                KeyEvent.KEYCODE_APP_SWITCH -> {
                    return true // Redam tombol fisik saat Kiosk Lock aktif
                }
            }
        }
        return super.onKeyDown(keyCode, event)
    }
}
