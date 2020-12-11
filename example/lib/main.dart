import 'dart:io';

import 'package:cloudpayments/cloudpayments.dart';
import 'package:cloudpayments_example/models/transaction.dart';
import 'package:cloudpayments_example/network/api_error.dart';
import 'package:cloudpayments_example/screens/checkout/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'common/custom_button.dart';
import 'constants.dart';
import 'network/api.dart';

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
      debugShowCheckedModeBanner: false,
      home: CheckoutScreen(),
    );
  }
}

