import 'dart:convert';

class Response {
  final bool success;
  final String message;
  final dynamic data;

  Response(this.success, this.message, this.data);

  Map<String, dynamic> get body =>
      data is String ? jsonDecode(data as String) : data as Map<String, dynamic>;

  Response.fromJson(Map<String, dynamic> json):
        success = json['Success'],
        message = json['Message'],
        data = json['Model'];

}


