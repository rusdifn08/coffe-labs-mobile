package com.supernovalabs.coffeelabs.qris_bridge

import android.content.Context

/**
 * Implementasi PRODUKTIF untuk build **merchant** (internal toko saja).
 *
 * Mendelegasikan ke [LivinMerchantNotificationListener] yang menyaring
 * paket `id.bmri.livinmerchant`, mengekstrak nominal Rupiah, dan mengirim
 * payload bertanda tangan HMAC-SHA256 ke backend.
 *
 * JANGAN pernah mendistribusikan build ini ke publik / Play Store.
 */
internal object QrisNotificationGatewayImpl : QrisNotificationGateway {

    override fun isNotificationAccessEnabled(context: Context): Boolean =
        LivinMerchantNotificationListener.isNotificationAccessEnabled(context)

    override fun openNotificationAccessSettings(context: Context) {
        LivinMerchantNotificationListener.openNotificationAccessSettings(context)
    }
}
