import Flutter
import UIKit

public class SwiftCloudpaymentsPlugin: NSObject, FlutterPlugin {
    

    var applicationController: UIViewController!
    
    var d3ds: D3DS?
    var delegate: MyDelegate?
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "cloudpayments", binaryMessenger: registrar.messenger())
        let instance = SwiftCloudpaymentsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        applicationController = application.windows.first?.rootViewController
        return true;
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
        case "show3ds":
            show3ds(call, result: result)
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
    
    public func show3ds(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        let params = call.arguments as! [String: Any]
        let acsUrl = params["acsUrl"] as? String
        let transactionId = params["transactionId"] as? String
        let paReq = params["paReq"] as? String
        
        d3ds = D3DS.init()
        delegate = MyDelegate()
        
        delegate?.closureAuthCompleted = { md, paRes in
            result(["md": md, "paRes": paRes])
            self.delegate = nil
            self.d3ds = nil
        }
        
        delegate?.closureAuthFailed = { html in
            result(FlutterError(code: "AuthorizationFailed", message: "authorizationFailed", details: nil))
            self.delegate = nil
            self.d3ds = nil
        }
       
        d3ds?.make3DSPayment(with: applicationController, andD3DSDelegate: delegate, andAcsURLString: acsUrl, andPaReqString: paReq, andTransactionIdString: transactionId)
        
    }
    
    
}

class MyDelegate: D3DSDelegate {
    
    var closureAuthCompleted: ((_ md: String, _ paRes: String) -> Void)?
    
    var closureAuthFailed: ((_ html: String) -> Void)?
    
    func authorizationCompleted(withMD md: String!, andPares paRes: String!) {
        closureAuthCompleted?(md, paRes)
    }
    
    func authorizationFailed(withHtml html: String!) {
        closureAuthFailed?(html)
    }
}
