class PortfolioStyle {
  const PortfolioStyle({
    required this.layoutId,
    required this.colorId,
    this.exists = false,
    this.id,
  });

  static const defaults = PortfolioStyle(
    layoutId: 'classique',
    colorId: 'neon',
  );

  final String layoutId;
  final String colorId;
  final bool exists;
  final String? id;

  factory PortfolioStyle.fromJson(Map<String, dynamic> json) {
    if (json['exists'] != true) return defaults;
    return PortfolioStyle(
      exists: true,
      id: json['id'] as String?,
      layoutId: json['layout'] as String? ?? defaults.layoutId,
      colorId: json['color'] as String? ?? defaults.colorId,
    );
  }
}
