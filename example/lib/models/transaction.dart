class Transaction {
  final String transactionId;
  final int reasonCode;
  final String cardHolderMessage;
  final String paReq;
  final String ascUrl;

  Transaction.fromJson(Map<String, dynamic> json)
      : transactionId = json['TransactionId'].toString(),
        reasonCode = json['ReasonCode'],
        cardHolderMessage = json['CardHolderMessage'],
        paReq = json['PaReq'],
        ascUrl = json['AcsUrl'];

  @override
  String toString() {
    return 'Transaction{transactionId: $transactionId, reasonCode: $reasonCode, cardHolderMessage: $cardHolderMessage, paReq: $paReq, ascUrl: $ascUrl}';
  }
}