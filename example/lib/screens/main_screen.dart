import 'dart:io';

import 'package:cloudpayments_example/common/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloudpayments example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomButton(
              backgroundColor: Colors.blue,
              onPressed: () {
                Navigator.pushNamed(context, '/card');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pay with card',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Icon(Icons.credit_card),
                ],
              ),
            ),
            SizedBox(
              height: 8,
            ),
            if (Platform.isAndroid)
              CustomButton(
                backgroundColor: Colors.black,
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pay with',
                      textAlign: TextAlign.center,
                    ),
                    SvgPicture.asset(
                      'assets/images/google_pay.svg',
                      height: 30,
                    ),
                  ],
                ),
              ),
            if (Platform.isIOS)
              CustomButton(
                backgroundColor: Colors.black,
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pay with Apple',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
