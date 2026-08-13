import 'package:flutter/material.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/features/subscriptions/models/payment_config.dart';
import 'package:linkflutter/features/subscriptions/services/subscriptions_api_service.dart';
import 'package:linkflutter/features/subscriptions/widgets/soft_pay_checkout_screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// Bottom sheet SoftPay : prénom / nom / téléphone + Wave / OM / Free.
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

class _SoftPaySheetState extends State<SoftPaySheet> {
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
  bool _verifying = false;
  SoftPayResult? _result;

  @override
  void initState() {
    super.initState();
    _prenom = TextEditingController(text: widget.initialPrenom.trim());
    _nom = TextEditingController(text: widget.initialNom.trim());
    _tel = TextEditingController(text: widget.initialTelephone.trim());
    _invoiceToken = widget.invoiceToken?.trim();
  }

  @override
  void dispose() {
    _prenom.dispose();
    _nom.dispose();
    _tel.dispose();
    super.dispose();
  }

  Future<bool> _openUrl(String url, {String title = 'Paiement'}) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      _setError('Lien de paiement invalide.');
      return false;
    }

    // https → WebView in-app (évite l’erreur Safari deep link Wave sans app).
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      if (!mounted) return false;
      await SoftPayCheckoutScreen.open(context, url: url, title: title);
      return true;
    }

    try {
      final ok = await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (!ok && mounted) {
        _setError('Impossible d’ouvrir le lien de paiement.');
      }
      return ok;
    } catch (_) {
      if (mounted) {
        _setError('Impossible d’ouvrir le lien de paiement.');
      }
      return false;
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
    if (_loading || _verifying) return;
    setState(() {
      _method = method;
      _error = null;
    });
  }

  Future<void> _onPay() async {
    if (_loading || _verifying) return;

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

      // Wave / Free : url principale.
      // OM : privilégier Maxit / OM app, sinon page QR.
      final primary = method == 'orange_money_sn'
          ? (result.maxitUrl ?? result.omUrl ?? result.url)
          : (result.url?.trim().isNotEmpty == true
                ? result.url
                : (result.omUrl ?? result.maxitUrl));
      if (primary != null && primary.trim().isNotEmpty) {
        final title = switch (method) {
          'wave_sn' => 'Paiement Wave',
          'orange_money_sn' => 'Paiement Orange Money',
          _ => 'Paiement',
        };
        await _openUrl(primary.trim(), title: title);
      }
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

  Future<void> _terminer() async {
    final token = _invoiceToken?.trim();
    if (token == null || token.isEmpty) {
      _setError('Aucun paiement en cours.');
      return;
    }

    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      final confirm = await widget.api.confirmPaydunya(invoiceToken: token);
      if (!mounted) return;
      if (confirm.paid) {
        Navigator.of(context).pop(true);
        return;
      }
      _setError(
        'Paiement pas encore confirmé. Finalisez dans Wave / OM / Free puis réessayez.',
      );
    } catch (_) {
      if (!mounted) return;
      _setError('Vérification impossible pour le moment.');
    } finally {
      if (mounted) setState(() => _verifying = false);
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
          onTap: (_loading || _verifying) ? null : () => _selectMethod(id),
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

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
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
                    ignoring: _loading || _verifying,
                    child: Row(
                      children: [
                        _methodTile(
                          id: 'wave_sn',
                          label: 'Wave',
                          assetPath: _assetWave,
                        ),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: Color(0xFFB71C1C),
                        height: 1.35,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
                if (_result == null) ...[
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: (_loading || _verifying) ? null : _onPay,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.bleu_primaire,
                      disabledBackgroundColor: AppColors.bleu_primaire
                          .withValues(alpha: 0.45),
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
                ] else ...[
                  const SizedBox(height: 18),
                  Text(
                    _result!.message,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                  ),
                  if (_result!.hasLaunchableUrl) ...[
                    const SizedBox(height: 10),
                    if (_method == 'orange_money_sn') ...[
                      if ((_result!.maxitUrl ?? '').isNotEmpty)
                        OutlinedButton(
                          onPressed: () => _openUrl(_result!.maxitUrl!),
                          child: const Text('Ouvrir Maxit'),
                        ),
                      if ((_result!.omUrl ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => _openUrl(_result!.omUrl!),
                          child: const Text('Ouvrir Orange Money'),
                        ),
                      ],
                      if ((_result!.url ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => _openUrl(_result!.url!),
                          child: const Text('Voir le QR code'),
                        ),
                      ],
                    ] else
                      OutlinedButton(
                        onPressed: () {
                          final u =
                              _result!.url ??
                              _result!.omUrl ??
                              _result!.maxitUrl;
                          if (u != null) _openUrl(u);
                        },
                        child: const Text('Rouvrir le lien de paiement'),
                      ),
                  ],
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: _verifying ? null : _terminer,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.bleu_primaire,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _verifying
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('J’ai payé — Terminer'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
