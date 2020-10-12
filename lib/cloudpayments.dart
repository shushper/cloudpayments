import 'dart:async';

import 'package:cloudpayments/cryptogram.dart';
import 'package:flutter/services.dart';

class Cloudpayments {
  static const MethodChannel _channel = const MethodChannel('cloudpayments');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> isValidNumber(String cardNumber) async {
    final bool valid =
        await _channel.invokeMethod<bool>('isValidNumber', {'cardNumber': cardNumber});
    return valid;
  }

  static Future<bool> isValidExpireDate(String expireDate) async {
    final bool valid =
        await _channel.invokeMethod<bool>('isValidExpireDate', {'expireDate': expireDate});
    return valid;
  }

  static Future<Cryptogram> cardCryptogram(
    String cardNumber,
    String cardDate,
    String cardCVC,
    String publicId,
  ) async {
    final dynamic arguments =
        await _channel.invokeMethod<dynamic>('cardCryptogram', {
      'cardNumber': cardNumber,
      'cardDate': cardDate,
      'cardCVC': cardCVC,
      'publicId': publicId,
    });
    return Cryptogram(arguments['cryptogram'], arguments['error']);
  }
}
