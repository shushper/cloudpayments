import 'dart:async';
import 'dart:io';

import 'package:cloudpayments/cryptogram.dart';
import 'package:cloudpayments/google_pay_response.dart';
import 'package:cloudpayments/three_ds_response.dart';
import 'package:flutter/services.dart';

class Cloudpayments {
  static const MethodChannel _channel = const MethodChannel('cloudpayments');

  static Future<bool> isValidNumber(String cardNumber) async {
    final bool valid = await _channel.invokeMethod<bool>('isValidNumber', {'cardNumber': cardNumber});
    return valid;
  }

  static Future<bool> isValidExpireDate(String expireDate) async {
    final date = _formatExpireDate(expireDate);
    final valid = await _channel.invokeMethod<bool>('isValidExpireDate', {'expireDate': date});
    return valid;
  }

  static Future<Cryptogram> cardCryptogram(
    String cardNumber,
    String cardDate,
    String cardCVC,
    String publicId,
  ) async {
    final date = _formatExpireDate(cardDate);
    final dynamic arguments = await _channel.invokeMethod<dynamic>('cardCryptogram', {
      'cardNumber': cardNumber,
      'cardDate': date,
      'cardCVC': cardCVC,
      'publicId': publicId,
    });
    return Cryptogram(arguments['cryptogram'], arguments['error']);
  }

  static Future<ThreeDsResponse> show3ds(String acsUrl, String transactionId, String paReq) async {
    try {
      final dynamic arguments = await _channel.invokeMethod<dynamic>('show3ds', {
        'acsUrl': acsUrl,
        'transactionId': transactionId,
        'paReq': paReq,
      });

      if (arguments == null) {
        return null;
      } else {
        return ThreeDsResponse(success: true, md: arguments['md'], paRes: arguments['paRes']);
      }
    } on PlatformException catch (e) {
      return ThreeDsResponse(success: false, error: e.message);
    }
  }

  static Future<bool> isGooglePayAvailable() async {
    if (Platform.isAndroid) {
      try {
        final bool available = await _channel.invokeMethod('isGooglePayAvailable');
        return available;
      } on PlatformException catch (e) {
        print('${e.code}: ${e.message}');
        return false;
      }
    }
    return false;
  }

  static Future<GooglePayResponse> requestGooglePayPayment(String price, String currencyCode, String countryCode, String merchantName, String publicId) async {
    if (Platform.isAndroid) {
      try {
        print('requestGooglePayPayment');
        final dynamic result = await _channel.invokeMethod<dynamic>('requestGooglePayPayment', {
          'price': price,
          'currencyCode': currencyCode,
          'countryCode': countryCode,
          'merchantName': merchantName,
          'publicId': publicId,
        });
        return GooglePayResponse.fromMap(result);
      } on PlatformException catch (e) {
        print('platform exception');
        print('${e.code}: ${e.message}');
        return null;
      } catch (e) {
        print('exception');
        print(e);
        return null;
      }
    } else {
      throw Exception("Google Pay is allowed only on Android");
    }
  }

  static String _formatExpireDate(String expireDate) {
    String date;
    if (Platform.isAndroid) {
      date = expireDate.replaceAll('/', '');
    } else if (Platform.isIOS) {
      date = expireDate;
    }
    return date;
  }
}
