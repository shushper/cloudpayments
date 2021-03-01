package com.shushper.cloudpayments.googlepay

import android.app.Activity
import com.google.android.gms.common.internal.Constants
import com.google.android.gms.wallet.PaymentDataRequest
import com.google.android.gms.wallet.PaymentsClient
import com.google.android.gms.wallet.Wallet
import com.google.android.gms.wallet.Wallet.WalletOptions
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject


object GooglePayUtil {

    private val baseRequest = JSONObject().apply {
        put("apiVersion", 2)
        put("apiVersionMinor", 0)
    }


    private val allowedCardNetworks = JSONArray(GooglePayConstants.SUPPORTED_NETWORKS)

    private val allowedCardAuthMethods = JSONArray(GooglePayConstants.SUPPORTED_METHODS)

    private fun baseCardPaymentMethod(): JSONObject {
        return JSONObject().apply {

            val parameters = JSONObject().apply {
                put("allowedAuthMethods", allowedCardAuthMethods)
                put("allowedCardNetworks", allowedCardNetworks)
                put("billingAddressRequired", true)
                put("billingAddressParameters", JSONObject().apply {
                    put("format", "FULL")
                })
            }

            put("type", "CARD")
            put("parameters", parameters)
        }
    }

    private fun cardPaymentMethod(gatewayMerchantId: String): JSONObject {
        val cardPaymentMethod = baseCardPaymentMethod()

        val tokenizationSpecification = JSONObject().apply {
            put("type", "PAYMENT_GATEWAY")
            put("parameters", JSONObject().apply {
                put("gateway", GooglePayConstants.PAYMENT_GATEWAY_TOKENIZATION_NAME)
                put("gatewayMerchantId", gatewayMerchantId)
            })
        }

        cardPaymentMethod.put("tokenizationSpecification", tokenizationSpecification)

        return cardPaymentMethod
    }


    fun isReadyToPayRequest(): JSONObject? {
        return try {
            baseRequest.apply {
                put("allowedPaymentMethods", JSONArray().put(baseCardPaymentMethod()))
            }

        } catch (e: JSONException) {
            null
        }
    }


    fun createPaymentsClient(activity: Activity, environment: Int): PaymentsClient {
        val walletOptions = Wallet.WalletOptions.Builder()
                .setEnvironment(environment)
                .build()

        return Wallet.getPaymentsClient(activity, walletOptions)
    }

    private fun getTransactionInfo(price: String, currencyCode: String, countryCode: String): JSONObject {
        return JSONObject().apply {
            put("totalPrice", price)
            put("totalPriceStatus", "FINAL")
            put("countryCode", countryCode)
            put("currencyCode", currencyCode)
        }
    }

    fun getPaymentDataRequest(price: String, currencyCode: String, countryCode: String, merchantName: String, gatewayMerchantId: String): JSONObject? {
        return try {
            baseRequest.apply {
                put("allowedPaymentMethods", JSONArray().put(cardPaymentMethod(gatewayMerchantId)))
                put("transactionInfo", getTransactionInfo(price, currencyCode, countryCode))
                put("merchantInfo", JSONObject().apply {
                    put("merchantName", merchantName)
                })
                put("shippingAddressRequired", false)
                put("emailRequired", true)
            }
        } catch (e: JSONException) {
            null
        }
    }

}