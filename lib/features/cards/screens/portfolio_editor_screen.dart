import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:linkflutter/core/api/api_config.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/media/image_pick_and_crop.dart';
import 'package:linkflutter/features/cards/models/business_card.dart';
import 'package:linkflutter/features/cards/models/card_social_link.dart';
import 'package:linkflutter/features/cards/models/card_social_platform.dart';
import 'package:linkflutter/features/cards/models/portfolio_profile.dart';
import 'package:linkflutter/features/cards/models/social_link_draft.dart';
import 'package:linkflutter/features/cards/services/cards_api_service.dart';
import 'package:linkflutter/features/cards/widgets/social_network_tile.dart';
import 'package:linkflutter/features/sharing/screens/public_portfolio_screen.dart';
import 'package:linkflutter/features/uploads/services/uploads_api_service.dart';
import 'package:provider/provider.dart';

enum _PortfolioSocialSource { unset, fromCard, custom }

class PortfolioEditorScreen extends StatefulWidget {
  const PortfolioEditorScreen({
    required this.card,
    required this.layoutId,
    required this.colorId,
    super.key,
  });

  final BusinessCard card;
  final String layoutId;
  final String colorId;

  @override
  State<PortfolioEditorScreen> createState() => _PortfolioEditorScreenState();
}

class _PortfolioEditorScreenState extends State<PortfolioEditorScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _age = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _picker = ImagePickAndCrop();

  var _loading = true;
  var _saving = false;
  var _importingCv = false;
  var _exists = true;
  var _hidePersonal = false;
  String? _photoUrl;
  String? _photoPath;
  List<PortfolioExperienceItem> _experiences = [];
  List<PortfolioTeachingItem> _teachings = [];
  List<PortfolioSkillItem> _skills = [];
  List<String> _competences = [];
  List<String> _strengths = [];
  List<String> _interests = [];
  List<PortfolioWorkItem> _projects = [];
  static const _portfolioSocialPlatforms = [
    CardSocialPlatform.linkedin,
    CardSocialPlatform.instagram,
  ];
  final _socialControllers = <CardSocialPlatform, TextEditingController>{};
  List<SocialLinkDraft> _socialLinks = [
    for (final platform in _portfolioSocialPlatforms)
      SocialLinkDraft(platform: platform, isSelected: true),
  ];
  List<CardSocialLink> _cardSocialLinks = const [];
  var _socialSource = _PortfolioSocialSource.custom;
  String? _draftChip;
  final _chipDraft = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _firstName,
      _lastName,
      _age,
      _phone,
      _address,
      _title,
      _description,
    ]) {
      controller.addListener(_refresh);
    }
    for (final link in _socialLinks) {
      _socialControllers[link.platform] =
          TextEditingController(text: link.value);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final controller in [
      _firstName,
      _lastName,
      _age,
      _phone,
      _address,
      _title,
      _description,
    ]) {
      controller.removeListener(_refresh);
      controller.dispose();
    }
    _chipDraft.dispose();
    for (final controller in _socialControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _setSocialDrafts(List<SocialLinkDraft> links) {
    for (final controller in _socialControllers.values) {
      controller.dispose();
    }
    _socialControllers.clear();
    _socialLinks = links;
    for (final link in _socialLinks) {
      _socialControllers[link.platform] =
          TextEditingController(text: link.value);
    }
  }

  void _applySocialLinks(List<PortfolioSocialLinkItem> links) {
    final byPlatform = <String, String>{
      for (final item in links)
        if (item.platform.isNotEmpty && item.url.trim().isNotEmpty)
          item.platform: item.url.trim(),
    };
    _setSocialDrafts([
      for (final platform in _portfolioSocialPlatforms)
        SocialLinkDraft(
          platform: platform,
          isSelected: true,
          value: byPlatform[platform.apiValue] ?? '',
        ),
    ]);
  }

  List<SocialLinkDraft> _emptySocialDrafts() {
    return [
      for (final platform in _portfolioSocialPlatforms)
        SocialLinkDraft(platform: platform, isSelected: true),
    ];
  }

  List<SocialLinkDraft> _socialDraftsFromCard() {
    final byPlatform = <CardSocialPlatform, String>{
      for (final saved in _cardSocialLinks)
        if (saved.isConfigured) saved.platform: saved.url,
    };
    return [
      for (final platform in _portfolioSocialPlatforms)
        SocialLinkDraft(
          platform: platform,
          isSelected: true,
          value: byPlatform[platform] ?? '',
        ),
    ];
  }

  bool get _cardHasCopyableSocials => _cardSocialLinks.any(
        (link) =>
            link.isConfigured &&
            _portfolioSocialPlatforms.contains(link.platform),
      );

  void _chooseSocialSource(_PortfolioSocialSource source) {
    if (source == _PortfolioSocialSource.fromCard && !_cardHasCopyableSocials) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.portfolioEditorSocialNoCardLinks)),
      );
      return;
    }
    setState(() {
      _socialSource = source;
      if (source == _PortfolioSocialSource.fromCard) {
        _setSocialDrafts(_socialDraftsFromCard());
      } else if (source == _PortfolioSocialSource.custom) {
        _setSocialDrafts(_emptySocialDrafts());
      }
    });
  }

  List<Map<String, dynamic>> _socialLinksPayload() {
    return _socialLinks
        .where((link) => link.isSelected && link.value.trim().isNotEmpty)
        .map(
          (link) => {
            'platform': link.platform.apiValue,
            'url': link.platform.shareUrl(
              _socialControllers[link.platform]?.text.trim() ?? link.value,
            ),
          },
        )
        .where((item) => (item['url'] as String).isNotEmpty)
        .toList();
  }

  Future<void> _load() async {
    try {
      final cards = context.read<CardsApiService>();
      final profile = await cards.fetchPortfolioProfile(widget.card.id);
      if (!mounted) return;
      _apply(profile);
      setState(() => _loading = false);
      try {
        final cardLinks = await cards.fetchSocialLinks(widget.card.id);
        if (!mounted) return;
        setState(() => _cardSocialLinks = cardLinks);
      } catch (_) {
        // Les réseaux carte sont optionnels pour ouvrir l’éditeur.
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _exists = false;
        _loading = false;
      });
    }
  }

  void _apply(PortfolioProfile profile) {
    _exists = profile.exists;
    if (!profile.exists) return;
    _firstName.text = profile.firstName;
    _lastName.text = profile.lastName;
    _age.text = profile.age?.toString() ?? '';
    _phone.text = profile.phone;
    _address.text = profile.address;
    _title.text = profile.title;
    _description.text = profile.description;
    _hidePersonal = profile.hidePersonalDetails;
    _photoUrl = profile.photoUrl;
    _photoPath = null;
    _experiences = profile.experiences;
    _teachings = profile.teachings;
    _skills = profile.skills;
    _competences = profile.competences;
    _strengths = profile.strengths;
    _interests = profile.interests;
    _projects = profile.projects;
    _socialSource = _PortfolioSocialSource.custom;
    if (profile.socialLinks.isNotEmpty) {
      _applySocialLinks(profile.socialLinks);
    } else {
      _setSocialDrafts(_emptySocialDrafts());
    }
  }

  int get _percent {
    var filled = 0;
    if (_photoPath != null || (_photoUrl?.trim().isNotEmpty ?? false)) filled++;
    if (_firstName.text.trim().isNotEmpty) filled++;
    if (_lastName.text.trim().isNotEmpty) filled++;
    if (_hidePersonal || int.tryParse(_age.text.trim()) != null) filled++;
    if (_phone.text.trim().isNotEmpty) filled++;
    if (_hidePersonal || _address.text.trim().isNotEmpty) filled++;
    if (_title.text.trim().isNotEmpty) filled++;
    if (_description.text.trim().isNotEmpty) filled++;
    if (_experiences.isNotEmpty) filled++;
    if (_teachings.isNotEmpty) filled++;
    if (_skills.isNotEmpty) filled++;
    if (_competences.isNotEmpty) filled++;
    if (_strengths.isNotEmpty) filled++;
    if (_interests.isNotEmpty) filled++;
    if (_projects.isNotEmpty) filled++;
    return ((filled / 15) * 100).round();
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _pickPhoto() async {
    final path = await _picker.pickAndCrop(kind: ImageCropKind.avatar);
    if (path == null || !mounted) return;
    setState(() => _photoPath = path);
  }

  Future<void> _importCv() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.portfolioEditorImportCvConfirmTitle),
        content: Text(l10n.portfolioEditorImportCvConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.portfolioEditorImport),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final picked = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(
          label: 'PDF',
          extensions: ['pdf'],
          mimeTypes: ['application/pdf'],
          uniformTypeIdentifiers: ['com.adobe.pdf'],
        ),
      ],
    );
    final path = picked?.path;
    if (path == null || path.isEmpty) {
      if (mounted) _toast(l10n.portfolioEditorImportCvPickError);
      return;
    }
    if (!mounted) return;

    setState(() => _importingCv = true);
    try {
      final draft = await context.read<CardsApiService>().importPortfolioCv(
            cardId: widget.card.id,
            filePath: path,
          );
      if (!mounted) return;
      final keptPhotoUrl = _photoUrl;
      final keptPhotoPath = _photoPath;
      setState(() {
        _apply(draft);
        _photoUrl = keptPhotoUrl ?? draft.photoUrl;
        _photoPath = keptPhotoPath;
      });
      _toast(l10n.portfolioEditorImportCvReady);
    } on ApiException catch (error) {
      if (mounted) _toast(error.message);
    } catch (_) {
      if (mounted) _toast(context.l10n.portfolioEditorImportCvError);
    } finally {
      if (mounted) setState(() => _importingCv = false);
    }
  }

  Future<bool> _persist() async {
    final l10n = context.l10n;
    if (_firstName.text.trim().isEmpty || _lastName.text.trim().isEmpty) {
      _toast(l10n.portfolioEditorNameRequired);
      return false;
    }
    setState(() => _saving = true);
    final uploads = context.read<UploadsApiService>();
    final cards = context.read<CardsApiService>();
    try {
      var photo = _photoUrl;
      if (_photoPath != null) {
        photo = await uploads.uploadImage(_photoPath!);
      }
      final projects = <Map<String, dynamic>>[];
      for (final project in _projects) {
        var image = project.imageUrl;
        final local = project.localPath;
        if (local != null) {
          image = await uploads.uploadImage(local);
          project
            ..imageUrl = image
            ..localPath = null;
        }
        projects.add(project.toJson());
      }
      final age = int.tryParse(_age.text.trim());
      final saved = await cards.savePortfolioProfile(
            cardId: widget.card.id,
            body: {
              'photoUrl': photo,
              'firstName': _firstName.text.trim(),
              'lastName': _lastName.text.trim(),
              'age': age,
              'phone': _phone.text.trim(),
              'address': _address.text.trim(),
              'hidePersonalDetails': _hidePersonal,
              'title': _title.text.trim(),
              'description': _description.text.trim(),
              'experiences': _experiences.map((item) => item.toJson()).toList(),
              'teachings': _teachings.map((item) => item.toJson()).toList(),
              'skills': _skills.map((item) => item.toJson()).toList(),
              'competences': _competences,
              'strengths': _strengths,
              'interests': _interests,
              'socialLinks': _socialLinksPayload(),
              'projects': projects,
            },
          );
      if (!mounted) return false;
      setState(() => _apply(saved));
      return true;
    } on ApiException catch (error) {
      if (mounted) _toast(error.message);
      return false;
    } catch (_) {
      if (mounted) _toast(context.l10n.portfolioEditorSaveError);
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _preview() async {
    final ok = await _persist();
    if (!ok || !mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => PublicPortfolioScreen(
            slug: widget.card.slug,
            layout: widget.layoutId,
            color: widget.colorId,
          ),
        ),
      );
  }

  Future<void> _publish() async {
    final ok = await _persist();
    if (!ok || !mounted) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text(context.l10n.portfolioEditorPublished)),
    );
    navigator.pop();
    if (navigator.canPop()) navigator.pop();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<T?> _openSheet<T>(Widget sheet) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => sheet,
    );
  }

  Future<void> _editExperience([PortfolioExperienceItem? current]) async {
    final result = await _openSheet<_SheetResult<PortfolioExperienceItem>>(
      _ExperienceSheet(current: current),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (result.deleted && current != null) {
        _experiences = _experiences.where((item) => item.id != current.id).toList();
      } else if (result.value != null) {
        final value = result.value!;
        final index = _experiences.indexWhere((item) => item.id == value.id);
        if (index >= 0) {
          _experiences[index] = value;
        } else {
          _experiences = [..._experiences, value];
        }
      }
    });
  }

  Future<void> _editTeaching([PortfolioTeachingItem? current]) async {
    final result = await _openSheet<_SheetResult<PortfolioTeachingItem>>(
      _TeachingSheet(current: current),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (result.deleted && current != null) {
        _teachings = _teachings.where((item) => item.id != current.id).toList();
      } else if (result.value != null) {
        final value = result.value!;
        final index = _teachings.indexWhere((item) => item.id == value.id);
        if (index >= 0) {
          _teachings[index] = value;
        } else {
          _teachings = [..._teachings, value];
        }
      }
    });
  }

  Future<void> _editSkill([PortfolioSkillItem? current]) async {
    final result = await _openSheet<_SheetResult<PortfolioSkillItem>>(
      _SkillSheet(current: current),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (result.deleted && current != null) {
        _skills = _skills.where((item) => item.id != current.id).toList();
      } else if (result.value != null) {
        final value = result.value!;
        final index = _skills.indexWhere((item) => item.id == value.id);
        if (index >= 0) {
          _skills[index] = value;
        } else {
          _skills = [..._skills, value];
        }
      }
    });
  }

  List<String> _chipsFor(String key) {
    return switch (key) {
      'competences' => _competences,
      'strengths' => _strengths,
      _ => _interests,
    };
  }

  void _beginChip(String key) {
    final previous = _draftChip;
    final text = _chipDraft.text.trim();
    setState(() {
      if (previous != null && previous != key && text.isNotEmpty) {
        final list = _chipsFor(previous);
        if (!list.contains(text)) list.add(text);
      }
      _draftChip = key;
      _chipDraft.clear();
    });
  }

  void _commitChip(String key) {
    final value = _chipDraft.text.trim();
    setState(() {
      if (_draftChip == key && value.isNotEmpty) {
        final list = _chipsFor(key);
        if (!list.contains(value)) list.add(value);
      }
      if (_draftChip == key) {
        _draftChip = null;
        _chipDraft.clear();
      }
    });
  }

  Future<void> _editProject([PortfolioWorkItem? current]) async {
    if (current == null && _projects.length >= 12) return;
    final result = await _openSheet<_SheetResult<PortfolioWorkItem>>(
      _ProjectSheet(current: current),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (result.deleted && current != null) {
        _projects = _projects.where((item) => item != current).toList();
      } else if (result.value != null) {
        final value = result.value!;
        if (current == null) {
          _projects = [..._projects, value];
          return;
        }
        final index = _projects.indexOf(current);
        if (index >= 0) _projects[index] = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : !_exists
                ? _Missing(message: l10n.portfolioEditorMissing)
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                        child: Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.bleu_primaire,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              icon: const Icon(Icons.chevron_left_rounded, size: 26),
                              label: Text(l10n.commonBack),
                            ),
                            const Spacer(),
                            OutlinedButton(
                              onPressed: (_saving || _importingCv) ? null : _preview,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.bleu_primaire,
                                side: const BorderSide(color: Color(0xFFD7E4FF)),
                                shape: const StadiumBorder(),
                              ),
                              child: Text(l10n.portfolioEditorPreview),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          children: [
                            Text(
                              l10n.portfolioEditorTitle,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: LinearProgressIndicator(
                                value: _percent / 100,
                                minHeight: 6,
                                backgroundColor: const Color(0xFFE4E6EE),
                                color: AppColors.bleu_primaire,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                l10n.portfolioEditorProgress(_percent),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Heading(l10n.portfolioEditorImportCv),
                                  Text(
                                    l10n.portfolioEditorImportCvHint,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: (_saving || _importingCv)
                                          ? null
                                          : _importCv,
                                      icon: _importingCv
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.upload_file_outlined,
                                              size: 20,
                                            ),
                                      label: Text(
                                        _importingCv
                                            ? l10n.portfolioEditorImportCvLoading
                                            : l10n.portfolioEditorImportCv,
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.bleu_primaire,
                                        side: const BorderSide(
                                          color: Color(0xFFD7E4FF),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                          horizontal: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _PhotoCard(
                              title: l10n.portfolioEditorPhotoTitle,
                              hint: l10n.portfolioEditorPhotoHint,
                              changeLabel: l10n.portfolioEditorPhotoChange,
                              photoPath: _photoPath,
                              photoUrl: ApiConfig.resolvePublicAssetUrl(_photoUrl),
                              initials: widget.card.initials,
                              onChange: _pickPhoto,
                            ),
                            const SizedBox(height: 12),
                            _Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Heading(l10n.portfolioEditorPersonal),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _Field(
                                          label: l10n.portfolioEditorFirstName,
                                          controller: _firstName,
                                          textCapitalization: TextCapitalization.words,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _Field(
                                          label: l10n.portfolioEditorLastName,
                                          controller: _lastName,
                                          textCapitalization: TextCapitalization.words,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _Field(
                                          label: l10n.portfolioEditorAge,
                                          controller: _age,
                                          hint: l10n.portfolioEditorAgeHint,
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _Field(
                                          label: l10n.portfolioEditorPhone,
                                          controller: _phone,
                                          keyboardType: TextInputType.phone,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _Field(
                                    label: l10n.portfolioEditorAddress,
                                    controller: _address,
                                    hint: l10n.portfolioEditorAddressHint,
                                    textCapitalization: TextCapitalization.sentences,
                                  ),
                                  const SizedBox(height: 8),
                                  SwitchListTile.adaptive(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      l10n.portfolioEditorHidePersonal,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    value: _hidePersonal,
                                    activeThumbColor: Colors.white,
                                    activeTrackColor: AppColors.bleu_primaire,
                                    onChanged: (value) =>
                                        setState(() => _hidePersonal = value),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Heading(l10n.portfolioEditorPresentation),
                                  _Field(
                                    label: l10n.portfolioEditorPortfolioTitle,
                                    controller: _title,
                                    textCapitalization: TextCapitalization.sentences,
                                  ),
                                  const SizedBox(height: 12),
                                  _Field(
                                    label: l10n.portfolioEditorDescription,
                                    controller: _description,
                                    hint: l10n.portfolioEditorDescriptionHint,
                                    maxLines: 4,
                                    textCapitalization: TextCapitalization.sentences,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Heading(l10n.portfolioEditorSocialTitle),
                                  Text(
                                    l10n.portfolioEditorSocialSubtitle,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    l10n.portfolioEditorSocialChoice,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _SocialSourceChip(
                                          label: l10n.portfolioEditorSocialCopyCard,
                                          selected: _socialSource ==
                                              _PortfolioSocialSource.fromCard,
                                          onTap: () => _chooseSocialSource(
                                            _PortfolioSocialSource.fromCard,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _SocialSourceChip(
                                          label: l10n.portfolioEditorSocialRetype,
                                          selected: _socialSource ==
                                              _PortfolioSocialSource.custom,
                                          onTap: () => _chooseSocialSource(
                                            _PortfolioSocialSource.custom,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  for (final link in _socialLinks) ...[
                                    SocialNetworkTile(
                                      draft: link,
                                      controller:
                                          _socialControllers[link.platform] ??
                                              TextEditingController(),
                                      onToggle: (selected) {
                                        setState(() {
                                          _socialLinks = [
                                            for (final item in _socialLinks)
                                              if (item.platform == link.platform)
                                                item.copyWith(
                                                  isSelected: selected,
                                                )
                                              else
                                                item,
                                          ];
                                        });
                                      },
                                      onValueChanged: (value) {
                                        setState(() {
                                          _socialLinks = [
                                            for (final item in _socialLinks)
                                              if (item.platform == link.platform)
                                                item.copyWith(value: value)
                                              else
                                                item,
                                          ];
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _CountHeading(
                                    l10n.portfolioEditorExperience,
                                    l10n.portfolioEditorPosts(_experiences.length),
                                  ),
                                  for (final item in _experiences)
                                    _EntryTile(
                                      icon: Icons.work_outline_rounded,
                                      title: item.role,
                                      subtitle: item.subtitle,
                                      editLabel: l10n.portfolioEditorEdit,
                                      onEdit: () => _editExperience(item),
                                    ),
                                  _DashedButton(
                                    label: l10n.portfolioEditorAddExperience,
                                    onTap: () => _editExperience(
                                      PortfolioExperienceItem(id: _newId(), role: ''),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _CountHeading(
                                    l10n.portfolioEditorTeaching,
                                    l10n.portfolioEditorEntries(_teachings.length),
                                  ),
                                  for (final item in _teachings)
                                    _EntryTile(
                                      icon: Icons.school_outlined,
                                      title: item.title,
                                      subtitle: item.subtitle,
                                      editLabel: l10n.portfolioEditorEdit,
                                      onEdit: () => _editTeaching(item),
                                    ),
                                  _DashedButton(
                                    label: l10n.portfolioEditorAddTeaching,
                                    onTap: () => _editTeaching(
                                      PortfolioTeachingItem(id: _newId(), title: ''),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Heading(l10n.portfolioEditorSkills),
                                  for (final skill in _skills)
                                    _SkillRow(
                                      skill: skill,
                                      onTap: () => _editSkill(skill),
                                    ),
                                  _DashedButton(
                                    label: l10n.portfolioEditorAddSkill,
                                    onTap: () => _editSkill(
                                      PortfolioSkillItem(id: _newId(), name: '', level: 70),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _ChipCard(
                              title: l10n.portfolioEditorCompetences,
                              hint: l10n.portfolioEditorCompetencesHint,
                              values: _competences,
                              addLabel: l10n.portfolioEditorAdd,
                              draftHint: l10n.portfolioEditorNewChip,
                              drafting: _draftChip == 'competences',
                              draftController: _chipDraft,
                              onAdd: () => _beginChip('competences'),
                              onCommit: () => _commitChip('competences'),
                              onRemove: (value) =>
                                  setState(() => _competences.remove(value)),
                            ),
                            const SizedBox(height: 12),
                            _ChipCard(
                              title: l10n.portfolioEditorStrengths,
                              hint: l10n.portfolioEditorStrengthsHint,
                              values: _strengths,
                              addLabel: l10n.portfolioEditorAdd,
                              draftHint: l10n.portfolioEditorNewChip,
                              drafting: _draftChip == 'strengths',
                              draftController: _chipDraft,
                              onAdd: () => _beginChip('strengths'),
                              onCommit: () => _commitChip('strengths'),
                              onRemove: (value) =>
                                  setState(() => _strengths.remove(value)),
                            ),
                            const SizedBox(height: 12),
                            _ChipCard(
                              title: l10n.portfolioEditorInterests,
                              hint: l10n.portfolioEditorInterestsHint,
                              values: _interests,
                              addLabel: l10n.portfolioEditorAdd,
                              draftHint: l10n.portfolioEditorNewChip,
                              drafting: _draftChip == 'interests',
                              draftController: _chipDraft,
                              onAdd: () => _beginChip('interests'),
                              onCommit: () => _commitChip('interests'),
                              onRemove: (value) =>
                                  setState(() => _interests.remove(value)),
                            ),
                            const SizedBox(height: 12),
                            _Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _CountHeading(
                                    l10n.portfolioEditorProjects,
                                    '${_projects.length}/12',
                                  ),
                                  Text(
                                    l10n.portfolioEditorProjectsHint,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _projects.length + (_projects.length < 12 ? 1 : 0),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 0.82,
                                    ),
                                    itemBuilder: (context, index) {
                                      if (index >= _projects.length) {
                                        return _ImportTile(
                                          label: l10n.portfolioEditorAdd,
                                          onTap: () => _editProject(),
                                        );
                                      }
                                      final project = _projects[index];
                                      return _ProjectTile(
                                        project: project,
                                        index: index,
                                        onTap: () => _editProject(project),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                        color: const Color(0xFFF3F4F8),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: (_saving || _importingCv) ? null : _preview,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(52),
                                  foregroundColor: AppColors.textPrimary,
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: Color(0xFFE4E6EE)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(l10n.portfolioEditorPreview),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: FilledButton(
                                onPressed: (_saving || _importingCv) ? null : _publish,
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(52),
                                  backgroundColor: AppColors.bleu_primaire,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _saving
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(l10n.portfolioEditorPublish),
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

class _SheetResult<T> {
  const _SheetResult.save(this.value) : deleted = false;
  const _SheetResult.delete() : value = null, deleted = true;

  final T? value;
  final bool deleted;
}

class _Missing extends StatelessWidget {
  const _Missing({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.chevron_left_rounded),
            label: Text(context.l10n.commonBack),
          ),
          const SizedBox(height: 24),
          Text(message, style: const TextStyle(fontSize: 16, height: 1.4)),
        ],
      ),
    );
  }
}

class _SocialSourceChip extends StatelessWidget {
  const _SocialSourceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.bleu_primaire.withValues(alpha: 0.12)
                : const Color(0xFFF6F7FB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.bleu_primaire
                  : const Color(0xFFE7E8EE),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: !enabled
                  ? AppColors.textSecondary.withValues(alpha: 0.55)
                  : selected
                      ? AppColors.bleu_primaire
                      : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7E8EE)),
      ),
      child: child,
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

class _CountHeading extends StatelessWidget {
  const _CountHeading(this.title, this.count);

  final String title;
  final String count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          Text(count, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFB0B6C3)),
            filled: true,
            fillColor: const Color(0xFFF4F5F8),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.title,
    required this.hint,
    required this.changeLabel,
    required this.initials,
    required this.onChange,
    this.photoPath,
    this.photoUrl,
  });

  final String title;
  final String hint;
  final String changeLabel;
  final String initials;
  final VoidCallback onChange;
  final String? photoPath;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    ImageProvider? image;
    if (photoPath != null) {
      image = FileImage(File(photoPath!));
    } else if (photoUrl != null && photoUrl!.isNotEmpty) {
      image = NetworkImage(photoUrl!);
    }
    return _Card(
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFFE8EEF9),
            backgroundImage: image,
            child: image == null
                ? Text(
                    initials,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  hint,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.3),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onChange, child: Text(changeLabel)),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.editLabel,
    required this.onEdit,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String editLabel;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9DCE3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.bleu_primaire, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
              ],
            ),
          ),
          TextButton(onPressed: onEdit, child: Text(editLabel)),
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({required this.skill, required this.onTap});

  final PortfolioSkillItem skill;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text(skill.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                Text('${skill.level} %', style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: skill.level / 100,
                minHeight: 6,
                backgroundColor: const Color(0xFFE6E8EE),
                color: AppColors.bleu_primaire,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipCard extends StatelessWidget {
  const _ChipCard({
    required this.title,
    required this.hint,
    required this.values,
    required this.addLabel,
    required this.draftHint,
    required this.drafting,
    required this.draftController,
    required this.onAdd,
    required this.onCommit,
    required this.onRemove,
  });

  final String title;
  final String hint;
  final List<String> values;
  final String addLabel;
  final String draftHint;
  final bool drafting;
  final TextEditingController draftController;
  final VoidCallback onAdd;
  final VoidCallback onCommit;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Heading(title),
          Text(hint, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in values)
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F5F8),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: const Color(0xFFE4E6EE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(value),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => onRemove(value),
                        child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              if (drafting)
                _NewChipField(
                  controller: draftController,
                  hint: draftHint,
                  onCommit: onCommit,
                )
              else
                _DottedButton(
                  onTap: onAdd,
                  radius: 99,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, size: 18, color: AppColors.bleu_primaire),
                      const SizedBox(width: 4),
                      Text(
                        addLabel,
                        style: const TextStyle(
                          color: AppColors.bleu_primaire,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DottedButton extends StatelessWidget {
  const _DottedButton({
    required this.onTap,
    required this.child,
    required this.radius,
    this.padding = EdgeInsets.zero,
    this.expand = false,
    this.fillHeight = false,
  });

  final VoidCallback onTap;
  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final bool expand;
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DottedRRectPainter(
        radius: radius,
        color: const Color(0xFF7EB0FF),
      ),
      child: Material(
        color: const Color(0xFFF3F8FF),
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            width: expand ? double.infinity : null,
            height: fillHeight ? double.infinity : null,
            padding: padding,
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _DottedRRectPainter extends CustomPainter {
  const _DottedRRectPainter({required this.radius, required this.color});

  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final maxRadius = size.shortestSide / 2;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      Radius.circular(radius.clamp(0, maxRadius)),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    const dot = 1.5;
    const gap = 4.2;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dot), paint);
        distance += dot + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedRRectPainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.color != color;
  }
}

class _DashedButton extends StatelessWidget {
  const _DashedButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: _DottedButton(
        onTap: onTap,
        radius: 16,
        padding: const EdgeInsets.symmetric(vertical: 14),
        expand: true,
        child: Text(
          '+ $label',
          style: const TextStyle(
            color: AppColors.bleu_primaire,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ImportTile extends StatelessWidget {
  const _ImportTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _DottedButton(
      onTap: onTap,
      radius: 16,
      expand: true,
      fillHeight: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.upload_rounded, color: AppColors.bleu_primaire),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.bleu_primaire,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({
    required this.project,
    required this.index,
    required this.onTap,
  });

  final PortfolioWorkItem project;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = index.isEven
        ? [const Color(0xFF6B8CFF), const Color(0xFF3A4DCC)]
        : [const Color(0xFFFFC2AE), const Color(0xFFE88978)];
    ImageProvider? image;
    if (project.localPath != null) {
      image = FileImage(File(project.localPath!));
    } else {
      final url = ApiConfig.resolvePublicAssetUrl(project.imageUrl);
      if (url != null) image = NetworkImage(url);
    }
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                image: image == null ? null : DecorationImage(image: image, fit: BoxFit.cover),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: double.infinity,
                color: Colors.black.withValues(alpha: 0.35),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(
                  project.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewChipField extends StatefulWidget {
  const _NewChipField({
    required this.controller,
    required this.hint,
    required this.onCommit,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onCommit;

  @override
  State<_NewChipField> createState() => _NewChipFieldState();
}

class _NewChipFieldState extends State<_NewChipField> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => widget.onCommit(),
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.hint,
          hintStyle: const TextStyle(color: Color(0xFFB0B6C3)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(99),
            borderSide: const BorderSide(color: AppColors.bleu_primaire, width: 1.4),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(99),
            borderSide: const BorderSide(color: AppColors.bleu_primaire, width: 1.4),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(99),
            borderSide: const BorderSide(color: AppColors.bleu_primaire, width: 1.6),
          ),
        ),
      ),
    );
  }
}

class _AddSheetScaffold extends StatelessWidget {
  const _AddSheetScaffold({
    required this.title,
    required this.actionLabel,
    required this.onSubmit,
    required this.child,
    this.onDelete,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onSubmit;
  final Widget child;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD5D8E0),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
            if (onDelete != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onDelete,
                  child: Text(
                    l10n.portfolioEditorDelete,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ),
            ] else
              const SizedBox(height: 18),
            FilledButton(
              onPressed: onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.bleu_primaire,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperienceSheet extends StatefulWidget {
  const _ExperienceSheet({this.current});

  final PortfolioExperienceItem? current;

  @override
  State<_ExperienceSheet> createState() => _ExperienceSheetState();
}

class _ExperienceSheetState extends State<_ExperienceSheet> {
  late final TextEditingController _role;
  late final TextEditingController _company;
  late final TextEditingController _period;
  late final TextEditingController _missions;

  @override
  void initState() {
    super.initState();
    _role = TextEditingController(text: widget.current?.role ?? '');
    _company = TextEditingController(text: widget.current?.company ?? '');
    _period = TextEditingController(text: widget.current?.period ?? '');
    _missions = TextEditingController(text: widget.current?.missions ?? '');
  }

  @override
  void dispose() {
    _role.dispose();
    _company.dispose();
    _period.dispose();
    _missions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final editing = widget.current != null && widget.current!.role.isNotEmpty;
    return _AddSheetScaffold(
      title: '${editing ? l10n.portfolioEditorEdit : l10n.portfolioEditorAdd} · ${l10n.portfolioEditorExperience}',
      actionLabel: editing ? l10n.portfolioEditorSave : l10n.portfolioEditorAdd,
      onDelete: editing
          ? () => Navigator.pop(context, const _SheetResult<PortfolioExperienceItem>.delete())
          : null,
      onSubmit: () {
        final role = _role.text.trim();
        if (role.isEmpty) return;
        Navigator.pop(
          context,
          _SheetResult.save(
            PortfolioExperienceItem(
              id: widget.current?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
              role: role,
              company: _company.text.trim(),
              period: _period.text.trim(),
              missions: _missions.text.trim(),
            ),
          ),
        );
      },
      child: Column(
        children: [
          _Field(
            label: l10n.portfolioEditorPoste,
            controller: _role,
            hint: l10n.portfolioEditorPosteHint,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          _Field(
            label: l10n.portfolioEditorCompany,
            controller: _company,
            hint: l10n.portfolioEditorCompanyHint,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          _Field(
            label: l10n.portfolioEditorPeriod,
            controller: _period,
            hint: l10n.portfolioEditorPeriodExample,
          ),
          const SizedBox(height: 12),
          _Field(
            label: l10n.portfolioEditorMissions,
            controller: _missions,
            hint: l10n.portfolioEditorMissionsHint,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }
}

class _TeachingSheet extends StatefulWidget {
  const _TeachingSheet({this.current});

  final PortfolioTeachingItem? current;

  @override
  State<_TeachingSheet> createState() => _TeachingSheetState();
}

class _TeachingSheetState extends State<_TeachingSheet> {
  late final TextEditingController _title;
  late final TextEditingController _school;
  late final TextEditingController _year;
  late final TextEditingController _audience;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.current?.title ?? '');
    _school = TextEditingController(text: widget.current?.school ?? '');
    _year = TextEditingController(text: widget.current?.year ?? '');
    _audience = TextEditingController(text: widget.current?.audience ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _school.dispose();
    _year.dispose();
    _audience.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final editing = widget.current != null && widget.current!.title.isNotEmpty;
    return _AddSheetScaffold(
      title: '${editing ? l10n.portfolioEditorEdit : l10n.portfolioEditorAdd} · ${l10n.portfolioEditorTeaching}',
      actionLabel: editing ? l10n.portfolioEditorSave : l10n.portfolioEditorAdd,
      onDelete: editing
          ? () => Navigator.pop(context, const _SheetResult<PortfolioTeachingItem>.delete())
          : null,
      onSubmit: () {
        final title = _title.text.trim();
        if (title.isEmpty) return;
        Navigator.pop(
          context,
          _SheetResult.save(
            PortfolioTeachingItem(
              id: widget.current?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
              title: title,
              school: _school.text.trim(),
              year: _year.text.trim(),
              audience: _audience.text.trim(),
            ),
          ),
        );
      },
      child: Column(
        children: [
          _Field(
            label: l10n.portfolioEditorCourse,
            controller: _title,
            hint: l10n.portfolioEditorCourseHint,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          _Field(
            label: l10n.portfolioEditorSchool,
            controller: _school,
            hint: l10n.portfolioEditorSchoolHint,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          _Field(
            label: l10n.portfolioEditorYear,
            controller: _year,
            hint: l10n.portfolioEditorYearHint,
          ),
          const SizedBox(height: 12),
          _Field(
            label: l10n.portfolioEditorAudience,
            controller: _audience,
            hint: l10n.portfolioEditorAudienceHint,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }
}

class _SkillSheet extends StatefulWidget {
  const _SkillSheet({this.current});

  final PortfolioSkillItem? current;

  @override
  State<_SkillSheet> createState() => _SkillSheetState();
}

class _SkillSheetState extends State<_SkillSheet> {
  late final TextEditingController _name;
  late int _level;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.current?.name ?? '');
    _level = widget.current?.level ?? 70;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final editing = widget.current != null && widget.current!.name.isNotEmpty;
    return _AddSheetScaffold(
      title: '${editing ? l10n.portfolioEditorEdit : l10n.portfolioEditorAdd} · ${l10n.portfolioEditorSkillSheet}',
      actionLabel: editing ? l10n.portfolioEditorSave : l10n.portfolioEditorAdd,
      onDelete: editing
          ? () => Navigator.pop(context, const _SheetResult<PortfolioSkillItem>.delete())
          : null,
      onSubmit: () {
        final name = _name.text.trim();
        if (name.isEmpty) return;
        Navigator.pop(
          context,
          _SheetResult.save(
            PortfolioSkillItem(
              id: widget.current?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
              name: name,
              level: _level,
            ),
          ),
        );
      },
      child: Column(
        children: [
          _Field(
            label: l10n.portfolioEditorSkillNameLabel,
            controller: _name,
            hint: l10n.portfolioEditorSkillHint,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(l10n.portfolioEditorLevel, style: const TextStyle(color: AppColors.textSecondary)),
              const Spacer(),
              Text('$_level %', style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          Slider(
            value: _level.toDouble(),
            max: 100,
            divisions: 20,
            activeColor: AppColors.bleu_primaire,
            onChanged: (value) => setState(() => _level = value.round()),
          ),
        ],
      ),
    );
  }
}

class _ProjectSheet extends StatefulWidget {
  const _ProjectSheet({this.current});

  final PortfolioWorkItem? current;

  @override
  State<_ProjectSheet> createState() => _ProjectSheetState();
}

class _ProjectSheetState extends State<_ProjectSheet> {
  final _picker = ImagePickAndCrop();
  late final TextEditingController _title;
  late final TextEditingController _caption;
  late final TextEditingController _link;
  String? _localPath;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.current?.title ?? '');
    _caption = TextEditingController(text: widget.current?.caption ?? '');
    _link = TextEditingController(text: widget.current?.projectUrl ?? '');
    _localPath = widget.current?.localPath;
    _imageUrl = widget.current?.imageUrl;
  }

  @override
  void dispose() {
    _title.dispose();
    _caption.dispose();
    _link.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final path = await _picker.pickAndCrop(kind: ImageCropKind.logo);
    if (path == null || !mounted) return;
    setState(() => _localPath = path);
  }

  String _normalizeLink(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    return 'https://$value';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final editing = widget.current != null && widget.current!.title.trim().isNotEmpty;
    final previewUrl = _localPath == null
        ? ApiConfig.resolvePublicAssetUrl(_imageUrl)
        : null;
    return _AddSheetScaffold(
      title: '${editing ? l10n.portfolioEditorEdit : l10n.portfolioEditorAdd} · ${l10n.portfolioEditorProjects}',
      actionLabel: editing ? l10n.portfolioEditorSave : l10n.portfolioEditorAdd,
      onDelete: editing
          ? () => Navigator.pop(context, const _SheetResult<PortfolioWorkItem>.delete())
          : null,
      onSubmit: () {
        final title = _title.text.trim();
        if (title.isEmpty) return;
        Navigator.pop(
          context,
          _SheetResult.save(
            PortfolioWorkItem(
              id: widget.current?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
              title: title,
              caption: _caption.text.trim(),
              imageUrl: _localPath == null ? _imageUrl : widget.current?.imageUrl,
              localPath: _localPath,
              projectUrl: _normalizeLink(_link.text),
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Field(
            label: l10n.portfolioEditorProjectTitle,
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          _Field(
            label: l10n.portfolioEditorCaption,
            controller: _caption,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.portfolioEditorProjectPhoto,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 6),
          if (_localPath != null || previewUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: Image(
                      image: _localPath != null
                          ? FileImage(File(_localPath!))
                          : NetworkImage(previewUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() {
                          _localPath = null;
                          _imageUrl = null;
                        }),
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            _DottedButton(
              onTap: _pickPhoto,
              radius: 16,
              expand: true,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Text(
                l10n.portfolioEditorProjectPhotoAdd,
                style: const TextStyle(
                  color: AppColors.bleu_primaire,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (_localPath != null || previewUrl != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _pickPhoto,
                child: Text(l10n.portfolioEditorProjectPhotoChange),
              ),
            ),
          ],
          const SizedBox(height: 4),
          _Field(
            label: l10n.portfolioEditorProjectLink,
            controller: _link,
            hint: l10n.portfolioEditorProjectLinkHint,
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }
}
