import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/auth_error_l10n.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/providers/auth_provider.dart';
import 'package:linkflutter/shared/widgets/created_by_mega.dart';
import 'package:linkflutter/shared/widgets/link_back_button.dart';
import 'package:linkflutter/shared/widgets/link_logo.dart';
import 'package:linkflutter/shared/widgets/link_primary_button.dart';
import 'package:linkflutter/shared/widgets/link_text_field.dart';
import 'package:linkflutter/shared/widgets/responsive_layout.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({this.initialEmail, super.key});

  final String? initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  var _sent = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final success = await context.read<AuthProvider>().requestPasswordReset(
      email: email,
    );
    if (!mounted) return;

    if (success) {
      setState(() => _sent = true);
      return;
    }

    final message = context.read<AuthProvider>().errorMessage;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.resolveAuthError(message))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLoading = context.watch<AuthProvider>().isLoading;
    final email = _emailController.text.trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: ResponsiveLayout(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                  const SizedBox(height: AppSpacing.lg),
                  const LinkBackButton(),
                  SizedBox(
                    height: context.responsive(
                      mobile: AppSpacing.xl,
                      tablet: AppSpacing.xxl,
                    ),
                  ),
                  LinkLogo(
                    height: context.responsive(
                      mobile: AppSizes.headerLogoHeight,
                      tablet: AppSizes.headerLogoHeight + 4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  Text(
                    l10n.authForgotPasswordTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: context.rs(AppFontSize.xxl),
                      fontWeight: AppFontWeight.bold,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _sent
                        ? l10n.authForgotPasswordSent(email)
                        : l10n.authForgotPasswordLead,
                    style: TextStyle(
                      fontSize: context.rs(AppFontSize.lg),
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  if (!_sent) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    LinkTextField(
                      label: l10n.editCardEmail,
                      controller: _emailController,
                      hint: l10n.commonEmailHint,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return l10n.authForgotPasswordEmailRequired;
                        }
                        if (!trimmed.contains('@')) {
                          return l10n.authForgotPasswordEmailInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    LinkPrimaryButton(
                      label: isLoading
                          ? l10n.authForgotPasswordSending
                          : l10n.authForgotPasswordSubmit,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                  ] else ...[
                    const SizedBox(height: AppSpacing.xxxl),
                    LinkPrimaryButton(
                      label: l10n.authForgotPasswordBackToLogin,
                      onPressed: () => context.go(RoutePaths.login),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const CreatedByMega(),
          ],
        ),
      ),
    );
  }
}
