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
import 'package:linkflutter/shared/widgets/link_back_button.dart';
import 'package:linkflutter/shared/widgets/link_logo.dart';
import 'package:linkflutter/shared/widgets/link_primary_button.dart';
import 'package:linkflutter/shared/widgets/link_social_button.dart';
import 'package:linkflutter/shared/widgets/link_text_field.dart';
import 'package:linkflutter/shared/widgets/responsive_layout.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool get _showAppleSignIn => !kIsWeb && Platform.isIOS;

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _referralCodeController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  ({String firstName, String lastName}) _splitFullName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return (firstName: '', lastName: '');
    }
    if (parts.length == 1) {
      return (firstName: parts.first, lastName: parts.first);
    }
    return (firstName: parts.first, lastName: parts.sublist(1).join(' '));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _splitFullName(_fullNameController.text);
    final success = await context.read<AuthProvider>().register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: name.firstName,
          lastName: name.lastName,
          referralCode: _referralCodeController.text.trim(),
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
                  const LinkBackButton(),
                  SizedBox(
                    height: context.responsive(
                      mobile: AppSpacing.lg,
                      tablet: AppSpacing.xl,
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
                    l10n.authRegisterTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: context.rs(AppFontSize.xxl),
                          fontWeight: AppFontWeight.bold,
                          letterSpacing: -0.5,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.authRegisterSubtitle,
                    style: TextStyle(
                      fontSize: context.rs(AppFontSize.lg),
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  LinkTextField(
                    label: l10n.referralCodeFieldLabel,
                    controller: _referralCodeController,
                    hint: l10n.referralEnterCodeHint,
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (_showAppleSignIn) ...[
                    LinkSocialButton(
                      type: SocialButtonType.apple,
                      label: l10n.authContinueApple,
                      onPressed: isLoading
                          ? () {}
                          : () => handleOAuthSignIn(
                                context,
                                () => context
                                    .read<AuthProvider>()
                                    .signInWithApple(
                                      referralCode:
                                          _referralCodeController.text.trim(),
                                    ),
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
                              () => context
                                  .read<AuthProvider>()
                                  .signInWithGoogle(
                                    referralCode:
                                        _referralCodeController.text.trim(),
                                  ),
                            ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const LinkAuthDivider(),
                  const SizedBox(height: AppSpacing.xxl),
                  LinkTextField(
                    label: l10n.editCardFullName,
                    controller: _fullNameController,
                    hint: l10n.commonNameHint,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.authFullNameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
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
                      if (value == null || value.length < 8) {
                        return l10n.authPasswordMinLength;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  LinkPrimaryButton(
                    label: l10n.authCreateMyAccount,
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
                          l10n.commonAlreadyAccount,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: context.rs(AppFontSize.lg),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go(RoutePaths.login),
                          child: Text(
                            l10n.authSignIn,
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
