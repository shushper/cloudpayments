import 'package:equatable/equatable.dart';

class CheckoutState extends Equatable {
  const CheckoutState();
  @override
  List<Object> get props => [];
}

class MainState extends CheckoutState {
  final bool isLoading;
  final String cardHolderError;
  final String cardNumberError;
  final String expireDateError;
  final String cvcError;

  MainState({this.isLoading = false, this.cardHolderError, this.cardNumberError, this.expireDateError, this.cvcError});

  @override
  List<Object> get props => [isLoading, cardNumberError, cardNumberError, expireDateError, cvcError];
}

class ShowSnackBar extends CheckoutState {
  final String message;

  ShowSnackBar(this.message);

  @override
  List<Object> get props => [message];
}
