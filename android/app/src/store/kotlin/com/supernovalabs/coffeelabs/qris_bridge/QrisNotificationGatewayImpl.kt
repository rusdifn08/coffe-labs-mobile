package com.supernovalabs.coffeelabs.qris_bridge

import android.content.Context
import android.widget.Toast

/**
 * Implementasi INERT untuk build **store** (publik / Play Store).
 *
 * Build ini sengaja tidak memuat `LivinMerchantNotificationListener`.
 * Fitur auto-rekonsiliasi QRIS dari notifikasi bank tetap jalan lewat
 * Channel B server-side (webhook / input manual / bridge terpisah) —
 * bukan dengan membaca notifikasi aplikasi keuangan di perangkat user.
 *
 * Kenapa begini: NotificationListenerService yang menyaring paket bank adalah
 * signature banking-trojan di classifier Play Protect. Tidak ada flag runtime
 * yang bisa menyembunyikannya dari static analysis — satu-satunya cara lulus
 * adalah tidak mengompilasi class tersebut ke APK publik.
 */
internal object QrisNotificationGatewayImpl : QrisNotificationGateway {

    override fun isNotificationAccessEnabled(context: Context): Boolean = false

    override fun openNotificationAccessSettings(context: Context) {
        Toast.makeText(
            context,
            "Bridge QRIS hanya tersedia di build Coffee Labs Merchant.",
            Toast.LENGTH_LONG,
        ).show()
    }
}
