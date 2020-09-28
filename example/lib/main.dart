import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:cloudpayments/cloudpayments.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    initPlatformState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await Cloudpayments.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Center(
              child: Text('Running on: $_platformVersion\n'),
            ),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
            ),
            RaisedButton(
              child: Text('Проверить валидность карты'),
              onPressed: () async {
                final cardNumber = _controller.text;
                final isValid = await Cloudpayments.isCardNumberValid(cardNumber);
                print('Card number $cardNumber is valid = $isValid');
              },
            )
          ],
        ),
      ),
    );
  }
}
