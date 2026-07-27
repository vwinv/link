import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkflutter/config/routes/app_navigation.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/ai_scan_quota_l10n.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/scan/models/ai_scan_quota.dart';
import 'package:linkflutter/features/scan/services/business_card_ocr_service.dart';
import 'package:linkflutter/features/scan/services/device_contacts_service.dart';
import 'package:linkflutter/features/scan/services/scans_api_service.dart';
import 'package:linkflutter/features/scan/widgets/scan_review_sheet.dart';
import 'package:linkflutter/features/scan/models/scan_contact_draft.dart';
import 'package:linkflutter/providers/cards_provider.dart';
import 'package:linkflutter/providers/contacts_provider.dart';
import 'package:provider/provider.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  static const _screenBackground = Color(0xFF0C0D10);

  final _imagePicker = ImagePicker();
  final _ocrService = BusinessCardOcrService();
  final _deviceContactsService = DeviceContactsService();

  AiScanQuota _quota = AiScanQuota.empty;
  var _isLoading = true;
  var _isScanning = false;

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadQuota());
  }

  Future<void> _loadQuota() async {
    setState(() => _isLoading = true);

    try {
      final quota = await context.read<ScansApiService>().fetchQuota();
      if (!mounted) return;
      setState(() {
        _quota = quota;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startScan() async {
    if (_isScanning || !_quota.canScan) {
      if (!_quota.canScan) {
        if (_quota.max <= 0) {
          openLinkPremium(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.scanQuotaReached(_quota.max),
              ),
            ),
          );
        }
      }
      return;
    }

    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (!mounted || image == null) return;

    setState(() => _isScanning = true);

    try {
      final draft = await _ocrService.extractFromImagePath(image.path);
      if (!mounted) return;

      if (_isOwnDroponeCard(draft)) {
        setState(() => _isScanning = false);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.scanOwnCardError)),
        );
        return;
      }

      final confirmed = await showScanReviewSheet(
        context,
        draft: draft,
        imagePath: image.path,
      );
      if (!mounted || confirmed == null) {
        setState(() => _isScanning = false);
        return;
      }

      final quota = await context.read<ScansApiService>().recordScan(
            contact: confirmed.toApiBody(),
          );
      if (!mounted) return;
      await context.read<ContactsProvider>().load();
      if (!mounted) return;

      final deviceResult = await _deviceContactsService.saveDraft(confirmed);
      if (!mounted) return;

      setState(() {
        _quota = quota;
        _isScanning = false;
      });

      final message = switch (deviceResult) {
        DeviceContactSaveResult.saved =>
          l10n.scanContactSavedToPhoneNamed(confirmed.fullName),
        DeviceContactSaveResult.permissionDenied =>
          l10n.scanContactPhonePermissionDenied,
        DeviceContactSaveResult.failed =>
          l10n.scanContactAddedNamed(confirmed.fullName),
      };
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } on BusinessCardOcrException catch (error) {
      if (!mounted) return;
      setState(() => _isScanning = false);
      final message = switch (error.message) {
        'empty' => l10n.scanNoTextDetected,
        'unreadable' => l10n.scanUnreadableCard,
        'own_card' => l10n.scanOwnCardError,
        _ => l10n.scanRecordError,
      };
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _isScanning = false);
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
      await _loadQuota();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isScanning = false);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.scanRecordError)),
      );
    }
  }

  bool _isOwnDroponeCard(ScanContactDraft draft) {
    final slug = draft.detectedDroponeSlug?.trim().toLowerCase();
    if (slug == null || slug.isEmpty) return false;

    return context.read<CardsProvider>().cards.any(
          (card) => card.slug.trim().toLowerCase() == slug,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: _screenBackground,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.onPrimary),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenHorizontal,
                      AppSpacing.lg,
                      AppSpacing.screenHorizontal,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.scanTitle,
                          style: TextStyle(
                            color: AppColors.onPrimary,
                            fontSize: context.rs(28),
                            fontWeight: AppFontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.scanSubtitle,
                          style: TextStyle(
                            color: AppColors.onPrimary.withValues(alpha: 0.45),
                            fontSize: context.rs(AppFontSize.md),
                            height: 1.4,
                          ),
                        ),
                        if (!_quota.isUnlimited && _quota.max > 0) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _quota.displayLabelL10n(l10n),
                            style: TextStyle(
                              color: AppColors.onPrimary.withValues(alpha: 0.35),
                              fontSize: context.rs(12),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                        vertical: AppSpacing.xl,
                      ),
                      child: Center(child: _ScanViewfinder()),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenHorizontal,
                      0,
                      AppSpacing.screenHorizontal,
                      AppSpacing.xl,
                    ),
                    child: _ScanCardButton(
                      label: _isScanning
                          ? l10n.scanAnalyzing
                          : _quota.canScan
                              ? l10n.scanScanCard
                              : l10n.scanSeePremium,
                      isLoading: _isScanning,
                      onPressed: _quota.canScan
                          ? _startScan
                          : () => openLinkPremium(context),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ScanViewfinder extends StatelessWidget {
  const _ScanViewfinder();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.clamp(0.0, 320.0);
        final height = width * 0.62;

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: width * 0.88,
                  height: height * 0.72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1B1F),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xl,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _PlaceholderLine(widthFactor: 0.55),
                      SizedBox(height: AppSpacing.md),
                      _PlaceholderLine(widthFactor: 0.72),
                      SizedBox(height: AppSpacing.md),
                      _PlaceholderLine(widthFactor: 0.48),
                      SizedBox(height: AppSpacing.md),
                      _PlaceholderLine(widthFactor: 0.64),
                    ],
                  ),
                ),
              ),
              const _ScanCorner(alignment: Alignment.topLeft),
              const _ScanCorner(alignment: Alignment.topRight),
              const _ScanCorner(alignment: Alignment.bottomLeft),
              const _ScanCorner(alignment: Alignment.bottomRight),
            ],
          ),
        );
      },
    );
  }
}

class _PlaceholderLine extends StatelessWidget {
  const _PlaceholderLine({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: AppColors.onPrimary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
    );
  }
}

class _ScanCorner extends StatelessWidget {
  const _ScanCorner({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    const size = 32.0;
    const stroke = 3.0;
    const color = AppColors.bleu_primaire;

    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;

    return Align(
      alignment: alignment,
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: isTop
                  ? const BorderSide(color: color, width: stroke)
                  : BorderSide.none,
              bottom: !isTop
                  ? const BorderSide(color: color, width: stroke)
                  : BorderSide.none,
              left: isLeft
                  ? const BorderSide(color: color, width: stroke)
                  : BorderSide.none,
              right: !isLeft
                  ? const BorderSide(color: color, width: stroke)
                  : BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanCardButton extends StatelessWidget {
  const _ScanCardButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.buttonHeight,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.onPrimary,
                ),
              )
            : const Icon(Icons.document_scanner_outlined, size: 22),
        label: Text(
          label,
          style: TextStyle(
            fontSize: context.rs(AppFontSize.md),
            fontWeight: AppFontWeight.semiBold,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.bleu_primaire,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor:
              AppColors.bleu_primaire.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ),
    );
  }
}
