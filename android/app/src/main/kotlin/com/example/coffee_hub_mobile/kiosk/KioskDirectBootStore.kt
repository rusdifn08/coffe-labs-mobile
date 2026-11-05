package com.example.coffee_hub_mobile.kiosk

import android.content.Context
import android.content.SharedPreferences
import android.os.Build

object KioskDirectBootStore {
    private const val PREF_NAME = "coffee_labs_direct_boot_kiosk_prefs"
    private const val KEY_IS_LOCKED = "is_aod_kiosk_locked"
    private const val KEY_PIN_SHA256 = "cashier_pin_sha256"
    private const val KEY_STORE_ID = "locked_store_id"
    private const val KEY_CACHED_MENU = "cached_aod_menu_json"
    private const val KEY_CACHED_CONFIG = "cached_store_config_json"

    private fun getPrefs(context: Context): SharedPreferences {
        val storageContext = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            context.createDeviceProtectedStorageContext()
        } else {
            context
        }
        return storageContext.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
    }

    fun setKioskLocked(
        context: Context,
        isLocked: Boolean,
        pinSha256: String? = null,
        storeId: String? = null
    ) {
        val editor = getPrefs(context).edit().putBoolean(KEY_IS_LOCKED, isLocked)
        if (pinSha256 != null) editor.putString(KEY_PIN_SHA256, pinSha256)
        if (storeId != null) editor.putString(KEY_STORE_ID, storeId)
        editor.commit() // Synchronous commit agar tahan pemadaman listrik mendadak
    }

    fun isKioskLocked(context: Context): Boolean {
        return getPrefs(context).getBoolean(KEY_IS_LOCKED, false)
    }

    fun getPinSha256(context: Context): String? {
        return getPrefs(context).getString(KEY_PIN_SHA256, null)
    }

    fun getStoreId(context: Context): String? {
        return getPrefs(context).getString(KEY_STORE_ID, null)
    }

    fun cacheMenuForDirectBoot(context: Context, menuJson: String, configJson: String) {
        getPrefs(context).edit()
            .putString(KEY_CACHED_MENU, menuJson)
            .putString(KEY_CACHED_CONFIG, configJson)
            .commit()
    }

    fun getCachedMenuJson(context: Context): String? {
        return getPrefs(context).getString(KEY_CACHED_MENU, null)
    }

    fun getCachedConfigJson(context: Context): String? {
        return getPrefs(context).getString(KEY_CACHED_CONFIG, null)
    }
}
