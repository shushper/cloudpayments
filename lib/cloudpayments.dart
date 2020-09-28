
import 'dart:async';

import 'package:flutter/services.dart';

class Cloudpayments {
  static const MethodChannel _channel =
      const MethodChannel('cloudpayments');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
