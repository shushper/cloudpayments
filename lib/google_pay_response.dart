import 'dart:convert';

import 'package:cloudpayments/response_statuses.dart';
import 'package:flutter/services.dart';

class GooglePayResponse {
  final String status;
  final Map<String, dynamic>? result;
  final String? errorCode;
  final String? errorMessage;
  final String? errorDescription;

  GooglePayResponse(this.status, this.result,
      {this.errorCode, this.errorMessage, this.errorDescription});

  GooglePayResponse.fromMap(Map<dynamic, dynamic> map)
      : status = map['status'],
        result = map['result'] != null ? parseResult(map['result']) : null,
        errorCode = map['errorCode'],
        errorMessage = map['errorMessage'],
        errorDescription = map['errorDescription'];

  GooglePayResponse.fromPlatformException(PlatformException exception)
      : status = STATUS_ERROR,
        result = null,
        errorCode = exception.code,
        errorMessage = exception.message,
        errorDescription = null;

  GooglePayResponse.fromException()
      : status = STATUS_ERROR,
        result = null,
        errorCode = null,
        errorMessage = null,
        errorDescription = null;

  static Map<String, dynamic>? parseResult(String result) {
    final decoded = jsonDecode(result) as Map<String, dynamic>?;
    return decoded;
  }

  /// Payment token than you can use in payment by a cryptogram
  String? get token =>
      result!['paymentMethodData']['tokenizationData']['token'];

  /// True if token was obtained successfully
  bool get isSuccess => status == STATUS_SUCCESS;

  /// True if there was an error while receiving the token
  bool get isError => status == STATUS_ERROR;

  /// True if Google Pay dialog was canceled
  bool get isCanceled => status == STATUS_CANCELED;
}
