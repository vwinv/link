import 'dart:io';

import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/scan/models/scan_contact_draft.dart';
import 'package:linkflutter/shared/widgets/link_text_field.dart';

Future<ScanContactDraft?> showScanReviewSheet(
  BuildContext context, {
  required ScanContactDraft draft,
  required String imagePath,
}) {
  return showModalBottomSheet<ScanContactDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (context) => _ScanReviewSheet(
      draft: draft,
      imagePath: imagePath,
    ),
  );
}

class _ScanReviewSheet extends StatefulWidget {
  const _ScanReviewSheet({
    required this.draft,
    required this.imagePath,
  });

  final ScanContactDraft draft;
  final String imagePath;

  @override
  State<_ScanReviewSheet> createState() => _ScanReviewSheetState();
}

class _ScanReviewSheetState extends State<_ScanReviewSheet> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _jobTitleController;
  late final TextEditingController _companyController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.draft.fullName);
    _jobTitleController = TextEditingController(text: widget.draft.jobTitle ?? '');
    _companyController = TextEditingController(text: widget.draft.company ?? '');
    _emailController = TextEditingController(text: widget.draft.email ?? '');
    _phoneController = TextEditingController(text: widget.draft.phone ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _jobTitleController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  ScanContactDraft _buildDraft() {
    final nameParts = _splitFullName(_fullNameController.text);
    return widget.draft.copyWith(
      firstName: nameParts.$1,
      lastName: nameParts.$2,
      jobTitle: _jobTitleController.text.trim(),
      company: _companyController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );
  }

  (String, String) _splitFullName(String value) {
    final cleaned = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) {
      return ('', '');
    }
    final parts = cleaned.split(' ');
    if (parts.length == 1) {
      return (parts.first, '');
    }
    return (parts.first, parts.sublist(1).join(' '));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
        AppSpacing.screenHorizontal,
        AppSpacing.lg + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.scanReviewTitle,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: context.rs(20),
                fontWeight: AppFontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.scanReviewSubtitle,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.rs(AppFontSize.sm),
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Semantics(
                  excludeSemantics: true,
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            LinkTextField(
              controller: _fullNameController,
              label: l10n.scanReviewName,
            ),
            const SizedBox(height: AppSpacing.md),
            LinkTextField(
              controller: _jobTitleController,
              label: l10n.scanReviewJobTitle,
            ),
            const SizedBox(height: AppSpacing.md),
            LinkTextField(
              controller: _companyController,
              label: l10n.scanReviewCompany,
            ),
            const SizedBox(height: AppSpacing.md),
            LinkTextField(
              controller: _emailController,
              label: l10n.scanReviewEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.md),
            LinkTextField(
              controller: _phoneController,
              label: l10n.scanReviewPhone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.commonCancel),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(_buildDraft());
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.bleu_primaire,
                    ),
                    child: Text(l10n.scanReviewSave),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
