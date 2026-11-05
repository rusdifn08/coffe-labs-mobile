package com.example.coffee_hub_mobile.kiosk

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.example.coffee_hub_mobile.MainActivity

class BootCompletedReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "KioskBootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        Log.i(TAG, "📡 Received boot event: $action")

        if (action == Intent.ACTION_LOCKED_BOOT_COMPLETED ||
            action == Intent.ACTION_BOOT_COMPLETED ||
            action == "android.intent.action.QUICKBOOT_POWERON" ||
            action == "com.htc.intent.action.QUICKBOOT_POWERON"
        ) {
            // Baca langsung dari Direct-Boot Device Protected Storage (sebelum PIN/pola HP dibuka)
            if (KioskDirectBootStore.isKioskLocked(context)) {
                Log.i(TAG, "⚡ Direct-Boot: AOD Kiosk is active! Launching Coffee Labs MainActivity...")
                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    addFlags(
                        Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP or
                        Intent.FLAG_ACTIVITY_NO_ANIMATION
                    )
                    putExtra("boot_into_aod_kiosk", true)
                }
                context.startActivity(launchIntent)
            } else {
                Log.d(TAG, "Normal boot: AOD Kiosk mode is not locked.")
            }
        }
    }
}
