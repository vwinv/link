enum WalletPlatformType {
  apple('APPLE_WALLET'),
  google('GOOGLE_WALLET');

  const WalletPlatformType(this.apiValue);

  final String apiValue;
}
