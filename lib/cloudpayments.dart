import 'dart:async';
import 'dart:io';

import 'package:cloudpayments/cryptogram.dart';
import 'package:cloudpayments/three_ds_response.dart';
import 'package:flutter/services.dart';

/// Contains helpful methods that allow you to check payment card parameters validity and create a card cryptogram.
class Cloudpayments {
  static const MethodChannel _channel = const MethodChannel('cloudpayments');

  /// Checks if the given [cardNumber] is valid.
  static Future<bool> isValidNumber(String cardNumber) async {
    final valid = await _channel
        .invokeMethod<bool>('isValidNumber', {'cardNumber': cardNumber});
    return valid!;
  }

  /// Checks if the given card [expiryDate] is valid and not expired.
  ///
  /// [expiryDate] must be in the format 'MM/YY'
  static Future<bool> isValidExpiryDate(String expiryDate) async {
    final date = _formatExpiryDate(expiryDate);
    final valid = await _channel
        .invokeMethod<bool>('isValidExpiryDate', {'expiryDate': date});
    return valid!;
  }

  /// Generates card cryptogram.
  ///
  /// [cardNumber] - Card number. For example 4242424242424242.
  ///
  /// [cardDate] - Card expiry date. Must be in the format 'MM/YY'. For example 03/24.
  ///
  /// [cardCVC] - Card CVC or CVV code.
  ///
  /// [publicId] - Your Cloudpayments public id. You can obtain it in your [Cloudpayments account](https://merchant.cloudpayments.ru/)
  static Future<Cryptogram> cardCryptogram({
    required String cardNumber,
    required String cardDate,
    required String cardCVC,
    required String publicId,
  }) async {
    final date = _formatExpiryDate(cardDate);
    final dynamic arguments =
        await _channel.invokeMethod<dynamic>('cardCryptogram', {
      'cardNumber': cardNumber,
      'cardDate': date,
      'cardCVC': cardCVC,
      'publicId': publicId,
    });
    return Cryptogram(arguments['cryptogram'], arguments['error']);
  }

  /// Shows 3DS dialog. [ascUrl], [transactionId], [paReq] are returned in response from the Cloudpayments api
  /// if a 3DS authentication is needed.
  ///
  /// Returns [ThreeDsResponse]. You have to use parameters of [ThreeDsResponse] in post3ds api method.
  static Future<ThreeDsResponse?> show3ds({
    required String acsUrl,
    required String transactionId,
    required String paReq,
  }) async {
    try {
      final dynamic arguments =
          await _channel.invokeMethod<dynamic>('show3ds', {
        'acsUrl': acsUrl,
        'transactionId': transactionId,
        'paReq': paReq,
      });

      if (arguments == null) {
        return null;
      } else {
        return ThreeDsResponse(
            success: true, md: arguments['md'], paRes: arguments['paRes']);
      }
    } on PlatformException catch (e) {
      return ThreeDsResponse(success: false, error: e.message);
    }
  }

  static String _formatExpiryDate(String expiryDate) {
    if (Platform.isAndroid) {
      return expiryDate.replaceAll('/', '');
    } else if (Platform.isIOS) {
      return expiryDate;
    } else {
      throw Exception("Platform is not supported");
    }
  }
}
