class WalletAddResult {
  const WalletAddResult({
    required this.walletType,
    required this.savedCardId,
    this.passBase64,
    this.saveUrl,
  });

  factory WalletAddResult.fromJson(Map<String, dynamic> json) {
    return WalletAddResult(
      walletType: json['walletType'] as String,
      savedCardId: json['savedCardId'] as String,
      passBase64: json['passBase64'] as String?,
      saveUrl: json['saveUrl'] as String?,
    );
  }

  final String walletType;
  final String savedCardId;
  final String? passBase64;
  final String? saveUrl;
}
