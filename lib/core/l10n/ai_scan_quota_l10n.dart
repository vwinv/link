import 'package:linkflutter/features/scan/models/ai_scan_quota.dart';
import 'package:linkflutter/l10n/app_localizations.dart';

extension AiScanQuotaL10n on AiScanQuota {
  String displayLabelL10n(AppLocalizations l10n) {
    if (isUnlimited) return l10n.scanUnlimited;
    if (max <= 0) return l10n.scanNotIncluded;
    return l10n.scanUsedCount(used, max);
  }
}
