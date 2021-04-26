import Flutter
import UIKit

public class SwiftCloudpaymentsPlugin: NSObject, FlutterPlugin {
    

    var applicationController: UIViewController!
    
    var d3ds: D3DS?
    var delegate: MyDelegate?
    
    var lastPaymentResult: FlutterResult?
    let paymentNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard]
        
    
    
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
        case "isValidExpiryDate":
            let valid = isValidExpiryDate(call)
            result(valid)
        case "cardCryptogram":
            let argument = cardCryptogram(call)
            result(argument)
        case "show3ds":
            show3ds(call, result: result)
        case "isApplePayAvailable":
            checkIsApplePayAvailable(call, result: result)
        case "requestApplePayPayment":
            requestApplePayPayment(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func isValidNumber(_ call: FlutterMethodCall) -> Bool {
        let params = call.arguments as! [String: Any]
        let cardNumber = params["cardNumber"] as? String
        return Card.isCardNumberValid(cardNumber)
    }
    
    private func isValidExpiryDate(_ call: FlutterMethodCall) -> Bool {
        let params = call.arguments as! [String: Any]
        let expiryDate = params["expiryDate"] as? String
        return Card.isExpDateValid(expiryDate)
    }
    
    private func cardCryptogram(_ call: FlutterMethodCall) -> [String: Any?] {
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
    
    private func show3ds(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
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
    
    private func checkIsApplePayAvailable(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let isAvailable = PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks)
        result(isAvailable)
    }
    
    private func requestApplePayPayment(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let params = call.arguments as! [String: Any]
        let merchantId = params["merchantId"] as! String
        let currencyCode = params["currencyCode"] as! String
        let countryCode = params["countryCode"] as! String
        let products = params["products"] as! Array<[String: String]>
        
        // Получение информации о товарах выбранных пользователем
        var paymentItems: [PKPaymentSummaryItem] = []
        for product in products {
            let productName = product["name"]!
            let productPrice = product["price"]!
            let amountValue = Double(productPrice)
            let amount = NSDecimalNumber(value: amountValue!)
            let paymentItem = PKPaymentSummaryItem.init(label: productName, amount: amount)
            paymentItems.append(paymentItem)
        }
           
        // Формируем запрос для Apple Pay
        let request = PKPaymentRequest()
        request.merchantIdentifier = merchantId
        request.supportedNetworks = paymentNetworks
        request.merchantCapabilities = PKMerchantCapability.capability3DS // Возможно использование 3DS
        request.countryCode = countryCode
        request.currencyCode = currencyCode
        request.paymentSummaryItems = paymentItems
        
        lastPaymentResult = result
        
        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        applePayController?.delegate = self
        applicationController.present(applePayController!, animated: true, completion: nil)
    }
    
}

extension SwiftCloudpaymentsPlugin: PKPaymentAuthorizationViewControllerDelegate {
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping ((PKPaymentAuthorizationStatus) -> Void)) {
        completion(PKPaymentAuthorizationStatus.success)
        
        // Конвертируем объект PKPayment в строку криптограммы
        guard let cryptogram = PKPaymentConverter.convert(toString: payment) else {
            lastPaymentResult?.self(FlutterError(code: "PK_PAYMENT_CONVERT_ERROR", message: "Can't convert pk payment", details: nil))
            return
        }
        
        lastPaymentResult?.self(cryptogram)
    }
    
    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
        lastPaymentResult?.self(FlutterError(code: "CANCELED", message: "Payment canceled", details: nil))
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
