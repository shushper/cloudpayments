import 'dart:io';

import 'package:cloudpayments/cloudpayments.dart';
import 'package:cloudpayments_example/common/extended_bloc.dart';
import 'package:cloudpayments_example/constants.dart';
import 'package:cloudpayments_example/network/api.dart';
import 'package:cloudpayments_example/screens/checkout/checkout_event.dart';
import 'package:cloudpayments_example/screens/checkout/checkout_state.dart';

class CheckoutBloc extends ExtendedBloc<CheckoutEvent, CheckoutState> {
  final api = Api();

  CheckoutBloc() : super(CheckoutState(isLoading: false, isGooglePayAvailable: false));

  @override
  Stream<CheckoutState> mapEventToState(CheckoutEvent event) async* {
    if (event is Init) {
      yield* _init(event);
    } else if (event is PayButtonPressed) {
      yield* _onPayButtonPressed(event);
    } else if (event is Auth) {
      yield* _auth(event);
    } else if (event is Show3DS) {
      yield* _show3DS(event);
    } else if (event is Post3DS) {
      yield* _post3DS(event);
    }
  }

  Stream<CheckoutState> _init(Init event) async* {
    if (Platform.isAndroid) {
      final isGooglePayAvailable = await Cloudpayments.isGooglePayAvailable();
      yield state.copyWith(isGooglePayAvailable: isGooglePayAvailable);
    } else if (Platform.isIOS) {

    }
  }

  Stream<CheckoutState> _onPayButtonPressed(PayButtonPressed event) async* {
    final isCardHolderValid = event.cardHolder.isNotEmpty;
    final isValidCardNumber = await Cloudpayments.isValidNumber(event.cardNumber);
    final isValidExpireDate = await Cloudpayments.isValidExpireDate(event.expireDate);
    final isValidCvcCode = event.cvcCode.length == 3;

    if (!isCardHolderValid) {
      yield state.copyWith(cardHolderError: 'Card holder can\'t be blank');
      return;
    } else if (!isValidCardNumber) {
      yield state.copyWith(cardNumberError: 'Invalid card number');
      return;
    } else if (!isValidExpireDate) {
      yield state.copyWith(expireDateError: 'Date invalid or expired');
      return;
    } else if (!isValidCvcCode) {
      yield state.copyWith(cvcError: 'Incorrect cvv code');
      return;
    }

    yield state.copyWith(cardHolderError: null, cardNumberError: null, expireDateError: null, cvcError: null);

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
    yield CheckoutState(isLoading: true);

    try {
      final transaction = await api.auth(event.cryptogram, event.cardHolder, event.amount);
      yield CheckoutState(isLoading: false);
      if (transaction.paReq != null && transaction.acsUrl != null) {
        add(Show3DS(transaction));
      } else {
        sendCommand(ShowSnackBar(transaction.cardHolderMessage));
      }
    } catch (e) {
      yield CheckoutState(isLoading: false);
      sendCommand(ShowSnackBar("Error"));
    }
  }

  Stream<CheckoutState> _show3DS(Show3DS event) async* {
    final transaction = event.transaction;
    final result = await Cloudpayments.show3ds(transaction.acsUrl, transaction.transactionId, transaction.paReq);

    if (result != null) {
      if (result.success) {
        add(Post3DS(result.md, result.paRes));
      } else {
        sendCommand(ShowSnackBar(result.error));
      }
    }
  }

  Stream<CheckoutState> _post3DS(Post3DS event) async* {
    yield CheckoutState(isLoading: true);

    try {
      final transaction = await api.post3ds(event.md, event.paRes);
      yield CheckoutState(isLoading: false);

      print(transaction);

      sendCommand(ShowSnackBar(transaction.cardHolderMessage));
    } catch (e) {
      yield CheckoutState(isLoading: false);
      sendCommand(ShowSnackBar("Error"));
    }
  }
}
