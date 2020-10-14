import Flutter
import UIKit

public class SwiftCloudpaymentsPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "cloudpayments", binaryMessenger: registrar.messenger())
        let instance = SwiftCloudpaymentsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch  call.method {
        case "isValidNumber":
            let valid = isValidNumber(call)
            result(valid)
        case "isValidExpireDate":
            let valid = isValidExpireDate(call)
            result(valid)
        case "cardCryptogram":
            let argument = cardCryptogram(call)
            result(argument)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func isValidNumber(_ call: FlutterMethodCall) -> Bool {
        let params = call.arguments as! [String: Any]
        let cardNumber = params["cardNumber"] as? String
        return Card.isCardNumberValid(cardNumber)
    }
    
    public func isValidExpireDate(_ call: FlutterMethodCall) -> Bool {
        let params = call.arguments as! [String: Any]
        let expireDate = params["expireDate"] as? String
        return Card.isExpDateValid(expireDate)
    }
    
    public func cardCryptogram(_ call: FlutterMethodCall) -> [String: Any?] {
        let params = call.arguments as! [String: Any]
        let cardNumber = params["cardNumber"] as? String
        let cardDate = params["cardDate"] as? String
        let cardCVC = params["cardCVC"] as? String
        let publicId = params["publicId"] as? String
        
        let card = Card();
        let cardCryptogram = card.makeCryptogramPacket(cardNumber, andExpDate: cardDate, andCVV: cardCVC, andMerchantPublicID: publicId)
        
        
        let arguments: [String: Any?] = [
          "cryptogram": cardCryptogram,
          "error": nil,
        ]
        return arguments
    }
}

/*
 "isValidExpireDate" -> {
                 val valid = isValidExpireDate(call)
                 result.success(valid)
             }
             "cardCryptogram" -> {
                 val argument = cardCryptogram(call)
                 result.success(argument)
             }
 */


/*
 private fun isValidExpireDate(call: MethodCall): Boolean {
         val params = call.arguments as Map<String, Any>
         val cardNumber = params["expireDate"] as String
         return CPCard.isValidExpDate(cardNumber)
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
 */
