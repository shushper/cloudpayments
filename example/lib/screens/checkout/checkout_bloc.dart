import 'dart:io';

import 'package:cloudpayments/cloudpayments.dart';
import 'package:cloudpayments/cloudpayments_apple_pay.dart';
import 'package:cloudpayments_example/common/extended_bloc.dart';
import 'package:cloudpayments_example/constants.dart';
import 'package:cloudpayments_example/network/api.dart';
import 'package:cloudpayments_example/screens/checkout/checkout_event.dart';
import 'package:cloudpayments_example/screens/checkout/checkout_state.dart';

class CheckoutBloc extends ExtendedBloc<CheckoutEvent, CheckoutState> {
  final api = Api();
  final applePay = CloudpaymentsApplePay();

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
    } else if (event is GooglePayPressed) {
      yield* _googlePayPressed(event);
    } else if (event is ApplePayPressed) {
      yield* _applePayPressed(event);
    } else if (event is Charge) {
      yield* _charge(event);
    }
  }

  Stream<CheckoutState> _init(Init event) async* {
    if (Platform.isAndroid) {
      final isGooglePayAvailable = await Cloudpayments.isGooglePayAvailable();
      yield state.copyWith(isGooglePayAvailable: isGooglePayAvailable, isApplePayAvailable: false);
    } else if (Platform.isIOS) {
      final isApplePayAvailable = await applePay.isApplePayAvailable();
      yield state.copyWith(isApplePayAvailable: isApplePayAvailable, isGooglePayAvailable: false);
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
      add(Auth(cryptogram.cryptogram, event.cardHolder, '1'));
    }
  }

  Stream<CheckoutState> _googlePayPressed(GooglePayPressed event) async* {
    yield state.copyWith(isLoading: true);

    try {
      final result = await Cloudpayments.requestGooglePayPayment(
          '2.34', 'RUB', 'RU', Constants.MERCHANT_NAME, Constants.MERCHANT_PUBLIC_ID);

      yield state.copyWith(isLoading: false);

      if (result != null) {
        if (result.status == "SUCCESS") {
          final token = result.result['paymentMethodData']['tokenizationData']['token'];
          add(Charge(token, 'Google Pay', '2.34'));
        } else if (result.status == "ERROR") {
          sendCommand(ShowSnackBar(result.errorDescription));
        }
      }
    } catch (e) {
      yield state.copyWith(isLoading: false);
      sendCommand(ShowSnackBar("Error"));
    }
  }

  Stream<CheckoutState> _applePayPressed(ApplePayPressed event) async* {
    yield state.copyWith(isLoading: true);

    try {
      final result = await applePay.requestApplePayPayment(
        merchantId: 'merchant.com.YOURDOMAIN',
        currencyCode: 'RUB',
        countryCode: 'RU',
        products: [
          {"name": "Манго", "price": "650.50"}
        ],
      );

      if (result != null) {
        add(Auth(result, '', '650.50'));
      }
    } catch (e) {
      print('Error $e');
      yield state.copyWith(isLoading: false);
      sendCommand(ShowSnackBar("Error"));
    }
  }

  Stream<CheckoutState> _charge(Charge event) async* {
    yield state.copyWith(isLoading: true);

    try {
      final transaction = await api.charge(event.token, event.cardHolder, event.amount);
      yield state.copyWith(isLoading: false);
      sendCommand(ShowSnackBar(transaction.cardHolderMessage));
    } catch (e) {
      yield state.copyWith(isLoading: false);
      sendCommand(ShowSnackBar("Error"));
    }
  }

  Stream<CheckoutState> _auth(Auth event) async* {
    yield state.copyWith(isLoading: true);

    try {
      final transaction = await api.auth(event.cryptogram, event.cardHolder, event.amount);
      yield state.copyWith(isLoading: false);
      if (transaction.paReq != null && transaction.acsUrl != null) {
        add(Show3DS(transaction));
      } else {
        sendCommand(ShowSnackBar(transaction.cardHolderMessage));
      }
    } catch (e) {
      yield state.copyWith(isLoading: false);
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
    yield state.copyWith(isLoading: true);

    try {
      final transaction = await api.post3ds(event.md, event.paRes);
      yield state.copyWith(isLoading: false);
      sendCommand(ShowSnackBar(transaction.cardHolderMessage));
    } catch (e) {
      yield state.copyWith(isLoading: false);
      sendCommand(ShowSnackBar("Error"));
    }
  }
}
