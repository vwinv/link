/// Doit rester aligné avec `backend-link/src/modules/subscriptions/apple-iap-products.ts`.
const kDefaultAppleProductIds = <String, String>{
  'link-premium:MONTHLY': 'com.mega.dropone.premium.monthly',
  'link-premium:YEARLY': 'com.mega.dropone.premium.yearly',
  'link-premium:LIFETIME': 'com.mega.dropone.premium.lifetime',
  'link-premium-plus:MONTHLY': 'com.mega.dropone.premiumplus.monthly',
  'link-premium-plus:YEARLY': 'com.mega.dropone.premiumplus.yearly',
  'link-premium-plus:LIFETIME': 'com.mega.dropone.premiumplus.lifetime',
  'link-premium-equipe:MONTHLY': 'com.mega.dropone.team.monthly',
  'link-premium-equipe:YEARLY': 'com.mega.dropone.team.yearly',
  'link-premium-equipe:LIFETIME': 'com.mega.dropone.team.lifetime',
  'link-entreprise-business:MONTHLY': 'com.mega.dropone.business.monthly',
  'link-entreprise-business:YEARLY': 'com.mega.dropone.business.yearly',
  'link-entreprise-business:LIFETIME': 'com.mega.dropone.business.lifetime',
  'drop-one-plus:MONTHLY': 'com.mega.dropone.premium.monthly',
  'drop-one-plus:YEARLY': 'com.mega.dropone.premium.yearly',
  'drop-one-plus:LIFETIME': 'com.mega.dropone.premium.lifetime',
  'drop-one-premium:MONTHLY': 'com.mega.dropone.premiumplus.monthly',
  'drop-one-premium:YEARLY': 'com.mega.dropone.premiumplus.yearly',
  'drop-one-premium:LIFETIME': 'com.mega.dropone.premiumplus.lifetime',
  'drop-one-business:MONTHLY': 'com.mega.dropone.business.monthly',
  'drop-one-business:YEARLY': 'com.mega.dropone.business.yearly',
  'drop-one-business:LIFETIME': 'com.mega.dropone.business.lifetime',
};

String? appleProductIdFor({
  required String offerSlug,
  required String billingType,
  String? fromApi,
}) {
  final apiId = fromApi?.trim() ?? '';
  if (apiId.isNotEmpty) return apiId;
  return kDefaultAppleProductIds['$offerSlug:${billingType.toUpperCase()}'];
}
