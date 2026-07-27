import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/config/routes/app_navigation.dart';
import 'package:linkflutter/core/l10n/auth_error_l10n.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/providers/auth_provider.dart';
import 'package:provider/provider.dart';

Future<void> handleOAuthSignIn(
  BuildContext context,
  Future<bool> Function() signIn,
) async {
  final success = await signIn();
  if (!context.mounted) return;

  if (success) {
    final returnTo = GoRouterState.of(context).uri.queryParameters['return'];
    await completePostAuthNavigation(context, returnTo: returnTo);
    return;
  }

  final message = context.read<AuthProvider>().errorMessage;
  if (message != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.resolveAuthError(message))),
    );
  }
}
