class Transaction {
  final String transactionId;
  final int reasonCode;
  final String cardHolderMessage;
  final String paReq;
  final String acsUrl;

  Transaction.fromJson(Map<String, dynamic> json)
      : transactionId = json['TransactionId'].toString(),
        reasonCode = json['ReasonCode'],
        cardHolderMessage = json['CardHolderMessage'],
        paReq = json['PaReq'],
        acsUrl = json['AcsUrl'];

  @override
  String toString() {
    return 'Transaction{transactionId: $transactionId, reasonCode: $reasonCode, cardHolderMessage: $cardHolderMessage, paReq: $paReq, ascUrl: $acsUrl}';
  }
}