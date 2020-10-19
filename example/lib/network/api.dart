import 'package:cloudpayments_example/models/transaction.dart';
import 'package:cloudpayments_example/network/network.dart';
import 'package:cloudpayments_example/network/pay_request.dart';
import 'package:cloudpayments_example/network/urls.dart';

class Api {
  final _network = Network(Url.apiUrl);

  Future<Transaction> auth(String cardCryptogramPacket, String cardHolderName, int amount) async {
    final request = PayRequest(
      amount: amount.toString(),
      currency: "RUB",
      name: cardHolderName,
      cardCryptogramPacket: cardCryptogramPacket,
      invoiceId: "1122",
      description: "Оплата товаров",
      accountId: "123",
      jsonData: "{\"age\":27,\"name\":\"Ivan\",\"phone\":\"+79998881122\"}",
    );

    final response = await _network.post(Url.authUrl,
        headers: {'Content-Type': 'application/json'}, body: request.toJson());

    return Transaction.fromJson(response.data);
  }
}