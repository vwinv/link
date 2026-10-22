import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/features/subscriptions/models/payment_config.dart';
import 'package:linkflutter/features/subscriptions/services/subscriptions_api_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Bottom sheet SoftPay : saisie → finalisation (QR + ouvrir Wave/Maxit).
class SoftPaySheet extends StatefulWidget {
  const SoftPaySheet({
    super.key,
    required this.offerSlug,
    required this.billingType,
    required this.montantLabel,
    required this.api,
    required this.initialPrenom,
    required this.initialNom,
    required this.initialTelephone,
    this.invoiceToken,
    this.email,
    this.teamId,
    this.seats,
  });

  final String offerSlug;
  final String billingType;
  final String montantLabel;
  final SubscriptionsApiService api;
  final String initialPrenom;
  final String initialNom;
  final String initialTelephone;
  final String? invoiceToken;
  final String? email;
  final String? teamId;
  final int? seats;

  static const BorderRadius topBorderRadius = BorderRadius.vertical(
    top: Radius.circular(24),
  );

  static Future<bool?> show(
    BuildContext context, {
    required String offerSlug,
    required String billingType,
    required String montantLabel,
    required SubscriptionsApiService api,
    required String initialPrenom,
    required String initialNom,
    required String initialTelephone,
    String? invoiceToken,
    String? email,
    String? teamId,
    int? seats,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: topBorderRadius),
      builder: (ctx) => SoftPaySheet(
        offerSlug: offerSlug,
        billingType: billingType,
        montantLabel: montantLabel,
        api: api,
        initialPrenom: initialPrenom,
        initialNom: initialNom,
        initialTelephone: initialTelephone,
        invoiceToken: invoiceToken,
        email: email,
        teamId: teamId,
        seats: seats,
      ),
    );
  }

  @override
  State<SoftPaySheet> createState() => _SoftPaySheetState();
}

class _SoftPaySheetState extends State<SoftPaySheet>
    with WidgetsBindingObserver {
  static const _assetWave = 'assets/wave.png';
  static const _assetOm = 'assets/om.png';
  static const _assetFree = 'assets/free.png';

  late final TextEditingController _prenom;
  late final TextEditingController _nom;
  late final TextEditingController _tel;
  String? _method;
  String? _invoiceToken;
  String? _error;
  bool _loading = false;
  bool _openingWallet = false;
  SoftPayResult? _result;
  Timer? _pollTimer;
  bool _pollInFlight = false;
  bool _paid = false;

  bool get _isFinalizing => _result != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prenom = TextEditingController(text: widget.initialPrenom.trim());
    _nom = TextEditingController(text: widget.initialNom.trim());
    _tel = TextEditingController(text: widget.initialTelephone.trim());
    _invoiceToken = widget.invoiceToken?.trim();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _prenom.dispose();
    _nom.dispose();
    _tel.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isFinalizing && !_paid) {
      unawaited(_pollOnce());
    }
  }

  String? _nonEmpty(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  String? get _walletUrl {
    switch (_method) {
      case 'orange_money_sn':
        return _nonEmpty(_result?.maxitUrl) ?? _nonEmpty(_result?.omUrl);
      case 'wave_sn':
        return _nonEmpty(_result?.url);
      default:
        return _nonEmpty(_result?.url) ??
            _nonEmpty(_result?.maxitUrl) ??
            _nonEmpty(_result?.omUrl);
    }
  }

  /// PNG officiel Orange Money (`data[qrcode]`), pas l’URL PayDunya.
  Uint8List? get _omQrPngBytes {
    final raw =
        _nonEmpty(_result?.qrImageBase64) ??
        _qrPngFromPaydunyaUrl(_result?.url);
    if (raw == null) return null;
    try {
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }

  String? _qrPngFromPaydunyaUrl(String? url) {
    final parsed = Uri.tryParse(url ?? '');
    if (parsed == null) return null;
    final qr =
        parsed.queryParameters['data[qrcode]'] ??
        parsed.queryParameters['qrcode'];
    if (qr == null || !qr.startsWith('iVBOR')) return null;
    return qr.replaceAll(RegExp(r'\s'), '');
  }

  /// Contenu à encoder en QR (Wave = lien de paiement). OM = image PNG à part.
  String? get _qrPayload {
    if (_method == 'orange_money_sn') {
      return _nonEmpty(_result?.maxitUrl) ?? _nonEmpty(_result?.omUrl);
    }
    return _nonEmpty(_result?.url) ?? _walletUrl;
  }

  bool _looksLikeImage(String url) {
    final path = (Uri.tryParse(url)?.path ?? url).toLowerCase();
    return path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.gif') ||
        path.endsWith('.webp') ||
        path.endsWith('.svg');
  }

  String get _openButtonLabel {
    switch (_method) {
      case 'wave_sn':
        return 'Ouvrir Wave';
      case 'orange_money_sn':
        return 'Ouvrir Maxit';
      case 'free_money_sn':
        return 'Ouvrir Free Money';
      default:
        return 'Ouvrir l’application';
    }
  }

  String get _methodTitle {
    switch (_method) {
      case 'wave_sn':
        return 'Wave';
      case 'orange_money_sn':
        return 'Orange Money';
      case 'free_money_sn':
        return 'Free Money';
      default:
        return 'paiement';
    }
  }

  Future<void> _openWallet() async {
    final url = _walletUrl;
    if (url == null) {
      _setError('Lien de paiement indisponible. Scannez le QR.');
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      _setError('Lien de paiement invalide. Scannez le QR.');
      return;
    }

    setState(() {
      _openingWallet = true;
      _error = null;
    });
    try {
      final https = uri.scheme == 'http' || uri.scheme == 'https';
      final ok = await launchUrl(
        uri,
        mode: https
            ? LaunchMode.externalApplication
            : LaunchMode.externalNonBrowserApplication,
      );
      if (!ok && mounted) {
        _setError(
          'Impossible d’ouvrir $_methodTitle. Scannez le QR ci-dessous.',
        );
      }
    } catch (_) {
      if (mounted) {
        _setError(
          'Impossible d’ouvrir $_methodTitle. Scannez le QR ci-dessous.',
        );
      }
    } finally {
      if (mounted) setState(() => _openingWallet = false);
    }
  }

  void _setError(String text) {
    setState(() => _error = text);
  }

  Future<String> _ensureInvoiceToken() async {
    final existing = _invoiceToken?.trim();
    if (existing != null && existing.isNotEmpty) return existing;

    final session = await widget.api.createCheckoutSession(
      offerSlug: widget.offerSlug,
      billingType: widget.billingType,
      teamId: widget.teamId,
      seats: widget.seats,
    );
    _invoiceToken = session.invoiceToken;
    return session.invoiceToken;
  }

  void _selectMethod(String method) {
    if (_loading || _isFinalizing) return;
    setState(() {
      _method = method;
      _error = null;
    });
  }

  void _startPolling() {
    _pollTimer?.cancel();
    unawaited(_pollOnce());
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      unawaited(_pollOnce());
    });
  }

  Future<void> _pollOnce() async {
    if (_paid || _pollInFlight || !mounted) return;
    final token = _invoiceToken?.trim();
    if (token == null || token.isEmpty) return;

    _pollInFlight = true;
    try {
      final confirm = await widget.api.confirmPaydunya(invoiceToken: token);
      if (!mounted || _paid) return;
      if (confirm.paid) {
        _paid = true;
        _pollTimer?.cancel();
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      // On continue de poller : l’IPN peut arriver un peu plus tard.
    } finally {
      _pollInFlight = false;
    }
  }

  Future<void> _onPay() async {
    if (_loading || _isFinalizing) return;

    final method = _method;
    if (method == null || method.isEmpty) {
      _setError('Choisissez Wave, Orange Money ou Free.');
      return;
    }

    final prenom = _prenom.text.trim();
    final nom = _nom.text.trim();
    final tel = _tel.text.trim().replaceAll(RegExp(r'\s+'), '');
    if (prenom.isEmpty || nom.isEmpty) {
      _setError('Renseignez le prénom et le nom.');
      return;
    }
    if (tel.length < 8) {
      _setError('Numéro de téléphone invalide.');
      return;
    }

    setState(() {
      _loading = true;
      _result = null;
      _error = null;
    });

    try {
      final token = await _ensureInvoiceToken();
      final result = await widget.api.softPay(
        offerSlug: widget.offerSlug,
        billingType: widget.billingType,
        invoiceToken: token,
        method: method,
        prenom: prenom,
        nom: nom,
        telephone: tel,
        email: widget.email,
        teamId: widget.teamId,
        seats: widget.seats,
      );
      if (!mounted) return;
      setState(() => _result = result);
      _startPolling();
    } on ApiException catch (e) {
      if (!mounted) return;
      _setError(e.message);
    } catch (_) {
      if (!mounted) return;
      _setError('Paiement impossible. Vérifiez la connexion et réessayez.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _fieldDecoration(String label, {String? hint}) {
    final r = BorderRadius.circular(12);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      border: OutlineInputBorder(borderRadius: r, borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: r,
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: r,
        borderSide: const BorderSide(
          color: AppColors.bleu_primaire,
          width: 1.8,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _methodTile({
    required String id,
    required String label,
    required String assetPath,
  }) {
    final selected = _method == id;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _loading ? null : () => _selectMethod(id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.fromLTRB(6, 14, 6, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? AppColors.bleu_primaire
                    : Colors.grey.shade300,
                width: selected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: selected ? 0.08 : 0.04),
                  blurRadius: selected ? 10 : 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    assetPath,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, error, stackTrace) => Container(
                      width: 40,
                      height: 40,
                      color: const Color(0xFFF3F4F6),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.payment_rounded,
                        color: Colors.grey.shade500,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade900,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _qrBlock() {
    final png = _omQrPngBytes;
    if (png != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Image.memory(png, width: 200, height: 200, fit: BoxFit.contain),
      );
    }

    final payload = _qrPayload;
    if (payload == null) {
      return Text(
        'Validez le paiement dans $_methodTitle. L’abonnement s’activera tout seul.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey.shade700, height: 1.4),
      );
    }

    if (_looksLikeImage(payload)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          payload,
          width: 220,
          height: 220,
          fit: BoxFit.contain,
          errorBuilder: (_, error, stackTrace) => _qrImage(payload),
        ),
      );
    }

    return _qrImage(payload);
  }

  Widget _qrImage(String data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: QrImageView(
        data: data,
        size: 200,
        backgroundColor: Colors.white,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
      ),
    );
  }

  List<Widget> _buildCheckoutForm() {
    return [
      Text(
        'Payer ${widget.montantLabel}',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'Choisissez votre moyen de paiement',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      ),
      const SizedBox(height: 18),
      TextField(
        controller: _prenom,
        decoration: _fieldDecoration('Prénom'),
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _nom,
        decoration: _fieldDecoration('Nom'),
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _tel,
        decoration: _fieldDecoration('Téléphone', hint: '77XXXXXXX'),
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
      ),
      const SizedBox(height: 20),
      Text(
        'Moyens de paiement',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade800,
        ),
      ),
      const SizedBox(height: 12),
      Opacity(
        opacity: _loading ? 0.55 : 1,
        child: IgnorePointer(
          ignoring: _loading,
          child: Row(
            children: [
              _methodTile(id: 'wave_sn', label: 'Wave', assetPath: _assetWave),
              const SizedBox(width: 10),
              _methodTile(
                id: 'orange_money_sn',
                label: 'OM',
                assetPath: _assetOm,
              ),
              const SizedBox(width: 10),
              _methodTile(
                id: 'free_money_sn',
                label: 'Free',
                assetPath: _assetFree,
              ),
            ],
          ),
        ),
      ),
      if (_error != null) ...[
        const SizedBox(height: 14),
        _errorBanner(_error!),
      ],
      const SizedBox(height: 20),
      FilledButton(
        onPressed: _loading ? null : _onPay,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.bleu_primaire,
          disabledBackgroundColor: AppColors.bleu_primaire.withValues(
            alpha: 0.45,
          ),
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text('Payer'),
      ),
    ];
  }

  List<Widget> _buildFinalization() {
    return [
      const Text(
        'Finalisez le paiement',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'Ouvrez $_methodTitle ou scannez le QR. L’abonnement s’activera automatiquement.',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
          height: 1.4,
        ),
      ),
      const SizedBox(height: 20),
      Center(child: _qrBlock()),
      const SizedBox(height: 10),
      Text(
        'Scannez avec $_methodTitle',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      if (_error != null) ...[
        const SizedBox(height: 14),
        _errorBanner(_error!),
      ],
      if (_walletUrl != null) ...[
        const SizedBox(height: 18),
        FilledButton(
          onPressed: _openingWallet ? null : _openWallet,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.bleu_primaire,
            disabledBackgroundColor: AppColors.bleu_primaire.withValues(
              alpha: 0.45,
            ),
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _openingWallet
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(_openButtonLabel),
        ),
      ],
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text(
            'En attente de la confirmation…',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ];
  }

  Widget _errorBanner(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFB71C1C),
          height: 1.35,
          fontSize: 13.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.92;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: SoftPaySheet.topBorderRadius,
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...(_isFinalizing
                    ? _buildFinalization()
                    : _buildCheckoutForm()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
