import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:cloudpayments/cloudpayments.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pay with cart',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Icon(Icons.credit_card),
                  ],
                ),
              ),
              SizedBox(height: 8,),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Function onPressed;

  CustomButton({this.child, this.backgroundColor, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) => backgroundColor),
          minimumSize: MaterialStateProperty.resolveWith((states) => Size(double.infinity, 48.0))),
      onPressed: onPressed,
      child: child,
    );
  }
}
