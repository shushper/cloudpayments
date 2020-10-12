import 'package:cloudpayments/cloudpayments.dart';
import 'package:cloudpayments/cryptogram.dart';
import 'package:cloudpayments_example/constants.dart';
import 'package:cloudpayments_example/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CardScreen extends StatefulWidget {
  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  final _formKey = GlobalKey<FormState>();
  final cardHolderController = TextEditingController();
  final cardNumberMaskFormatter = MaskTextInputFormatter(mask: '#### #### #### ####');
  final expireDateFormatter = MaskTextInputFormatter(mask: '##/##');
  final cvcDateFormatter = MaskTextInputFormatter(mask: '###');

  bool _isInvalidAsyncCardHolder = false;
  bool _isInvalidAsyncCardNumber = false;
  bool _isInvalidAsyncExpireDate = false;
  bool _isInvalidAsyncCvcCode = false;

  Cryptogram cryptogram;

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

  void _generateCryptogram() async {
    print('_generateCryptogram');
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      FocusScope.of(context).unfocus();

      final cardHolder = cardHolderController.text;
      final isCardHolderValid = cardHolder.isNotEmpty;

      final cardNumber = cardNumberMaskFormatter.getUnmaskedText();
      final isValidCardNumber = await Cloudpayments.isValidNumber(cardNumber);

      final expireDate = expireDateFormatter.getUnmaskedText();
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

        setState(() {
          this.cryptogram = cryptogram;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _formKey.currentState?.validate();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay with card'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
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
                  child: Text('GENERATE CRYPTOGRAM'),
                  onPressed: _generateCryptogram,
                ),
                if (cryptogram != null) CryptogramResult(cryptogram),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CryptogramResult extends StatelessWidget {
  final Cryptogram cryptogram;

  CryptogramResult(this.cryptogram);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (cryptogram.cryptogram != null) ..._cryptogramWidgets(),
        if (cryptogram.error != null) ..._errorWidgets(),
      ],
    );
  }

  List<Widget> _cryptogramWidgets() {
    return [
      SizedBox(
        height: 16,
      ),
      Text(
        'Cryptogram successfully generated',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
      SizedBox(
        height: 8,
      ),
      Text('${cryptogram.cryptogram}'),
    ];
  }

  List<Widget> _errorWidgets() {
    return [
      SizedBox(
        height: 16,
      ),
      Text(
        'Error while generating cryptogram',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
      SizedBox(
        height: 8,
      ),
      Text('${cryptogram.error}'),
    ];
  }
}
