import 'package:cloudpayments_example/common/custom_button.dart';
import 'package:cloudpayments_example/common/extended_bloc.dart';
import 'package:cloudpayments_example/screens/checkout/checkout_bloc.dart';
import 'package:cloudpayments_example/screens/checkout/checkout_event.dart';
import 'package:cloudpayments_example/screens/checkout/checkout_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CheckoutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CheckoutBloc>(
      create: (context) {
        return CheckoutBloc()..add(Init());
      },
      child: CheckoutScreenContent(),
    );
  }
}

class CheckoutScreenContent extends StatefulWidget {
  @override
  _CheckoutScreenContentState createState() => _CheckoutScreenContentState();
}

class _CheckoutScreenContentState extends State<CheckoutScreenContent> {
  final cardHolderController = TextEditingController();
  final cardNumberMaskFormatter = MaskTextInputFormatter(mask: '#### #### #### ####');
  final expireDateFormatter = MaskTextInputFormatter(mask: '##/##');
  final cvcDateFormatter = MaskTextInputFormatter(mask: '###');

  void _onPayClick(BuildContext context) async {
    print('_onPayClick');

    FocusScope.of(context).unfocus();

    final cardHolder = cardHolderController.text;
    final cardNumber = cardNumberMaskFormatter.getUnmaskedText();
    final expiryDate = expireDateFormatter.getMaskedText();
    final cvcCode = cvcDateFormatter.getUnmaskedText();

    final event = PayButtonPressed(
      cardHolder: cardHolder,
      cardNumber: cardNumber,
      expiryDate: expiryDate,
      cvcCode: cvcCode,
    );

    context.read<CheckoutBloc>().add(event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: BlocCommandsListener<CheckoutBloc>(
        listener: (context, command) {
          if (command is ShowSnackBar) {
            final snackBar = SnackBar(
              content: Text(command.message),
            );
            Scaffold.of(context).showSnackBar(snackBar);
          }
        },
        child: BlocBuilder<CheckoutBloc, CheckoutState>(
          builder: (context, state) {
            print('Rebuild screen');
            return LoadingOverlay(
              isLoading: state.isLoading,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total to be paid: 2 RUB.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: cardHolderController,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Card holder',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: UnderlineInputBorder(),
                          errorText: state.cardHolderError,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [cardNumberMaskFormatter],
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Card number',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: UnderlineInputBorder(),
                          errorText: state.cardNumberError,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              textInputAction: TextInputAction.next,
                              inputFormatters: [expireDateFormatter],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Expire Date',
                                labelStyle: TextStyle(color: Colors.grey),
                                border: UnderlineInputBorder(),
                                errorText: state.expiryDateError,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: TextField(
                              textInputAction: TextInputAction.done,
                              inputFormatters: [cvcDateFormatter],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'CVC',
                                labelStyle: TextStyle(color: Colors.grey),
                                border: UnderlineInputBorder(),
                                errorText: state.cvcError,
                              ),
                            ),
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
                        onPressed: () => _onPayClick(context),
                      ),
                      if (state.isGooglePayAvailable)
                        GooglePaySection(),
                      if (state.isApplePayAvailable)
                        ApplePaySection(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class GooglePaySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PaySection(
      CustomButton(
        backgroundColor: Colors.black,
        onPressed: () {
          context.read<CheckoutBloc>().add(GooglePayPressed());
        },
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
    );
  }
}

class ApplePaySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PaySection(
      CustomButton(
        backgroundColor: Colors.black,
        onPressed: () {
          context.read<CheckoutBloc>().add(ApplePayPressed());
        },
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
    );
  }
}

class PaySection extends StatelessWidget {
  final Widget payButton;

  PaySection(this.payButton);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        payButton
      ],
    );
  }
}
