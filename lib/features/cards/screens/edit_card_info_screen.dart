import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linkflutter/config/routes/app_navigation.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/bootstrap/user_workspace_bootstrap.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/media/image_pick_and_crop.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/models/card_draft.dart';
import 'package:linkflutter/features/cards/models/card_kind.dart';
import 'package:linkflutter/features/cards/models/card_social_link.dart';
import 'package:linkflutter/features/cards/models/card_social_platform.dart';
import 'package:linkflutter/features/cards/models/social_link_draft.dart';
import 'package:linkflutter/features/cards/services/cards_api_service.dart';
import 'package:linkflutter/features/cards/widgets/create_card_avatar_picker.dart';
import 'package:linkflutter/features/cards/widgets/social_network_tile.dart';
import 'package:linkflutter/features/uploads/services/uploads_api_service.dart';
import 'package:linkflutter/features/subscriptions/widgets/premium_unlock_banner.dart';
import 'package:linkflutter/providers/auth_provider.dart';
import 'package:linkflutter/providers/cards_provider.dart';
import 'package:linkflutter/providers/subscriptions_provider.dart';
import 'package:linkflutter/providers/teams_provider.dart';
import 'package:linkflutter/shared/widgets/link_back_button.dart';
import 'package:linkflutter/shared/widgets/link_primary_button.dart';
import 'package:linkflutter/shared/widgets/link_text_field.dart';
import 'package:provider/provider.dart';

class EditCardInfoScreen extends StatefulWidget {
  const EditCardInfoScreen({required this.card, super.key});

  final BusinessCard card;

  @override
  State<EditCardInfoScreen> createState() => _EditCardInfoScreenState();
}

class _EditCardInfoScreenState extends State<EditCardInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _jobTitleController;
  late final TextEditingController _companyController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late BusinessCard _card;
  var _isSaving = false;
  String? _logoFilePath;
  String? _existingLogoUrl;
  var _logoRemoved = false;
  String? _avatarFilePath;
  String? _existingAvatarUrl;
  var _avatarRemoved = false;
  final _imagePickAndCrop = ImagePickAndCrop();
  final _socialControllers = <CardSocialPlatform, TextEditingController>{};
  List<SocialLinkDraft> _socialLinks = const [];
  List<SocialLinkDraft> _initialSocialLinks = const [];
  var _isLoadingSocial = true;

  @override
  void initState() {
    super.initState();
    _card = widget.card;
    _syncLogoFromCard(_card);
    _syncAvatarFromCard(_card);
    _fullNameController = TextEditingController(text: _card.fullName);
    _jobTitleController = TextEditingController(text: _card.jobTitle ?? '');
    _companyController = TextEditingController(text: _card.company ?? '');
    _emailController = TextEditingController(text: _card.email ?? '');
    _phoneController = TextEditingController(text: _card.phone ?? '');
    _addressController = TextEditingController(text: _card.address ?? '');
    _fullNameController.addListener(() => setState(() {}));
    _addressController.addListener(() => setState(() {}));
    _socialLinks = SocialLinkDraft.initialDefaults(kind: _card.kind);
    _initialSocialLinks = SocialLinkDraft.initialDefaults(kind: _card.kind);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncCardsForTabs();
      _loadSocialLinks();
    });
  }

  Future<void> _syncCardsForTabs() async {
    await syncOwnedCardsForEditing(context);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _jobTitleController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    for (final controller in _socialControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSocialLinks() async {
    setState(() => _isLoadingSocial = true);

    try {
      final links = await context
          .read<CardsApiService>()
          .fetchSocialLinks(_card.id);
      if (!mounted) return;
      _applySocialLinks(_socialLinksFromApi(links));
    } catch (_) {
      if (!mounted) return;
      _applySocialLinks(SocialLinkDraft.initialDefaults(kind: _card.kind));
    } finally {
      if (mounted) setState(() => _isLoadingSocial = false);
    }
  }

  List<SocialLinkDraft> _socialLinksFromApi(List<CardSocialLink> links) {
    return SocialLinkDraft.initialDefaults(kind: _card.kind).map((draft) {
      for (final saved in links) {
        if (saved.platform == draft.platform && saved.isConfigured) {
          return draft.copyWith(isSelected: true, value: saved.url);
        }
      }
      if (draft.platform == CardSocialPlatform.website) {
        final site = _card.website?.trim() ?? '';
        if (site.isNotEmpty) {
          return draft.copyWith(isSelected: true, value: site);
        }
      }
      return draft;
    }).toList();
  }

  void _applySocialLinks(List<SocialLinkDraft> links) {
    for (final controller in _socialControllers.values) {
      controller.dispose();
    }
    _socialControllers.clear();

    for (final link in links) {
      _socialControllers[link.platform] =
          TextEditingController(text: link.value);
    }

    _socialLinks = links;
    _initialSocialLinks = links
        .map((link) => link.copyWith())
        .toList(growable: false);
  }

  List<SocialLinkDraft> get _currentSocialLinks {
    return _socialLinks
        .map(
          (link) => link.copyWith(
            value: _socialControllers[link.platform]?.text.trim() ?? '',
          ),
        )
        .toList(growable: false);
  }

  bool _socialLinksEqual(List<SocialLinkDraft> a, List<SocialLinkDraft> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].platform != b[i].platform) return false;
      if (a[i].isSelected != b[i].isSelected) return false;
      if (a[i].value.trim() != b[i].value.trim()) return false;
    }
    return true;
  }

  void _toggleSocialLink(CardSocialPlatform platform, bool selected) {
    setState(() {
      _socialLinks = _socialLinks
          .map(
            (link) => link.platform == platform
                ? link.copyWith(isSelected: selected)
                : link,
          )
          .toList(growable: false);
    });
  }

  void _updateSocialLinkValue(CardSocialPlatform platform, String value) {
    setState(() {
      _socialLinks = _socialLinks
          .map(
            (link) => link.platform == platform
                ? link.copyWith(value: value)
                : link,
          )
          .toList(growable: false);
    });
  }

  List<Map<String, dynamic>> _socialLinksPayload() {
    return _currentSocialLinks
        .where((link) => link.isSelected && link.value.trim().isNotEmpty)
        .toList()
        .asMap()
        .entries
        .map(
          (entry) => {
            'platform': entry.value.platform.apiValue,
            'url': entry.value.platform == CardSocialPlatform.website
                ? CardSocialPlatformX.normalizeWebsiteUrl(entry.value.value)
                : entry.value.value.trim(),
            'order': entry.key,
          },
        )
        .toList();
  }

  String? _websitePayload() {
    if (!_card.kind.isTeamLinked) return null;
    for (final link in _currentSocialLinks) {
      if (link.platform != CardSocialPlatform.website) continue;
      if (!link.isSelected || link.value.trim().isEmpty) return '';
      return CardSocialPlatformX.normalizeWebsiteUrl(link.value);
    }
    return '';
  }

  String _initialsFromName(String fullName) {
    return CardDraft(fullName: fullName).initials;
  }

  String _companyInitials() {
    final company = _companyController.text.trim();
    if (company.isEmpty) {
      return _card.companyInitials ?? 'EQ';
    }
    final parts = company.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.length >= 2
          ? parts.first.substring(0, 2).toUpperCase()
          : parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void _syncLogoFromCard(BusinessCard card) {
    _logoFilePath = null;
    _logoRemoved = false;
    _existingLogoUrl = card.logoImageUrl;
  }

  void _syncAvatarFromCard(BusinessCard card) {
    _avatarFilePath = null;
    _avatarRemoved = false;
    _existingAvatarUrl = card.avatarImageUrl;
  }

  String? _displayAvatarUrl() {
    if (_avatarFilePath != null || _avatarRemoved) return null;
    return _existingAvatarUrl;
  }

  String? _displayLogoUrl(BuildContext context) {
    if (_logoFilePath != null || _logoRemoved) return null;
    final cardLogo = _existingLogoUrl;
    if (cardLogo != null && cardLogo.isNotEmpty) return cardLogo;
    return context.read<TeamsProvider>().myTeam?.logoImageUrl;
  }

  bool get _hasAvatarChanges {
    if (_avatarFilePath != null) return true;
    if (_avatarRemoved && (_card.avatarUrl?.trim().isNotEmpty ?? false)) {
      return true;
    }
    return false;
  }

  bool get _hasLogoChanges {
    if (!_card.kind.isProfessional) return false;
    if (_logoFilePath != null) return true;
    if (_logoRemoved && (_card.logoUrl?.trim().isNotEmpty ?? false)) {
      return true;
    }
    return false;
  }

  bool get _canEditSocial {
    final team = context.read<TeamsProvider>().teamById(_card.teamId);
    return context
        .read<SubscriptionsProvider>()
        .canEditSocialLinksFor(_card, team: team);
  }

  bool get _hasChanges {
    final draft = _buildDraft();
    final name = draft.splitName;

    return name.firstName != _card.firstName ||
        name.lastName != _card.lastName ||
        draft.jobTitle.trim() != (_card.jobTitle?.trim() ?? '') ||
        draft.company.trim() != (_card.company?.trim() ?? '') ||
        draft.email.trim() != (_card.email?.trim() ?? '') ||
        draft.phone.trim() != (_card.phone?.trim() ?? '') ||
        (_card.kind.isTeamLinked &&
            _addressController.text.trim() != (_card.address?.trim() ?? '')) ||
        _hasAvatarChanges ||
        _hasLogoChanges ||
        (_canEditSocial &&
            !_socialLinksEqual(_currentSocialLinks, _initialSocialLinks));
  }

  CardDraft _buildDraft() {
    return CardDraft(
      fullName: _fullNameController.text.trim(),
      jobTitle: _jobTitleController.text.trim(),
      company: _companyController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isSaving || !_hasChanges) return;

    final draft = _buildDraft();
    final name = draft.splitName;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isSaving = true);

    try {
      String? logoUrl;
      var includeLogo = false;
      String? avatarUrl;
      var includeAvatar = false;

      if (_hasAvatarChanges) {
        includeAvatar = true;
        if (_avatarRemoved) {
          avatarUrl = '';
        } else if (_avatarFilePath != null) {
          avatarUrl = await context
              .read<UploadsApiService>()
              .uploadImage(_avatarFilePath!);
        }
      }

      if (_card.kind.isProfessional && _hasLogoChanges) {
        includeLogo = true;
        if (_logoRemoved) {
          logoUrl = '';
        } else if (_logoFilePath != null) {
          logoUrl =
              await context.read<UploadsApiService>().uploadImage(_logoFilePath!);
        }
      }

      final updated = await context.read<CardsApiService>().updateCard(
            _card.id,
            firstName: name.firstName,
            lastName: name.lastName,
            jobTitle: draft.jobTitle.isEmpty ? null : draft.jobTitle,
            company: draft.company.isEmpty ? null : draft.company,
            email: draft.email.isEmpty ? null : draft.email,
            phone: draft.phone.isEmpty ? null : draft.phone,
            address: _card.kind.isTeamLinked
                ? _addressController.text.trim()
                : null,
            includeAddress: _card.kind.isTeamLinked,
            website: _websitePayload(),
            includeWebsite: _card.kind.isTeamLinked,
            avatarUrl: avatarUrl,
            includeAvatar: includeAvatar,
            logoUrl: logoUrl,
            includeLogo: includeLogo,
          );

      if (_canEditSocial) {
        await context.read<CardsApiService>().syncSocialLinks(
              _card.id,
              _socialLinksPayload(),
            );
      }

      if (!mounted) return;

      context.read<CardsProvider>().replaceCard(updated);
      await context.read<AuthProvider>().updateLocalProfile(
            firstName: updated.firstName,
            lastName: updated.lastName,
            email: updated.email,
            phone: updated.phone,
          );
      await persistUserWorkspace(context);

      if (!mounted) return;
      navigator.pop(updated);
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.editCardSaved)),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.editCardSaveError)),
      );
    }
  }

  void _switchCard(CardKind kind) {
    final cards = context.read<CardsProvider>();
    final teams = context.read<TeamsProvider>();
    final BusinessCard? next = kind == CardKind.member
        ? cards.memberCard(teamId: teams.memberTeam?.id)
        : cards.cardForKind(kind);
    if (next == null || next.id == _card.id) return;

    setState(() {
      _card = next;
      _fullNameController.text = next.fullName;
      _jobTitleController.text = next.jobTitle ?? '';
      _companyController.text = next.company ?? '';
      _emailController.text = next.email ?? '';
      _phoneController.text = next.phone ?? '';
      _addressController.text = next.address ?? '';
      _syncLogoFromCard(next);
      _syncAvatarFromCard(next);
      _isLoadingSocial = true;
    });

    _loadSocialLinks();
  }

  Future<void> _pickAvatar() async {
    try {
      final path = await _imagePickAndCrop.pickAndCrop(
        kind: ImageCropKind.avatar,
      );
      if (path == null || !mounted) return;
      setState(() {
        _avatarFilePath = path;
        _avatarRemoved = false;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible d’ouvrir la galerie : ${error.message ?? error.code}',
          ),
        ),
      );
    }
  }

  void _removeAvatar() {
    setState(() {
      _avatarFilePath = null;
      _avatarRemoved = true;
    });
  }

  Future<void> _pickLogo() async {
    try {
      final path = await _imagePickAndCrop.pickAndCrop(
        kind: ImageCropKind.logo,
      );
      if (path == null || !mounted) return;
      setState(() {
        _logoFilePath = path;
        _logoRemoved = false;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible d’ouvrir la galerie : ${error.message ?? error.code}',
          ),
        ),
      );
    }
  }

  void _removeLogo() {
    setState(() {
      _logoFilePath = null;
      _logoRemoved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cardsProvider = context.watch<CardsProvider>();
    final teamsProvider = context.watch<TeamsProvider>();
    final kindSet = <CardKind>{
      for (final card in cardsProvider.cards) card.kind,
      _card.kind,
    };
    final availableKinds = <CardKind>[
      if (kindSet.contains(CardKind.personal)) CardKind.personal,
      if (kindSet.contains(CardKind.professional)) CardKind.professional,
      if (kindSet.contains(CardKind.member) &&
          (teamsProvider.canAccessMemberSpace ||
              cardsProvider.hasMemberCard))
        CardKind.member,
    ];
    final showScopeToggle = availableKinds.length >= 2;

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
                  const Spacer(),
                  Text(
                    switch (_card.kind) {
                      CardKind.professional => l10n.cardScopeProfessionalShort,
                      CardKind.member => l10n.cardScopeMemberShort,
                      CardKind.personal => l10n.cardScopePersonalShort,
                    },
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: context.rs(AppFontSize.sm),
                      fontWeight: AppFontWeight.medium,
                    ),
                  ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.editCardTitle,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: context.rs(28),
                          fontWeight: AppFontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.editCardSubtitle,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: context.rs(AppFontSize.md),
                        ),
                      ),
                      if (showScopeToggle) ...[
                        const SizedBox(height: AppSpacing.lg),
                        _CardKindToggle(
                          selected: _card.kind,
                          kinds: availableKinds,
                          labelFor: (kind) => switch (kind) {
                            CardKind.personal => l10n.cardScopePersonal,
                            CardKind.professional =>
                              l10n.cardScopeProfessional,
                            CardKind.member => l10n.cardScopeMember,
                          },
                          onChanged: _switchCard,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxl),
                      Center(
                        child: CreateCardAvatarPicker(
                          initials: _initialsFromName(_fullNameController.text),
                          imageFilePath: _avatarFilePath,
                          imageUrl: _displayAvatarUrl(),
                          onAddPressed: _pickAvatar,
                          onRemove: (_avatarFilePath != null ||
                                  _displayAvatarUrl() != null)
                              ? _removeAvatar
                              : null,
                          removeLabel: l10n.editCardRemovePhoto,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      LinkTextField(
                        label: l10n.editCardFullName,
                        controller: _fullNameController,
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
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      LinkTextField(
                        label: l10n.editCardCompany,
                        controller: _companyController,
                        textCapitalization: TextCapitalization.words,
                      ),
                      if (_card.kind.isProfessional) ...[
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          l10n.editCardCompanyLogo,
                          style: const TextStyle(
                            fontSize: AppFontSize.sm,
                            fontWeight: AppFontWeight.semiBold,
                            color: AppColors.textTertiaire,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _CompanyLogoPicker(
                          logoFilePath: _logoFilePath,
                          logoUrl: _displayLogoUrl(context),
                          initials: _companyInitials(),
                          changeLabel: l10n.editCardChangeLogo,
                          importLabel: l10n.editCardImportLogo,
                          hintLabel: l10n.editCardLogoHint,
                          removeLabel: l10n.editCardRemoveLogo,
                          onPick: _pickLogo,
                          onRemove: (_logoFilePath != null ||
                                  _displayLogoUrl(context) != null)
                              ? _removeLogo
                              : null,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      LinkTextField(
                        label: l10n.editCardEmail,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.editCardEmailRequired;
                          }
                          if (!value.contains('@')) {
                            return l10n.editCardEmailInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      LinkTextField(
                        label: l10n.editCardPhone,
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      if (_card.kind.isTeamLinked) ...[
                        const SizedBox(height: AppSpacing.lg),
                        LinkTextField(
                          label: l10n.editCardAddress,
                          controller: _addressController,
                          keyboardType: TextInputType.streetAddress,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        l10n.editCardSocialTitle,
                        style: const TextStyle(
                          fontSize: AppFontSize.sm,
                          fontWeight: AppFontWeight.semiBold,
                          color: AppColors.textTertiaire,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.editCardSocialSubtitle,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: context.rs(AppFontSize.md),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (!_canEditSocial)
                        _SocialPremiumLock(
                          onUnlock: () => openLinkPremium(context),
                        )
                      else if (_isLoadingSocial)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        ..._socialLinks.map((link) {
                          final controller = _socialControllers[link.platform]!;

                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            child: SocialNetworkTile(
                              draft: link,
                              controller: controller,
                              onToggle: (selected) =>
                                  _toggleSocialLink(link.platform, selected),
                              onValueChanged: (value) =>
                                  _updateSocialLinkValue(link.platform, value),
                            ),
                          );
                        }),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                0,
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
              ),
              child: LinkPrimaryButton(
                label: l10n.commonSave,
                isLoading: _isSaving,
                onPressed: (_isSaving || !_hasChanges) ? null : _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialPremiumLock extends StatelessWidget {
  const _SocialPremiumLock({required this.onUnlock});

  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PremiumUnlockBanner(
      title: l10n.premiumSocialUnlock,
      subtitle: l10n.premiumSeeOffers,
      onTap: onUnlock,
    );
  }
}

class _CardKindToggle extends StatelessWidget {
  const _CardKindToggle({
    required this.selected,
    required this.kinds,
    required this.labelFor,
    required this.onChanged,
  });

  final CardKind selected;
  final List<CardKind> kinds;
  final String Function(CardKind) labelFor;
  final ValueChanged<CardKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        children: [
          for (final kind in kinds)
            Expanded(
              child: _ToggleChip(
                label: labelFor(kind),
                isSelected: selected == kind,
                onTap: () => onChanged(kind),
              ),
            ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.surface : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontSize: context.rs(AppFontSize.sm),
              fontWeight:
                  isSelected ? AppFontWeight.semiBold : AppFontWeight.medium,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompanyLogoPicker extends StatelessWidget {
  const _CompanyLogoPicker({
    required this.logoFilePath,
    required this.logoUrl,
    required this.initials,
    required this.changeLabel,
    required this.importLabel,
    required this.hintLabel,
    required this.removeLabel,
    required this.onPick,
    this.onRemove,
  });

  final String? logoFilePath;
  final String? logoUrl;
  final String initials;
  final String changeLabel;
  final String importLabel;
  final String hintLabel;
  final String removeLabel;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  bool get _hasLogo =>
      logoFilePath != null || (logoUrl != null && logoUrl!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.inputFill,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: logoFilePath != null
                    ? Image.file(
                        File(logoFilePath!),
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      )
                    : _hasLogo
                        ? Image.network(
                            logoUrl!,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _LogoPlaceholder(
                              initials: initials,
                            ),
                          )
                        : _LogoPlaceholder(initials: initials),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasLogo ? changeLabel : importLabel,
                      style: TextStyle(
                        color: AppColors.bleu_primaire,
                        fontSize: context.rs(AppFontSize.md),
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hintLabel,
                      style: TextStyle(
                        color: AppColors.textTertiaire,
                        fontSize: context.rs(12),
                      ),
                    ),
                    if (onRemove != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      GestureDetector(
                        onTap: onRemove,
                        child: Text(
                          removeLabel,
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: context.rs(12),
                            fontWeight: AppFontWeight.medium,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiaire,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      color: AppColors.surface,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.bleu_primaire,
          fontSize: context.rs(AppFontSize.lg),
          fontWeight: AppFontWeight.bold,
        ),
      ),
    );
  }
}
