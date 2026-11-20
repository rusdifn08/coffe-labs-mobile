package com.supernovalabs.coffeelabs.qris_bridge

import android.content.Context

/**
 * Kontrak akses notifikasi ke Livin' Merchant.
 *
 * Kenapa pakai interface + implementasi per-flavor, bukan langsung panggil
 * `LivinMerchantNotificationListener`:
 *
 *   - Build **store** (publik / Play Store) TIDAK boleh memuat class
 *     NotificationListenerService yang membaca notifikasi aplikasi bank.
 *     Cukup keberadaan class itu di dalam dex untuk menaikkan skor risiko
 *     classifier Google Play Protect sampai level "aplikasi diblokir".
 *   - Build **merchant** (internal toko) tetap dapat fungsi penuh.
 *
 * Implementasi `QrisNotificationGatewayImpl` disediakan per source set:
 *   src/store/kotlin/.../QrisNotificationGatewayImpl.kt    -> inert (no-op)
 *   src/merchant/kotlin/.../QrisNotificationGatewayImpl.kt -> Livin listener
 */
interface QrisNotificationGateway {

    /** True hanya jika user sudah memberi Notification Access ke service bridge. */
    fun isNotificationAccessEnabled(context: Context): Boolean

    /** Buka Settings > Notification access, atau tampilkan toast status di build store. */
    fun openNotificationAccessSettings(context: Context)
}

object QrisNotificationGatewayProvider {
    fun get(): QrisNotificationGateway = QrisNotificationGatewayImpl
}
