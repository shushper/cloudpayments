import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CloudpaymentsApplePay {
  static const MethodChannel _channel = const MethodChannel('cloudpayments');

  Future<bool> isApplePayAvailable() async {
    if (Platform.isIOS) {
      try {
        final bool available = await _channel.invokeMethod('isApplePayAvailable');
        return available;
      } on PlatformException catch (e) {
        print('${e.code}: ${e.message}');
        return false;
      }
    }
    return false;
  }

  Future<String> requestApplePayPayment({
    @required String merchantId,
    @required String currencyCode,
    @required String countryCode,
    @required List<Map<String,String>> products
  }) async {
    if (Platform.isIOS) {
      print('Invoke request payment method');
      final dynamic result = await _channel.invokeMethod<dynamic>('requestApplePayPayment', {
        'merchantId': merchantId,
        'currencyCode': currencyCode,
        'countryCode': countryCode,
        'products': products
      });
      print('Got result');
      return result;
    } else {
      throw Exception("Apple Pay is allowed only on Android");
    }
  }
}
