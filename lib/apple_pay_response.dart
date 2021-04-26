import 'package:flutter/services.dart';

class ApplePayResponse {
  final String status;
  final String token;
  final String errorMessage;

  ApplePayResponse(this.status, this.token, {this.errorMessage});

  ApplePayResponse.fromResult(String result)
      : status = 'SUCCESS',
        token = result,
        errorMessage = null;


  ApplePayResponse.fromPlatformException(PlatformException exception)
      : status = exception.code == 'CANCELED' ? 'CANCELED' : 'ERROR',
        token = null,
        errorMessage = exception.message;

  ApplePayResponse.fromException(Exception exception)
      : status = 'ERROR',
        token = null,
        errorMessage = null;


  /// True if token was obtained successfully
  bool get isSuccess => status == "SUCCESS";

  /// True if there was an error while receiving the token
  bool get isError => status == "ERROR";

  /// True if Apple Pay dialog was canceled
  bool get isCanceled => status == "CANCELED";
}
