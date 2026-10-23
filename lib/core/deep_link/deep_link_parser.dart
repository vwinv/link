const _reservedCardPathSegments = {'create', 'professional'};

class PublicDeepLink {
  const PublicDeepLink({required this.slug, required this.isPortfolio});

  final String slug;
  final bool isPortfolio;

  String get dismissKey => isPortfolio ? 'portfolio:$slug' : slug;
}

/// Lien public carte (`/cards/{slug}`) ou portfolio (`/portfolios/{slug}`).
PublicDeepLink? parsePublicDeepLink(Uri? uri) {
  if (uri == null) return null;

  final segments = uri.pathSegments.where((part) => part.isNotEmpty).toList();

  if (segments.length == 2 &&
      (segments.first == 'cards' || segments.first == 'portfolios')) {
    final slug = segments[1].trim();
    if (slug.isEmpty || _reservedCardPathSegments.contains(slug)) {
      return null;
    }
    return PublicDeepLink(
      slug: slug,
      isPortfolio: segments.first == 'portfolios',
    );
  }

  if (uri.scheme == 'link' &&
      (uri.host == 'cards' || uri.host == 'portfolios') &&
      segments.isNotEmpty) {
    final slug = segments.first.trim();
    if (slug.isEmpty) return null;
    return PublicDeepLink(slug: slug, isPortfolio: uri.host == 'portfolios');
  }

  return null;
}

/// Extrait le slug d’une carte depuis un lien public ou un deep link.
String? parseCardSlugFromUri(Uri? uri) {
  final link = parsePublicDeepLink(uri);
  if (link == null || link.isPortfolio) return null;
  return link.slug;
}
