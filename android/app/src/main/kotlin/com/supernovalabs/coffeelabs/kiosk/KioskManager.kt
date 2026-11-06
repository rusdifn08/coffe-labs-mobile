package com.supernovalabs.coffeelabs.kiosk

import android.app.Activity
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.WindowManager
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import java.security.MessageDigest

class KioskManager(private val activity: Activity) {

    private val dpm: DevicePolicyManager by lazy {
        activity.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
    }

    private val adminComponent: ComponentName by lazy {
        ComponentName(activity, CoffeeLabsDeviceAdminReceiver::class.java)
    }

    private val homeAliasComponent: ComponentName by lazy {
        ComponentName(activity, "${activity.packageName}.kiosk.KioskHomeLauncherAlias")
    }

    fun isDeviceOwner(): Boolean {
        return try {
            dpm.isDeviceOwnerApp(activity.packageName)
        } catch (_: Exception) {
            false
        }
    }

    fun enableStrictKioskMode(pinSha256: String, storeId: String): Map<String, Any> {
        // 1. Simpan state ke Direct-Boot Protected Storage
        KioskDirectBootStore.setKioskLocked(activity, true, pinSha256, storeId)

        // 2. Aktifkan Dynamic Home Launcher Alias agar tombol Home mengarah ke Coffee Labs
        activity.packageManager.setComponentEnabledSetting(
            homeAliasComponent,
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP
        )

        // 3. Pasang Window Flags anti-lockscreen & layar menyala terus
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            activity.setShowWhenLocked(true)
            activity.setTurnScreenOn(true)
        }
        @Suppress("DEPRECATION")
        activity.window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
        )

        // 4. Sembunyikan Status Bar & Navigation Bar (Immersive Sticky)
        applyImmersiveStickyBars()

        // 5. Aktifkan LockTask (COSU Kernel Mode jika Device Owner, atau Screen Pinning)
        val isOwner = isDeviceOwner()
        if (isOwner) {
            try {
                dpm.setLockTaskPackages(adminComponent, arrayOf(activity.packageName))
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    // Mematikan Home, Recents, Notifications, Status Bar, System Info & Global Actions
                    dpm.setLockTaskFeatures(adminComponent, DevicePolicyManager.LOCK_TASK_FEATURE_NONE)
                }
            } catch (_: Exception) {}
        }

        try {
            activity.startLockTask()
        } catch (_: Exception) {
            // Fallback ditangani secara real-time oleh Sub-40ms FocusLossWatchdog
        }

        return mapOf(
            "locked" to true,
            "mode" to if (isOwner) "COSU_DEVICE_OWNER" else "HYBRID_LAUNCHER_WATCHDOG"
        )
    }

    fun disableStrictKioskMode() {
        KioskDirectBootStore.setKioskLocked(activity, false)

        // Matikan kembali Home Launcher Alias agar HP kembali ke launcher normal
        activity.packageManager.setComponentEnabledSetting(
            homeAliasComponent,
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
            PackageManager.DONT_KILL_APP
        )

        try {
            activity.stopLockTask()
        } catch (_: Exception) {}

        // Pulihkan System UI Bars
        val controller = WindowCompat.getInsetsController(activity.window, activity.window.decorView)
        controller.show(WindowInsetsCompat.Type.systemBars())
    }

    fun applyImmersiveStickyBars() {
        WindowCompat.setDecorFitsSystemWindows(activity.window, false)
        val controller = WindowCompat.getInsetsController(activity.window, activity.window.decorView)
        controller.hide(WindowInsetsCompat.Type.systemBars())
        controller.systemBarsBehavior =
            WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
    }

    fun hasOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(activity)
        } else {
            true
        }
    }

    fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(activity)) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:${activity.packageName}")
            ).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            activity.startActivity(intent)
        }
    }

    fun promptSelectHomeLauncher() {
        val intent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        activity.startActivity(Intent.createChooser(intent, "Pilih Default Home Launcher Coffee Labs"))
    }

    fun verifyPinOffline(inputPinSha256: String): Boolean {
        val storedHash = KioskDirectBootStore.getPinSha256(activity) ?: return false
        return MessageDigest.isEqual(
            storedHash.trim().lowercase().toByteArray(Charsets.UTF_8),
            inputPinSha256.trim().lowercase().toByteArray(Charsets.UTF_8)
        )
    }

    fun cacheMenuForDirectBoot(menuJson: String, configJson: String) {
        KioskDirectBootStore.cacheMenuForDirectBoot(activity, menuJson, configJson)
    }

    fun getCachedMenuJson(): String? {
        return KioskDirectBootStore.getCachedMenuJson(activity)
    }

    fun getCachedConfigJson(): String? {
        return KioskDirectBootStore.getCachedConfigJson(activity)
    }
}
