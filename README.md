# cloudpayments

A Flutter plugin for integrating Cloudpaymanets in Android and iOS applications.

__Disclaimer__: It is not an official plugin. It uses [SDK-Android](https://github.com/cloudpayments/SDK-Android) on Android and [SDK-IOS](https://github.com/cloudpayments/SDK-iOS)
on iOS.

See the official documentation:
- [Android](https://developers.cloudpayments.ru/#sdk-dlya-android)
- [iOS](https://developers.cloudpayments.ru/#sdk-dlya-ios)

<img src="https://raw.githubusercontent.com/shushper/cloudpayments/master/images/example.gif"
width=200 height=400/>

### Supports

- [X] Check the validity of the card's parameters.
- [X] Generate card cryptogram packet.
- [X] Show 3ds dialog.

## Getting Started

### Initializing for Android

If you want to show 3ds dialog on Android, make MainActivity implements `FlutterFragmentActivity` instead of `FlutterActivity`

`android/app/src/main/.../MainActivity.kt`:

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {}
```

## Usage

- Check card number validity.

```dart
bool isValid = await Cloudpayments.isValidNumber(cardNumber);
```

- Check card expire date.

```dart
bool isValid = await Cloudpayments.isValidExpireDate(cardNumber); // MM/yy
```

- Generate card cryptogram packet. You need to get your publicId from your [personal account](https://merchant.cloudpayments.ru/login).

```dart
final cryptogram = await Cloudpayments.cardCryptogram(cardNumber, expireDate, cvcCode, publicId);
```

- Showing 3DS form and get results of 3DS auth.

```dart
final result = await Cloudpayments.show3ds(acsUrl, transactionId, paReq);
```
