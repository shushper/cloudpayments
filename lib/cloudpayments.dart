import 'dart:async';
import 'dart:io';

import 'package:cloudpayments/cryptogram.dart';
import 'package:flutter/services.dart';

class Cloudpayments {
  static const MethodChannel _channel = const MethodChannel('cloudpayments');

  static Future<bool> isValidNumber(String cardNumber) async {
    final bool valid =
        await _channel.invokeMethod<bool>('isValidNumber', {'cardNumber': cardNumber});
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
