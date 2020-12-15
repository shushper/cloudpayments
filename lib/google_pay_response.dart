import 'dart:convert';

class GooglePayResponse {
  final String status;
  final Map<String, dynamic> result;
  final String errorCode;
  final String errorMessage;
  final String errorDescription;

  GooglePayResponse(this.status, this.result, this.errorCode, this.errorMessage, this.errorDescription);

  GooglePayResponse.fromMap(Map<dynamic, dynamic> map)
      : status = map['status'],
        result = map['result'] != null ? parseResult(map['result'])  : null,
        errorCode = map['errorCode'],
        errorMessage = map['errorMessage'],
        errorDescription = map['errorDescription'];

  static Map<String, dynamic> parseResult(String result) {
    final decoded = jsonDecode(result) as Map<String, dynamic>;
    return decoded;
  }
}
