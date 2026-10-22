import 'package:flutter/material.dart';
import 'package:linkflutter/core/utils/color_utils.dart';
import 'package:linkflutter/features/cards/models/card_badge_type.dart';
import 'package:linkflutter/features/cards/models/card_style.dart';

class CardThemeSettings {
  const CardThemeSettings({
    this.style = CardStyle.noir,
    this.showQrCode = true,
    this.cardBadge = CardBadgeType.personalTag,
    this.proDesignId,
    this.brandColor,
    this.useCompanyColors = false,
  });

  factory CardThemeSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return const CardThemeSettings();
    }

    final brandColor = json['brandColor'] as String?;
    final hasBrandColor = brandColor != null && brandColor.isNotEmpty;
    final useCompanyColors = json.containsKey('useCompanyColors')
        ? (json['useCompanyColors'] as bool? ?? false)
        : hasBrandColor;

    return CardThemeSettings(
      style: CardStyle.fromKey(json['style'] as String?),
      showQrCode: json['showQrCode'] as bool? ?? true,
      cardBadge: CardBadgeType.fromKey(json['cardBadge'] as String?),
      proDesignId: json['proDesignId'] as String?,
      brandColor: brandColor,
      useCompanyColors: useCompanyColors,
    );
  }

  final CardStyle style;
  final bool showQrCode;
  final CardBadgeType cardBadge;
  final String? proDesignId;
  final String? brandColor;
  final bool useCompanyColors;

  Color? get brandColorValue => colorFromHex(brandColor);

  Map<String, dynamic> toJson() => {
    'style': style.name,
    'showQrCode': showQrCode,
    'cardBadge': cardBadge.name,
    if (proDesignId != null) 'proDesignId': proDesignId,
    'useCompanyColors': useCompanyColors,
    if (useCompanyColors && brandColor != null && brandColor!.isNotEmpty)
      'brandColor': brandColor,
  };

  CardThemeSettings copyWith({
    CardStyle? style,
    bool? showQrCode,
    CardBadgeType? cardBadge,
    String? proDesignId,
    String? brandColor,
    bool? useCompanyColors,
    bool clearProDesignId = false,
    bool clearBrandColor = false,
  }) {
    return CardThemeSettings(
      style: style ?? this.style,
      showQrCode: showQrCode ?? this.showQrCode,
      cardBadge: cardBadge ?? this.cardBadge,
      proDesignId: clearProDesignId ? null : (proDesignId ?? this.proDesignId),
      brandColor: clearBrandColor ? null : (brandColor ?? this.brandColor),
      useCompanyColors: useCompanyColors ?? this.useCompanyColors,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CardThemeSettings &&
            style == other.style &&
            showQrCode == other.showQrCode &&
            cardBadge == other.cardBadge &&
            proDesignId == other.proDesignId &&
            brandColor == other.brandColor &&
            useCompanyColors == other.useCompanyColors;
  }

  @override
  int get hashCode => Object.hash(
    style,
    showQrCode,
    cardBadge,
    proDesignId,
    brandColor,
    useCompanyColors,
  );
}
