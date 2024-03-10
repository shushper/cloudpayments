class PayRequest {
  final String amount;
  final String currency;
  final String name;
  final String cardCryptogramPacket;
  final String invoiceId;
  final String description;
  final String accountId;
  final String jsonData;

  PayRequest({
    required this.amount,
    required this.currency,
    required this.name,
    required this.cardCryptogramPacket,
    required this.invoiceId,
    required this.description,
    required this.accountId,
    required this.jsonData,
  });

  Map<String, dynamic> toJson() {
    final map = Map<String, dynamic>();

    map['amount'] = amount;
    map['currency'] = currency;
    map['name'] = name;
    map['card_cryptogram_packet'] = cardCryptogramPacket;
    map['invoice_id'] = invoiceId;
    map['description'] = description;
    map['account_id'] = accountId;
    map['json_data'] = jsonData;

    return map;
  }
}
