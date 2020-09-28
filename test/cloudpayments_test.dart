import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloudpayments/cloudpayments.dart';

void main() {
  const MethodChannel channel = MethodChannel('cloudpayments');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await Cloudpayments.platformVersion, '42');
  });
}
