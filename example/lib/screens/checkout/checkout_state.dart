import 'package:equatable/equatable.dart';

class CheckoutState extends Equatable {
  final bool isLoading;
  final bool isGooglePayAvailable;
  final bool isApplePayAvailable;
  final String cardHolderError;
  final String cardNumberError;
  final String expiryDateError;
  final String cvcError;

  CheckoutState({
    this.isLoading = false,
    this.isGooglePayAvailable = false,
    this.isApplePayAvailable = false,
    this.cardHolderError,
    this.cardNumberError,
    this.expiryDateError,
    this.cvcError,
  });

  @override
  List<Object> get props => [
        isLoading,
        isGooglePayAvailable,
        isApplePayAvailable,
        cardHolderError,
        cardNumberError,
        expiryDateError,
        cvcError,
      ];

  CheckoutState copyWith({
    bool isLoading,
    bool isGooglePayAvailable,
    bool isApplePayAvailable,
    String cardHolderError,
    String cardNumberError,
    String expiryDateError,
    String cvcError,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      isGooglePayAvailable: isGooglePayAvailable ?? this.isGooglePayAvailable,
      isApplePayAvailable: isApplePayAvailable ?? this.isApplePayAvailable,
      cardHolderError: cardHolderError,
      cardNumberError: cardNumberError,
      expiryDateError: expiryDateError,
      cvcError: cvcError,
    );
  }
}


