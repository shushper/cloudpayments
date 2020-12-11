import 'package:cloudpayments/cloudpayments.dart';
import 'package:cloudpayments_example/constants.dart';
import 'package:cloudpayments_example/network/api.dart';
import 'package:cloudpayments_example/screens/checkout/checkout_event.dart';
import 'package:cloudpayments_example/screens/checkout/checkout_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final api = Api();

  CheckoutBloc() : super(MainState(isLoading: false));

  @override
  Stream<CheckoutState> mapEventToState(CheckoutEvent event) async* {
    if (event is PayButtonPressed) {
      yield* _onPayButtonPressed(event);
    } else if (event is Auth) {
      yield* _auth(event);
    } else if (event is Show3DS) {
      yield* _show3DS(event);
    } else if (event is Post3DS) {
      yield* _post3DS(event);
    }
  }

  Stream<CheckoutState> _onPayButtonPressed(PayButtonPressed event) async* {
    final isCardHolderValid = event.cardHolder.isNotEmpty;
    final isValidCardNumber = await Cloudpayments.isValidNumber(event.cardNumber);
    final isValidExpireDate = await Cloudpayments.isValidExpireDate(event.expireDate);
    final isValidCvcCode = event.cvcCode.length == 3;

    if (!isCardHolderValid) {
      yield MainState(cardHolderError: 'Card holder can\'t be blank');
      return;
    } else if (!isValidCardNumber) {
      yield MainState(cardNumberError: 'Invalid card number');
      return;
    } else if (!isValidExpireDate) {
      yield MainState(expireDateError: 'Date invalid or expired');
      return;
    } else if (!isValidCvcCode) {
      yield MainState(cvcError: 'Incorrect cvv code');
      return;
    }

    yield MainState();

    final cryptogram = await Cloudpayments.cardCryptogram(
      event.cardNumber,
      event.expireDate,
      event.cvcCode,
      Constants.MERCHANT_PUBLIC_ID,
    );

    if (cryptogram.cryptogram != null) {
      add(Auth(cryptogram.cryptogram, event.cardHolder, 1));
    }
  }

  Stream<CheckoutState> _auth(Auth event) async* {
    yield MainState(isLoading: true);

    try {
      final transaction = await api.auth(event.cryptogram, event.cardHolder, event.amount);
      yield MainState(isLoading: false);
      if (transaction.paReq != null && transaction.acsUrl != null) {
        add(Show3DS(transaction));
      } else {
        yield ShowSnackBar(transaction.cardHolderMessage);
      }
    } catch (e) {
      yield MainState(isLoading: false);
      yield ShowSnackBar("Error");
    }
  }

  Stream<CheckoutState> _show3DS(Show3DS event) async* {
    final transaction = event.transaction;
    final result = await Cloudpayments.show3ds(transaction.acsUrl, transaction.transactionId, transaction.paReq);

    if (result != null) {
      if (result.success) {
        add(Post3DS(result.md, result.paRes));
      } else {
        yield ShowSnackBar(result.error);
      }
    }
  }

  Stream<CheckoutState> _post3DS(Post3DS event) async* {
    yield MainState(isLoading: true);

    try {
      final transaction = await api.post3ds(event.md, event.paRes);
      yield MainState(isLoading: false);

      print(transaction);

      yield ShowSnackBar(transaction.cardHolderMessage);
    } catch (e) {
      yield MainState(isLoading: false);
      yield ShowSnackBar("Error");
    }
  }
}
