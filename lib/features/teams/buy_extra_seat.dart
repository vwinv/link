import 'package:flutter/material.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/features/subscriptions/services/subscriptions_api_service.dart';
import 'package:linkflutter/features/subscriptions/widgets/soft_pay_sheet.dart';
import 'package:linkflutter/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// Achète une place au-delà de celles incluses dans l’offre.
/// Retourne vrai quand la place est ajoutée.
Future<bool> buyExtraTeamSeat(
  BuildContext context, {
  required String teamId,
}) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.teamExtraSeatTitle),
      content: Text(l10n.teamExtraSeatMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.teamExtraSeatPay),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return false;

  final messenger = ScaffoldMessenger.of(context);
  final api = context.read<SubscriptionsApiService>();
  final user = context.read<AuthProvider>().user;

  try {
    final checkout = await api.checkoutExtraSeats(teamId: teamId);
    if (!context.mounted) return false;
    if (checkout.paidImmediately) return true;

    final token = checkout.invoiceToken?.trim() ?? '';
    final offerSlug = checkout.offerSlug?.trim() ?? '';
    final billingType = checkout.billingType?.trim() ?? '';
    if (token.isEmpty || offerSlug.isEmpty || billingType.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.teamMembersSeatLimitReached(0))),
      );
      return false;
    }

    final paid = await SoftPaySheet.show(
      context,
      offerSlug: offerSlug,
      billingType: billingType,
      montantLabel: '${checkout.amountFcfa} ${checkout.currency}',
      api: api,
      initialPrenom: user?.firstName ?? '',
      initialNom: user?.lastName ?? '',
      initialTelephone: user?.phone ?? '',
      email: user?.email,
      teamId: teamId,
      seats: 1,
      purpose: 'seat_upgrade',
      invoiceToken: token,
    );
    return paid == true;
  } on ApiException catch (error) {
    if (context.mounted) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    }
    return false;
  } catch (_) {
    if (context.mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.teamMembersLoadError)),
      );
    }
    return false;
  }
}
