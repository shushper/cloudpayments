import 'package:equatable/equatable.dart';

class CheckoutState extends Equatable {
  final bool isLoading;
  final bool isGooglePayAvailable;
  final bool isApplePayAvailable;
  final String cardHolderError;
  final String cardNumberError;
  final String expireDateError;
  final String cvcError;

  CheckoutState({
    this.isLoading = false,
    this.isGooglePayAvailable = false,
    this.isApplePayAvailable = false,
    this.cardHolderError,
    this.cardNumberError,
    this.expireDateError,
    this.cvcError,
  });

  @override
  List<Object> get props => [
        isLoading,
        isGooglePayAvailable,
        isApplePayAvailable,
        cardNumberError,
        cardNumberError,
        expireDateError,
        cvcError,
      ];

  CheckoutState copyWith({
    bool isLoading,
    bool isGooglePayAvailable,
    bool isApplePayAvailable,
    String cardHolderError,
    String cardNumberError,
    String expireDateError,
    String cvcError,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      isGooglePayAvailable: isGooglePayAvailable ?? this.isGooglePayAvailable,
      isApplePayAvailable: isApplePayAvailable ?? this.isApplePayAvailable,
      cardHolderError: cardHolderError,
      cardNumberError: cardNumberError,
      expireDateError: expireDateError,
      cvcError: cvcError,
    );
  }
}


