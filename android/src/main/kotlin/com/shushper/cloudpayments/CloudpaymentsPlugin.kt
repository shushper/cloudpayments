package com.shushper.cloudpayments

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import ru.cloudpayments.sdk.cp_card.CPCard
import java.io.UnsupportedEncodingException
import java.security.InvalidKeyException
import java.security.NoSuchAlgorithmException
import javax.crypto.BadPaddingException
import javax.crypto.IllegalBlockSizeException
import javax.crypto.NoSuchPaddingException

/** CloudpaymentsPlugin */
public class CloudpaymentsPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "cloudpayments")
        channel.setMethodCallHandler(this);
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "cloudpayments")
            channel.setMethodCallHandler(CloudpaymentsPlugin())
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "isValidNumber" -> {
                val valid = isValidNumber(call)
                result.success(valid)
            }
            "isValidExpireDate" -> {
                val valid = isValidExpireDate(call)
                result.success(valid)
            }
            "cardCryptogram" -> {
                val argument = cardCryptogram(call)
                result.success(argument)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun isValidNumber(call: MethodCall): Boolean {
        val params = call.arguments as Map<String, Any>
        val cardNumber = params["cardNumber"] as String
        return CPCard.isValidNumber(cardNumber)
    }

    private fun isValidExpireDate(call: MethodCall): Boolean {
        val params = call.arguments as Map<String, Any>
        val expireDate = params["expireDate"] as String
        return CPCard.isValidExpDate(expireDate)
    }

    private fun cardCryptogram(call: MethodCall): Map<String, Any?> {
        val params = call.arguments as Map<String, Any>
        val cardNumber = params["cardNumber"] as String
        val cardDate = params["cardDate"] as String
        val cardCVC = params["cardCVC"] as String
        val publicId = params["publicId"] as String

        val card = CPCard(cardNumber, cardDate, cardCVC)
        var cardCryptogram: String? = null
        var error: String? = null;

        try {
            cardCryptogram = card.cardCryptogram(publicId)
        } catch (e: UnsupportedEncodingException) {
            e.printStackTrace()
            error = "UnsupportedEncodingException"
        } catch (e: NoSuchPaddingException) {
            e.printStackTrace()
            error = "NoSuchPaddingException"
        } catch (e: NoSuchAlgorithmException) {
            e.printStackTrace()
            error = "NoSuchAlgorithmException"
        } catch (e: BadPaddingException) {
            e.printStackTrace()
            error = "BadPaddingException"
        } catch (e: IllegalBlockSizeException) {
            e.printStackTrace()
            error = "IllegalBlockSizeException"
        } catch (e: InvalidKeyException) {
            e.printStackTrace()
            error = "InvalidKeyException"
        } catch (e: StringIndexOutOfBoundsException) {
            e.printStackTrace()
            error = "StringIndexOutOfBoundsException"
        }

        return mapOf("cryptogram" to cardCryptogram, "error" to error)
    }
}
