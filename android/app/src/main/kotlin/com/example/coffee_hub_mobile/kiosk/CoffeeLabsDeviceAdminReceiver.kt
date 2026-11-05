package com.example.coffee_hub_mobile.kiosk

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class CoffeeLabsDeviceAdminReceiver : DeviceAdminReceiver() {
    companion object {
        private const val TAG = "CoffeeLabsDeviceAdmin"
    }

    override fun onEnabled(context: Context, intent: Intent) {
        super.onEnabled(context, intent)
        Log.i(TAG, "🛡️ Coffee Labs Device Admin Enabled successfully.")
    }

    override fun onDisableRequested(context: Context, intent: Intent): CharSequence {
        return "Peringatan: Menonaktifkan Device Admin akan membuka kunci Kiosk Mode Coffee Labs."
    }

    override fun onDisabled(context: Context, intent: Intent) {
        super.onDisabled(context, intent)
        Log.w(TAG, "⚠️ Coffee Labs Device Admin Disabled.")
    }

    override fun onLockTaskModeEntering(context: Context, intent: Intent, pkg: String) {
        super.onLockTaskModeEntering(context, intent, pkg)
        Log.i(TAG, "🔒 Lock Task Mode (COSU Kiosk) entered for package: $pkg")
    }

    override fun onLockTaskModeExiting(context: Context, intent: Intent) {
        super.onLockTaskModeExiting(context, intent)
        Log.i(TAG, "🔓 Lock Task Mode exited.")
    }
}
