import 'dart:io';

import 'package:cloudpayments/cloudpayments.dart';
import 'package:cloudpayments_example/models/transaction.dart';
import 'package:cloudpayments_example/network/api_error.dart';
import 'package:flutter/material.dart';
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
      home: CheckoutScreen(),
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final cardHolderController = TextEditingController();
  final cardNumberMaskFormatter = MaskTextInputFormatter(mask: '#### #### #### ####');
  final expireDateFormatter = MaskTextInputFormatter(mask: '##/##');
  final cvcDateFormatter = MaskTextInputFormatter(mask: '###');
  final api = Api();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _isInvalidAsyncCardHolder = false;
  bool _isInvalidAsyncCardNumber = false;
  bool _isInvalidAsyncExpireDate = false;
  bool _isInvalidAsyncCvcCode = false;
  bool _isLoading = false;

  void setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  String _validateCardHolder(String cardHolder) {
    if (_isInvalidAsyncCardHolder) {
      _isInvalidAsyncCardHolder = false;
      return 'Card holder can\'t be blank';
    }
    return null;
  }

  String _validateCardNumber(String cardNumber) {
    if (_isInvalidAsyncCardNumber) {
      _isInvalidAsyncCardNumber = false;
      return 'Invalid card number';
    }
    return null;
  }

  String _validateExpireDate(String expireDate) {
    if (_isInvalidAsyncExpireDate) {
      _isInvalidAsyncExpireDate = false;
      return 'Date invalid or expired';
    }
    return null;
  }

  String _validateCvv(String cvc) {
    if (_isInvalidAsyncCvcCode) {
      _isInvalidAsyncCvcCode = false;
      return 'Incorrect cvv code';
    }
    return null;
  }

  void _onPayClick() async {
    print('_onPayClick');
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      FocusScope.of(context).unfocus();

      final cardHolder = cardHolderController.text;
      final isCardHolderValid = cardHolder.isNotEmpty;

      final cardNumber = cardNumberMaskFormatter.getUnmaskedText();
      final isValidCardNumber = await Cloudpayments.isValidNumber(cardNumber);

      final expireDate = expireDateFormatter.getMaskedText();
      final isValidExpireDate = await Cloudpayments.isValidExpireDate(expireDate);

      final cvcCode = cvcDateFormatter.getUnmaskedText();
      final isValidCvcCode = cvcCode.length == 3;

      if (!isCardHolderValid) {
        setState(() {
          _isInvalidAsyncCardHolder = true;
        });
      } else if (!isValidCardNumber) {
        setState(() {
          _isInvalidAsyncCardNumber = true;
        });
      } else if (!isValidExpireDate) {
        setState(() {
          _isInvalidAsyncExpireDate = true;
        });
      } else if (!isValidCvcCode) {
        setState(() {
          _isInvalidAsyncCvcCode = true;
        });
      } else {
        final cryptogram = await Cloudpayments.cardCryptogram(
          cardNumber,
          expireDate,
          cvcCode,
          Constants.MERCHANT_PUBLIC_ID,
        );

        print('Cryptogram = ${cryptogram.cryptogram}, Error = ${cryptogram.error}');

        if (cryptogram.cryptogram != null) {
          _auth(cryptogram.cryptogram, cardHolder, 1);
        }
      }
    }
  }

  void _auth(String cryptogram, String cardHolder, int amount) async {
    setLoading(true);

    try {
      final transaction = await api.auth(cryptogram, cardHolder, amount);
      setLoading(false);
      if (transaction.paReq != null && transaction.ascUrl != null) {
        _show3ds(transaction);
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(transaction.cardHolderMessage)));
      }
    } catch (e) {
      setLoading(false);
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Error")));
    }
  }

  void _show3ds(Transaction transaction) async {
    print('show 3ds');
    final result = await Cloudpayments.show3ds(transaction.ascUrl, transaction.transactionId, transaction.paReq);

    if (result != null) {
      if (result.success) {
        _post3ds(result.md, result.paRes);
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(result.error)));
      }
    }
  }

  void _post3ds(String md, String paRes) async {
    print('_post3ds md = $md, paRes = $paRes');
    setLoading(true);

    try {
      final transaction = await api.post3ds(md, paRes);
      setLoading(false);

      print(transaction);

      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(transaction.cardHolderMessage)));
    } catch (e) {
      setLoading(false);
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    _formKey.currentState?.validate();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total to be paid: 2 RUB.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: cardHolderController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: _validateCardHolder,
                    decoration: InputDecoration(
                      labelText: 'Card holder',
                      labelStyle: TextStyle(color: Colors.grey),
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [cardNumberMaskFormatter],
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Card number',
                      labelStyle: TextStyle(color: Colors.grey),
                      border: UnderlineInputBorder(),
                    ),
                    validator: _validateCardNumber,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          inputFormatters: [expireDateFormatter],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Expire Date',
                            labelStyle: TextStyle(color: Colors.grey),
                            border: UnderlineInputBorder(),
                          ),
                          validator: _validateExpireDate,
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: TextFormField(
                            textInputAction: TextInputAction.done,
                            inputFormatters: [cvcDateFormatter],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'CVC',
                              labelStyle: TextStyle(color: Colors.grey),
                              border: UnderlineInputBorder(),
                            ),
                            validator: _validateCvv),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  CustomButton(
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
                    onPressed: _onPayClick,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text('or'),
                  ),
                  SizedBox(
                    height: 16,
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
          ),
        ),
      ),
    );
  }
}
