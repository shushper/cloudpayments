import 'dart:async';
import 'dart:io';

import 'package:cloudpayments/cloudpayments.dart';
import 'package:cloudpayments/cloudpayments_apple_pay.dart';
import 'package:cloudpayments/cloudpayments_google_pay.dart';
import 'package:cloudpayments_example/common/extended_bloc.dart';
import 'package:cloudpayments_example/constants.dart';
import 'package:cloudpayments_example/network/api.dart';
import 'package:cloudpayments_example/screens/checkout/checkout_event.dart';
import 'package:cloudpayments_example/screens/checkout/checkout_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckoutBloc extends ExtendedBloc<CheckoutEvent, CheckoutState> {
  final api = Api();
  final googlePay = CloudpaymentsGooglePay(GooglePayEnvironment.test);
  final applePay = CloudpaymentsApplePay();

  CheckoutBloc()
      : super(CheckoutState(isLoading: false, isGooglePayAvailable: false)) {
    on<Init>(_init);
    on<PayButtonPressed>(_onPayButtonPressed);
    on<Auth>(_auth);
    on<Show3DS>(_show3DS);
    on<Post3DS>(_post3DS);
    on<GooglePayPressed>(_googlePayPressed);
    on<ApplePayPressed>(_applePayPressed);
    on<Charge>(_charge);
  }

  FutureOr<void> _init(Init event, Emitter<CheckoutState> emit) async {
    if (Platform.isAndroid) {
      final isGooglePayAvailable = await googlePay.isGooglePayAvailable();
      emit(state.copyWith(
          isGooglePayAvailable: isGooglePayAvailable,
          isApplePayAvailable: false));
    } else if (Platform.isIOS) {
      final isApplePayAvailable = await applePay.isApplePayAvailable();
      emit(state.copyWith(
          isApplePayAvailable: isApplePayAvailable,
          isGooglePayAvailable: false));
    }
  }

  FutureOr<void> _onPayButtonPressed(
      PayButtonPressed event, Emitter<CheckoutState> emit) async {
    final isCardHolderValid = event.cardHolder.isNotEmpty;
    final isValidCardNumber =
        await Cloudpayments.isValidNumber(event.cardNumber);
    final isValidExpiryDate =
        await Cloudpayments.isValidExpiryDate(event.expiryDate);
    final isValidCvcCode = event.cvcCode.length == 3;

    if (!isCardHolderValid) {
      print('Card holder is no valid');
      emit(state.copyWith(cardHolderError: 'Card holder can\'t be blank'));
      return;
    } else if (!isValidCardNumber) {
      emit(state.copyWith(cardNumberError: 'Invalid card number'));
      return;
    } else if (!isValidExpiryDate) {
      emit(state.copyWith(expiryDateError: 'Date invalid or expired'));
      return;
    } else if (!isValidCvcCode) {
      emit(state.copyWith(cvcError: 'Incorrect cvv code'));
      return;
    }

    emit(state.copyWith(
        cardHolderError: null,
        cardNumberError: null,
        expiryDateError: null,
        cvcError: null));

    final cryptogram = await Cloudpayments.cardCryptogram(
      cardNumber: event.cardNumber,
      cardDate: event.expiryDate,
      cardCVC: event.cvcCode,
      publicId: Constants.MERCHANT_PUBLIC_ID,
    );

    if (cryptogram.cryptogram != null) {
      add(Auth(cryptogram.cryptogram!, event.cardHolder, '1'));
    }
  }

  FutureOr<void> _googlePayPressed(
      GooglePayPressed event, Emitter<CheckoutState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final result = await googlePay.requestGooglePayPayment(
        price: '2.34',
        currencyCode: 'RUB',
        countryCode: 'RU',
        merchantName: Constants.MERCHANT_NAME,
        publicId: Constants.MERCHANT_PUBLIC_ID,
      );

      emit(state.copyWith(isLoading: false));

      if (result.isSuccess) {
        final token = result.token;
        add(Charge(token!, 'Google Pay', '2.34'));
      } else if (result.isError) {
        sendCommand(ShowSnackBar(result.errorDescription));
      } else if (result.isCanceled) {
        sendCommand(ShowSnackBar('Google pay has canceled'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      sendCommand(ShowSnackBar("Error"));
    }
  }

  FutureOr<void> _applePayPressed(
      ApplePayPressed event, Emitter<CheckoutState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final result = await applePay.requestApplePayPayment(
        merchantId: 'merchant.com.YOURDOMAIN',
        currencyCode: 'RUB',
        countryCode: 'RU',
        products: [
          {"name": "Манго", "price": "650.50"}
        ],
      );

      if (result.isSuccess) {
        final token = result.token;
        add(Auth(token!, '', '650.50'));
      } else if (result.isError) {
        sendCommand(ShowSnackBar(result.errorMessage));
      } else if (result.isCanceled) {
        sendCommand(ShowSnackBar('Apple pay has canceled'));
      }
    } catch (e) {
      print('Error $e');
      emit(state.copyWith(isLoading: false));
      sendCommand(ShowSnackBar("Error"));
    }
  }

  FutureOr<void> _charge(Charge event, Emitter<CheckoutState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final transaction =
          await api.charge(event.token, event.cardHolder, event.amount);
      emit(state.copyWith(isLoading: false));
      sendCommand(ShowSnackBar(transaction.cardHolderMessage));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      sendCommand(ShowSnackBar("Error"));
    }
  }

  FutureOr<void> _auth(Auth event, Emitter<CheckoutState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final transaction =
          await api.auth(event.cryptogram, event.cardHolder, event.amount);
      emit(state.copyWith(isLoading: false));
      if (transaction.paReq != null && transaction.acsUrl != null) {
        add(Show3DS(transaction));
      } else {
        sendCommand(ShowSnackBar(transaction.cardHolderMessage));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      sendCommand(ShowSnackBar("Error"));
    }
  }

  FutureOr<void> _show3DS(Show3DS event, Emitter<CheckoutState> emit) async {
    final transaction = event.transaction;
    final result = await Cloudpayments.show3ds(
      acsUrl: transaction.acsUrl,
      transactionId: transaction.transactionId,
      paReq: transaction.paReq,
    );

    if (result != null) {
      if (result.success!) {
        add(Post3DS(result.md!, result.paRes!));
      } else {
        sendCommand(ShowSnackBar(result.error));
      }
    }
  }

  FutureOr<void> _post3DS(Post3DS event, Emitter<CheckoutState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final transaction = await api.post3ds(event.md, event.paRes);
      emit(state.copyWith(isLoading: false));
      sendCommand(ShowSnackBar(transaction.cardHolderMessage));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      sendCommand(ShowSnackBar("Error"));
    }
  }
}
