import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/auth_error_l10n.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/auth/utils/social_sign_in_helper.dart';
import 'package:linkflutter/config/routes/app_navigation.dart';
import 'package:linkflutter/providers/auth_provider.dart';
import 'package:linkflutter/shared/widgets/created_by_mega.dart';
import 'package:linkflutter/shared/widgets/link_auth_divider.dart';
import 'package:linkflutter/shared/widgets/link_logo.dart';
import 'package:linkflutter/shared/widgets/link_primary_button.dart';
import 'package:linkflutter/shared/widgets/link_social_button.dart';
import 'package:linkflutter/shared/widgets/link_text_field.dart';
import 'package:linkflutter/shared/widgets/responsive_layout.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool get _showAppleSignIn => !kIsWeb && Platform.isIOS;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<AuthProvider>().login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

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

  void _onForgotPassword() {
    final email = _emailController.text.trim();
    final path = email.isEmpty
        ? RoutePaths.forgotPassword
        : '${RoutePaths.forgotPassword}?email=${Uri.encodeQueryComponent(email)}';
    context.push(path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveLayout(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  SizedBox(
                    height: context.responsive(
                      mobile: AppSpacing.xxxl,
                      tablet: 40,
                    ),
                  ),
                  Text(
                    l10n.authLoginTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: context.rs(AppFontSize.xxl),
                          fontWeight: AppFontWeight.bold,
                          letterSpacing: -0.5,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.authLoginSubtitle,
                    style: TextStyle(
                      fontSize: context.rs(AppFontSize.lg),
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  if (_showAppleSignIn) ...[
                    LinkSocialButton(
                      type: SocialButtonType.apple,
                      label: l10n.authContinueApple,
                      onPressed: isLoading
                          ? () {}
                          : () => handleOAuthSignIn(
                                context,
                                context.read<AuthProvider>().signInWithApple,
                              ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  LinkSocialButton(
                    type: SocialButtonType.google,
                    label: l10n.authContinueGoogle,
                    onPressed: isLoading
                        ? () {}
                        : () => handleOAuthSignIn(
                              context,
                              context.read<AuthProvider>().signInWithGoogle,
                            ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const LinkAuthDivider(),
                  const SizedBox(height: AppSpacing.xxl),
                  LinkTextField(
                    label: l10n.editCardEmail,
                    controller: _emailController,
                    hint: l10n.commonEmailHint,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.editCardEmailRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  LinkTextField(
                    label: l10n.authPassword,
                    controller: _passwordController,
                    hint: l10n.commonPasswordHint,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.authPasswordRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: isLoading ? null : _onForgotPassword,
                      child: Text(
                        l10n.authForgotPassword,
                        style: TextStyle(
                          color: AppColors.bleu_primaire,
                          fontSize: context.rs(AppFontSize.md),
                          fontWeight: AppFontWeight.medium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  LinkPrimaryButton(
                    label: l10n.authSignIn,
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          l10n.commonNoAccount,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: context.rs(AppFontSize.lg),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go(RoutePaths.accountType),
                          child: Text(
                            l10n.authCreateAccount,
                            style: TextStyle(
                              color: AppColors.bleu_primaire,
                              fontSize: context.rs(AppFontSize.lg),
                              fontWeight: AppFontWeight.semiBold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const CreatedByMega(),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
