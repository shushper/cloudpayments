package com.shushper.cloudpayments.googlepay

import com.google.android.gms.wallet.WalletConstants

object GooglePayConstants {
    
    const val PAYMENT_GATEWAY_TOKENIZATION_NAME = "cloudpayments"

    
    val SUPPORTED_NETWORKS = listOf("MASTERCARD", "VISA")

    val SUPPORTED_METHODS = listOf("PAN_ONLY", "CRYPTOGRAM_3DS")

}