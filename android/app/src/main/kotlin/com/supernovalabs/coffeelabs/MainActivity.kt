package com.supernovalabs.coffeelabs

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.KeyEvent
import androidx.core.content.FileProvider
import com.supernovalabs.coffeelabs.kiosk.KioskDirectBootStore
import com.supernovalabs.coffeelabs.kiosk.KioskManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val APK_CHANNEL = "com.coffeelabs.app/apk_installer"
    private val KIOSK_CHANNEL = "com.coffeelabs.app/kiosk_engine"

    private lateinit var kioskManager: KioskManager
    private var kioskMethodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        kioskManager = KioskManager(this)

        // 1. Channel APK Installer
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APK_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "canRequestPackageInstalls" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        result.success(packageManager.canRequestPackageInstalls())
                    } else {
                        result.success(true)
                    }
                }
                "openInstallPermissionSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        try {
                            val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES).apply {
                                data = Uri.parse("package:$packageName")
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("SETTINGS_ERROR", e.localizedMessage, null)
                        }
                    } else {
                        result.success(true)
                    }
                }
                "installApk" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath.isNullOrEmpty()) {
                        result.error("INVALID_PATH", "File path must not be null or empty", null)
                        return@setMethodCallHandler
                    }

                    val apkFile = File(filePath)
                    if (!apkFile.exists()) {
                        result.error("FILE_NOT_FOUND", "APK file does not exist at $filePath", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val apkUri: Uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            FileProvider.getUriForFile(
                                this,
                                "$packageName.fileProvider",
                                apkFile
                            )
                        } else {
                            Uri.fromFile(apkFile)
                        }

                        val intent = Intent(Intent.ACTION_VIEW).apply {
                            setDataAndType(apkUri, "application/vnd.android.package-archive")
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }

                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INSTALL_ERROR", e.localizedMessage, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // 2. Channel Strict Kiosk Engine & Direct-Boot
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
