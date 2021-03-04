import 'package:cloudpayments_example/models/transaction.dart';
import 'package:equatable/equatable.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();
  @override
  List<Object> get props => [];
}

class PayButtonPressed extends CheckoutEvent {
  final String cardHolder;
  final String cardNumber;
  final String expiryDate;
  final String cvcCode;

  PayButtonPressed({this.cardHolder, this.cardNumber, this.expiryDate, this.cvcCode});
}

class Init extends CheckoutEvent {}

class Auth extends CheckoutEvent {
  final String cryptogram;
  final String cardHolder;
  final String amount;

  Auth(this.cryptogram, this.cardHolder, this.amount);
}

class Charge extends CheckoutEvent {
  final String token;
  final String cardHolder;
  final String amount;

  Charge(this.token, this.cardHolder, this.amount);
}

class Show3DS extends CheckoutEvent {
  final Transaction transaction;

  Show3DS(this.transaction);
}

class Post3DS extends CheckoutEvent {
  final String md;
  final String paRes;

  Post3DS(this.md, this.paRes);
}

class GooglePayPressed extends CheckoutEvent {

}

class ApplePayPressed extends CheckoutEvent {

}
