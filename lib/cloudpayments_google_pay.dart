import 'dart:io';

import 'package:cloudpayments/google_pay_response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum GooglePayEnvironment { test, production }

class CloudpaymentsGooglePay {
  static const MethodChannel _channel = const MethodChannel('cloudpayments');

  CloudpaymentsGooglePay(GooglePayEnvironment environment) {
    _initGooglePay(describeEnum(environment));
  }

  void _initGooglePay(String environment) async {
    print('Init google pay');
    await _channel.invokeMethod('createPaymentsClient', {
      'environment': environment,
    });
  }

  Future<bool> isGooglePayAvailable() async {
    if (Platform.isAndroid) {
      try {
        final bool available = await _channel.invokeMethod('isGooglePayAvailable');
        return available;
      } on PlatformException catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<GooglePayResponse> requestGooglePayPayment({
    @required String price,
    @required String currencyCode,
    @required String countryCode,
    @required String merchantName,
    @required String publicId,
  }) async {
    if (Platform.isAndroid) {
      try {
        final dynamic result = await _channel.invokeMethod<dynamic>('requestGooglePayPayment', {
          'price': price,
          'currencyCode': currencyCode,
          'countryCode': countryCode,
          'merchantName': merchantName,
          'publicId': publicId,
        });
        return GooglePayResponse.fromMap(result);
      } on PlatformException catch (e) {
        return null;
      } catch (e) {
        return null;
      }
    } else {
      throw Exception("Google Pay is allowed only on Android");
    }
  }
}
