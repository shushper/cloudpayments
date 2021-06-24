import 'package:flutter/services.dart';

import 'response_statuses.dart';

class ApplePayResponse {
  final String status;
  final String? token;
  final String? errorMessage;

  ApplePayResponse(this.status, this.token, {this.errorMessage});

  ApplePayResponse.fromResult(String result)
      : status = STATUS_SUCCESS,
        token = result,
        errorMessage = null;

  ApplePayResponse.fromPlatformException(PlatformException exception)
      : status =
            exception.code == STATUS_CANCELED ? STATUS_CANCELED : STATUS_ERROR,
        token = null,
        errorMessage = exception.message;

  ApplePayResponse.fromException()
      : status = STATUS_ERROR,
        token = null,
        errorMessage = null;

  /// True if token was obtained successfully
  bool get isSuccess => status == STATUS_SUCCESS;

  /// True if there was an error while receiving the token
  bool get isError => status == STATUS_ERROR;

  /// True if Apple Pay dialog was canceled
  bool get isCanceled => status == STATUS_CANCELED;
}
