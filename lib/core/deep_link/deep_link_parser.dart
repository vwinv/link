const _reservedCardPathSegments = {'create', 'professional'};

/// Extrait le slug d’une carte depuis un lien public ou un deep link.
String? parseCardSlugFromUri(Uri? uri) {
  if (uri == null) return null;

  final segments = uri.pathSegments.where((part) => part.isNotEmpty).toList();

  // Lien public : /cards/{slug} (pas /cards/create/...)
  if (segments.length == 2 && segments.first == 'cards') {
    final slug = segments[1].trim();
    if (slug.isEmpty || _reservedCardPathSegments.contains(slug)) {
      return null;
    }
    return slug;
  }

  if (uri.scheme == 'link' && uri.host == 'cards' && segments.isNotEmpty) {
    final slug = segments.first.trim();
    return slug.isEmpty ? null : slug;
  }

  return null;
}
