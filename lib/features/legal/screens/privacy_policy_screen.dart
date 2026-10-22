import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/legal/privacy_policy_content.dart';
import 'package:linkflutter/shared/widgets/link_back_button.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Future<void> _openMail() async {
    await launchUrl(
      Uri.parse('mailto:contact@mega-sn.com'),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _openSite() async {
    await launchUrl(
      Uri.parse('https://mega-sn.com'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.sm,
                AppSpacing.screenHorizontal,
                0,
              ),
              child: Row(
                children: [
                  const LinkBackButton(),
                  Expanded(
                    child: Text(
                      l10n.privacyPolicyTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.rs(AppFontSize.lg),
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                  AppSpacing.screenHorizontal,
                  AppSpacing.xxl,
                ),
                children: [
                  Text(
                    PrivacyPolicyContent.title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: context.rs(AppFontSize.xl),
                      fontWeight: AppFontWeight.bold,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    PrivacyPolicyContent.lastUpdatedLabel,
                    style: TextStyle(
                      color: AppColors.textTertiaire,
                      fontSize: context.rs(AppFontSize.sm),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  for (final section in PrivacyPolicyContent.sections) ...[
                    _SectionTitle(section.title),
                    const SizedBox(height: AppSpacing.sm),
                    for (final paragraph in section.paragraphs) ...[
                      _BodyText(paragraph),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    if (section.bullets.isNotEmpty) ...[
                      for (final bullet in section.bullets) _Bullet(bullet),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    for (final subsection in section.subsections) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        subsection.title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: context.rs(AppFontSize.md),
                          fontWeight: AppFontWeight.semiBold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      for (final paragraph in subsection.paragraphs) ...[
                        _BodyText(paragraph),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      for (final bullet in subsection.bullets) _Bullet(bullet),
                    ],
                    for (final paragraph in section.closingParagraphs) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _BodyText(paragraph),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  TextButton(
                    onPressed: _openMail,
                    child: Text(
                      'contact@mega-sn.com',
                      style: TextStyle(
                        color: AppColors.bleu_primaire,
                        fontSize: context.rs(AppFontSize.sm),
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _openSite,
                    child: Text(
                      'https://mega-sn.com',
                      style: TextStyle(
                        color: AppColors.bleu_primaire,
                        fontSize: context.rs(AppFontSize.sm),
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: context.rs(AppFontSize.lg),
        fontWeight: AppFontWeight.bold,
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: context.rs(AppFontSize.sm),
        height: 1.5,
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•  ',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: context.rs(AppFontSize.sm),
              height: 1.5,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.rs(AppFontSize.sm),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
