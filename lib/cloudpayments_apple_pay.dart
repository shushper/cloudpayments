import 'dart:io';

import 'package:cloudpayments/apple_pay_response.dart';
import 'package:flutter/services.dart';

/// Contains helper methods that allow you to interact with Apple Pay.
class CloudpaymentsApplePay {
  static const MethodChannel _channel = const MethodChannel('cloudpayments');

  CloudpaymentsApplePay();

  /// Checks whether an Apple Pay is available on this device and can process payment requests using
  /// Cloudpayments payment network brands (Visa and Mastercard).
  Future<bool> isApplePayAvailable() async {
    if (Platform.isIOS) {
      try {
        final available = await _channel.invokeMethod('isApplePayAvailable');
        return available;
      } on PlatformException catch (_) {
        return false;
      }
    }
    return false;
  }

  /// Requests Apple Pay payment. Returns payment token that you can use for Cloudpayments payment by a cryptogram.
  ///
  /// [merchantId] - your Apple Pay merchant id. You have to create it in your [Apple Developer Account](https://developer.apple.com/) before.
  ///
  /// [currencyCode] - Currency code. For example 'RUB'.
  ///
  /// [countryCode] - Country code. For example 'RU'.
  ///
  /// [products] - List of products. It will be shown in Apple Pay window. Each product consists of a name and price.
  /// The price must use '.' decimal separator, not ','. Apple Pay uses the last item in the list
  /// as the grand total for the purchase.
  ///
  /// ```
  /// [
  ///   {"name": "Red apple", "price": "170"},
  ///   {"name": "Mango", "price": "250.50"},
  ///   {"name": "Delivery", "price": "100"},
  ///   {"name": "Discount", "price": "-89.90"},
  ///   {"name": "Total", "price": "430.60"},
  /// ]
  ///```
  ///
  /// Returns [ApplePayResponse]. You have to check whether response is success and if so, you can obtain
  /// payment token by [response.token]
  ///
  /// ```dart
  /// if (response.isSuccess) {
  ///   final token = response.token;
  ///   // use token for payment by a cryptogram
  /// } else if (response.isError) {
  ///   // show error
  ///} else if (response.isCanceled) {
  ///   // apple pay was canceled
  ///}
  /// ```
  Future<ApplePayResponse> requestApplePayPayment({
    required String merchantId,
    required String currencyCode,
    required String countryCode,
    required List<Map<String, String>> products,
  }) async {
    if (Platform.isIOS) {
      try {
        final dynamic result =
            await _channel.invokeMethod<dynamic>('requestApplePayPayment', {
          'merchantId': merchantId,
          'currencyCode': currencyCode,
          'countryCode': countryCode,
          'products': products,
        });

        return ApplePayResponse.fromResult(result);
      } on PlatformException catch (e) {
        return ApplePayResponse.fromPlatformException(e);
      } catch (e) {
        return ApplePayResponse.fromException();
      }
    } else {
      throw Exception("Apple Pay is allowed only on iOS");
    }
  }
}
