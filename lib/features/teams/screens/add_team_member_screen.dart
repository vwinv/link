import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/teams/models/team.dart';
import 'package:linkflutter/features/teams/models/team_member.dart';
import 'package:linkflutter/features/teams/services/teams_api_service.dart';
import 'package:linkflutter/features/uploads/services/uploads_api_service.dart';
import 'package:linkflutter/shared/widgets/link_primary_button.dart';
import 'package:linkflutter/shared/widgets/link_text_field.dart';
import 'package:provider/provider.dart';

class AddTeamMemberScreen extends StatefulWidget {
  const AddTeamMemberScreen({
    required this.team,
    super.key,
    this.canAssignAdminRole = true,
  });

  final Team team;
  final bool canAssignAdminRole;

  @override
  State<AddTeamMemberScreen> createState() => _AddTeamMemberScreenState();
}

class _AddTeamMemberScreenState extends State<AddTeamMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _emailController = TextEditingController();
  final _imagePicker = ImagePicker();

  String? _avatarFilePath;
  var _isAdmin = false;
  var _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _jobTitleController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  ({String firstName, String lastName}) _splitName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return (firstName: '', lastName: '');
    }
    if (parts.length == 1) {
      return (firstName: parts.first, lastName: '');
    }
    return (firstName: parts.first, lastName: parts.sublist(1).join(' '));
  }

  String _initialsFromName(String fullName) {
    final name = _splitName(fullName);
    final first = name.firstName.trim();
    final last = name.lastName.trim();
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    if (first.isNotEmpty) {
      return first.length >= 2
          ? first.substring(0, 2).toUpperCase()
          : first[0].toUpperCase();
    }
    return '++';
  }

  Future<void> _pickAvatar() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 88,
        requestFullMetadata: false,
      );
      if (picked == null || !mounted) return;
      setState(() => _avatarFilePath = picked.path);
    } on PlatformException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.editCardGalleryError(error.message ?? error.code),
          ),
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final name = _splitName(_fullNameController.text);

    try {
      String? avatarUrl;
      if (_avatarFilePath != null) {
        avatarUrl = await context.read<UploadsApiService>().uploadImage(
          _avatarFilePath!,
        );
      }

      await context.read<TeamsApiService>().addTeamMember(
        teamId: widget.team.id,
        email: _emailController.text.trim(),
        firstName: name.firstName,
        lastName: name.lastName,
        jobTitle: _jobTitleController.text.trim(),
        avatarUrl: avatarUrl,
        role: widget.canAssignAdminRole && _isAdmin
            ? TeamMemberRole.admin
            : TeamMemberRole.member,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.teamMembersInviteSuccess)),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.teamMembersInviteError)),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final initials = _initialsFromName(_fullNameController.text);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.sm,
                AppSpacing.screenHorizontal,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  _CloseButton(onPressed: () => Navigator.of(context).pop()),
                  Expanded(
                    child: Text(
                      l10n.teamMembersAddTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: AppFontSize.lg,
                        fontWeight: AppFontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      _AvatarPicker(
                        initials: initials,
                        imagePath: _avatarFilePath,
                        onTap: _pickAvatar,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      LinkTextField(
                        label: l10n.editCardFullName,
                        controller: _fullNameController,
                        hint: l10n.teamMembersFullNameHint,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.editCardNameRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      LinkTextField(
                        label: l10n.editCardJobTitle,
                        controller: _jobTitleController,
                        hint: l10n.teamMembersJobTitleHint,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      LinkTextField(
                        label: l10n.editCardEmail,
                        controller: _emailController,
                        hint: l10n.teamMembersEmailHint,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) {
                            return l10n.editCardEmailRequired;
                          }
                          if (!email.contains('@')) {
                            return l10n.editCardEmailInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (widget.canAssignAdminRole)
                        _AdminToggleCard(
                          value: _isAdmin,
                          onChanged: (value) =>
                              setState(() => _isAdmin = value),
                        ),
                      if (widget.canAssignAdminRole)
                        const SizedBox(height: AppSpacing.xxl),
                      if (!widget.canAssignAdminRole)
                        const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.md,
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
              ),
              child: LinkPrimaryButton(
                label: l10n.teamMembersSendInvitation,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.iconBgMuted,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.close_rounded,
            color: AppColors.textPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.initials,
    required this.onTap,
    this.imagePath,
  });

  final String initials;
  final String? imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.iconBgMuted,
          shape: BoxShape.circle,
          image: hasImage
              ? DecorationImage(
                  image: FileImage(File(imagePath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        alignment: Alignment.center,
        child: hasImage
            ? null
            : Text(
                initials,
                style: TextStyle(
                  color: AppColors.textTertiaire,
                  fontSize: context.rs(28),
                  fontWeight: AppFontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
      ),
    );
  }
}

class _AdminToggleCard extends StatelessWidget {
  const _AdminToggleCard({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.teamMembersSetAdmin,
                  style: const TextStyle(
                    fontSize: AppFontSize.md,
                    fontWeight: AppFontWeight.semiBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.teamMembersSetAdminSubtitle,
                  style: TextStyle(
                    fontSize: context.rs(AppFontSize.sm),
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.onPrimary,
            activeTrackColor: AppColors.bleu_primaire,
          ),
        ],
      ),
    );
  }
}
