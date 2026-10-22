import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/core/bootstrap/user_workspace_bootstrap.dart';
import 'package:linkflutter/core/api/api_exception.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/media/image_pick_and_crop.dart';
import 'package:linkflutter/l10n/app_localizations.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/widgets/brand_color_picker_sheet.dart';
import 'package:linkflutter/features/teams/models/team.dart';
import 'package:linkflutter/features/teams/services/teams_api_service.dart';
import 'package:linkflutter/features/uploads/services/uploads_api_service.dart';
import 'package:linkflutter/providers/teams_provider.dart';
import 'package:linkflutter/shared/widgets/link_back_button.dart';
import 'package:linkflutter/shared/widgets/link_primary_button.dart';
import 'package:provider/provider.dart';

class SetupTeamScreen extends StatefulWidget {
  const SetupTeamScreen({super.key});

  @override
  State<SetupTeamScreen> createState() => _SetupTeamScreenState();
}

class _SetupTeamScreenState extends State<SetupTeamScreen> {
  static const _defaultBrandColors = [
    Color(0xFFE57373),
    Color(0xFF64B5F6),
    Color(0xFF212121),
    Color(0xFF81C784),
    Color(0xFFBA68C8),
  ];

  final _imagePickAndCrop = ImagePickAndCrop();
  final _colorScrollController = ScrollController();
  final _teamNameFocusNode = FocusNode();
  late final TextEditingController _teamNameController;
  late List<Color> _brandColors;
  String? _logoFilePath;
  String? _existingLogoUrl;
  Team? _existingTeam;
  var _selectedColorIndex = 0;
  var _isSaving = false;

  bool get _isEditingExistingTeam => _existingTeam != null;

  @override
  void initState() {
    super.initState();
    _teamNameController = TextEditingController();
    _brandColors = List<Color>.of(_defaultBrandColors);
    _teamNameFocusNode.addListener(_onTeamNameFocusChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _hydrateFromProvider();
      await _loadExistingTeam();
      if (mounted && !_isEditingExistingTeam) {
        await _focusTeamNameField();
      }
    });
  }

  void _onTeamNameFocusChanged() {
    if (mounted) {
      setState(() {});
    }
    if (_teamNameFocusNode.hasFocus) {
      _showSoftKeyboard();
    }
  }

  Future<void> _showSoftKeyboard() async {
    try {
      await SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    } catch (_) {
      // Ignoré si le canal n'est pas prêt (certains émulateurs).
    }
  }

  Future<void> _focusTeamNameField() async {
    if (!mounted) return;
    FocusScope.of(context).requestFocus(_teamNameFocusNode);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    if (!mounted || !_teamNameFocusNode.hasFocus) return;
    await _showSoftKeyboard();
  }

  void _hydrateFromProvider() {
    // Un membre invité peut créer sa propre équipe : on ne préremplit
    // qu’avec l’équipe dont il est déjà propriétaire.
    final team = context.read<TeamsProvider>().ownedTeam;
    if (team == null) return;

    setState(() {
      _existingTeam = team;
      _teamNameController.text = team.name;
      _existingLogoUrl = team.logoImageUrl;
      final brandColor = team.brandColorValue;
      if (brandColor != null) {
        _applyPickedColor(brandColor);
      }
    });
  }

  Future<void> _loadExistingTeam() async {
    final teamsProvider = context.read<TeamsProvider>();
    if (!teamsProvider.hasLoaded) {
      await teamsProvider.load();
    }
    if (!mounted) return;

    final team = teamsProvider.ownedTeam;
    if (team == null) return;

    setState(() {
      _existingTeam = team;
      _teamNameController.text = team.name;
      _existingLogoUrl = team.logoImageUrl;
      final brandColor = team.brandColorValue;
      if (brandColor != null) {
        _applyPickedColor(brandColor);
      }
    });
  }

  @override
  void dispose() {
    _teamNameFocusNode.removeListener(_onTeamNameFocusChanged);
    _teamNameController.dispose();
    _teamNameFocusNode.dispose();
    _colorScrollController.dispose();
    super.dispose();
  }

  bool _sameRgb(Color a, Color b) =>
      (a.toARGB32() & 0xFFFFFF) == (b.toARGB32() & 0xFFFFFF);

  int? _indexOfColor(Color color) {
    for (var i = 0; i < _brandColors.length; i++) {
      if (_sameRgb(_brandColors[i], color)) return i;
    }
    return null;
  }

  void _scrollToColorIndex(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_colorScrollController.hasClients) return;
      const swatchWidth = 56.0;
      const gap = AppSpacing.sm;
      final target = index * (swatchWidth + gap);
      final maxScroll = _colorScrollController.position.maxScrollExtent;
      _colorScrollController.animateTo(
        target.clamp(0, maxScroll),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _applyPickedColor(Color picked) {
    if (picked == Colors.transparent) return;

    final existingIndex = _indexOfColor(picked);
    if (existingIndex != null) {
      setState(() => _selectedColorIndex = existingIndex);
      _scrollToColorIndex(existingIndex);
      return;
    }

    setState(() {
      _brandColors.add(picked);
      _selectedColorIndex = _brandColors.length - 1;
    });
    _scrollToColorIndex(_brandColors.length - 1);
  }

  Color get _selectedColor => _brandColors[_selectedColorIndex];

  Future<void> _openColorPicker(BuildContext anchorContext) async {
    final box = anchorContext.findRenderObject()! as RenderBox;
    final anchor = box.localToGlobal(Offset.zero) & box.size;

    final picked = await showBrandColorPicker(
      context,
      anchor: anchor,
      initialColor: _selectedColor,
    );
    if (picked == null || !mounted) return;
    _applyPickedColor(picked);
  }

  String _colorToHex(Color color) {
    final value = color.toARGB32() & 0xFFFFFF;
    return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  String _teamInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'EQ';
    if (parts.length == 1) {
      return parts.first.length >= 2
          ? parts.first.substring(0, 2).toUpperCase()
          : parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _pickLogo() async {
    try {
      final path = await _imagePickAndCrop.pickAndCrop(
        kind: ImageCropKind.logo,
      );
      if (path == null || !mounted) return;
      setState(() => _logoFilePath = path);
    } on PlatformException catch (error) {
      if (!mounted) return;
      final l10n = context.l10n;
      final needsRebuild = error.code == 'channel-error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            needsRebuild
                ? l10n.setupTeamAppRestart
                : l10n.editCardGalleryError(error.message ?? error.code),
          ),
        ),
      );
    }
  }

  Future<void> _continue() async {
    final l10n = context.l10n;
    final name = _teamNameController.text.trim();
    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.setupTeamNameRequired)),
      );
      _teamNameFocusNode.requestFocus();
      await _focusTeamNameField();
      return;
    }
    if (_isSaving) return;

    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    final teamsApi = context.read<TeamsApiService>();
    final uploadsApi = context.read<UploadsApiService>();
    final teamsProvider = context.read<TeamsProvider>();

    try {
      String? logoUrl;
      if (_logoFilePath != null) {
        logoUrl = await uploadsApi.uploadImage(_logoFilePath!);
      }

      final team = await teamsApi.createTeam(
        name: name,
        logoUrl: logoUrl,
        brandColor: _colorToHex(_selectedColor),
      );

      teamsProvider.setTeam(team);
      await persistUserWorkspace(context);
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEditingExistingTeam
                ? l10n.setupTeamUpdated(team.name)
                : l10n.setupTeamCreated(team.name),
          ),
        ),
      );
      context.pop<Team>(team);
    } on ApiException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error is ApiException
                ? error.message
                : l10n.setupTeamCreateError,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildTeamNameField(AppLocalizations l10n) {
    final isFocused = _teamNameFocusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _focusTeamNameField,
          behavior: HitTestBehavior.opaque,
          child: Text(
            l10n.setupTeamNameLabel,
            style: const TextStyle(
              fontSize: AppFontSize.sm,
              fontWeight: AppFontWeight.semiBold,
              color: AppColors.textTertiaire,
              letterSpacing: 0.6,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Material(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: InkWell(
            onTap: _focusTeamNameField,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isFocused ? AppColors.bleu_primaire : AppColors.border,
                  width: isFocused ? 1.5 : 1,
                ),
              ),
              child: TextField(
                controller: _teamNameController,
                focusNode: _teamNameFocusNode,
                onTap: _focusTeamNameField,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  fontSize: AppFontSize.md,
                  fontWeight: AppFontWeight.medium,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: l10n.setupTeamNameHint,
                  hintStyle: const TextStyle(
                    color: AppColors.textTertiaire,
                    fontWeight: AppFontWeight.regular,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.lg,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                0,
              ),
              child: LinkBackButton(),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.xl,
                  AppSpacing.screenHorizontal,
                  AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C0D10),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: Color(0xFFFFB300),
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      _isEditingExistingTeam
                          ? l10n.setupTeamTitleEdit
                          : l10n.setupTeamTitleCreate,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.rs(28),
                        fontWeight: AppFontWeight.bold,
                        letterSpacing: -0.5,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _isEditingExistingTeam
                          ? l10n.setupTeamSubtitleEdit
                          : l10n.setupTeamSubtitleCreate,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: context.rs(AppFontSize.md),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildTeamNameField(l10n),
                    const SizedBox(height: AppSpacing.xl),
                      Text(
                        l10n.setupTeamLogoLabel,
                        style: const TextStyle(
                          fontSize: AppFontSize.sm,
                          fontWeight: AppFontWeight.semiBold,
                          color: AppColors.textTertiaire,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Material(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: InkWell(
                            onTap: _pickLogo,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  ClipOval(
                                    child: ValueListenableBuilder<
                                        TextEditingValue>(
                                      valueListenable: _teamNameController,
                                      builder: (context, value, _) {
                                        final name = value.text;
                                        return _logoFilePath != null
                                            ? Image.file(
                                                File(_logoFilePath!),
                                                width: 56,
                                                height: 56,
                                                fit: BoxFit.cover,
                                              )
                                            : _existingLogoUrl != null
                                                ? Image.network(
                                                    _existingLogoUrl!,
                                                    width: 56,
                                                    height: 56,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, _, _) =>
                                                        CircleAvatar(
                                                      radius: 28,
                                                      backgroundColor:
                                                          AppColors.surface,
                                                      child: Text(
                                                        _teamInitials(name),
                                                        style: TextStyle(
                                                          color:
                                                              _selectedColor,
                                                          fontSize: context.rs(
                                                            AppFontSize.lg,
                                                          ),
                                                          fontWeight:
                                                              AppFontWeight
                                                                  .bold,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : CircleAvatar(
                                                    radius: 28,
                                                    backgroundColor:
                                                        AppColors.surface,
                                                    child: Text(
                                                      _teamInitials(name),
                                                      style: TextStyle(
                                                        color: _selectedColor,
                                                        fontSize: context.rs(
                                                          AppFontSize.lg,
                                                        ),
                                                        fontWeight:
                                                            AppFontWeight.bold,
                                                      ),
                                                    ),
                                                  );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.lg),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _logoFilePath == null &&
                                                  _existingLogoUrl == null
                                              ? l10n.editCardImportLogo
                                              : l10n.editCardChangeLogo,
                                          style: TextStyle(
                                            color: AppColors.bleu_primaire,
                                            fontSize:
                                                context.rs(AppFontSize.md),
                                            fontWeight: AppFontWeight.semiBold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          l10n.editCardLogoHint,
                                          style: TextStyle(
                                            color: AppColors.textTertiaire,
                                            fontSize: context.rs(12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.image_outlined,
                                    color: AppColors.textTertiaire,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          l10n.setupTeamColorLabel,
                          style: const TextStyle(
                            fontSize: AppFontSize.sm,
                            fontWeight: AppFontWeight.semiBold,
                            color: AppColors.textTertiaire,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.setupTeamColorSubtitle,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: context.rs(12),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                controller: _colorScrollController,
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    for (
                                      var index = 0;
                                      index < _brandColors.length;
                                      index++
                                    ) ...[
                                      if (index > 0)
                                        const SizedBox(width: AppSpacing.sm),
                                      _BrandColorSwatch(
                                        color: _brandColors[index],
                                        isSelected:
                                            _selectedColorIndex == index,
                                        onTap: () => setState(
                                          () => _selectedColorIndex = index,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _BrandPaletteButton(onTap: _openColorPicker),
                          ],
                        ),
                      ],
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
                label: l10n.commonContinue,
                isLoading: _isSaving,
                onPressed: _continue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandColorSwatch extends StatelessWidget {
  const _BrandColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: isSelected
              ? Icon(
                  Icons.check_rounded,
                  color: color.computeLuminance() > 0.55
                      ? AppColors.textPrimary
                      : AppColors.onPrimary,
                  size: 24,
                )
              : null,
        ),
      ),
    );
  }
}

class _BrandPaletteButton extends StatelessWidget {
  const _BrandPaletteButton({required this.onTap});

  final void Function(BuildContext anchorContext) onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Ink(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
            gradient: const SweepGradient(
              colors: [
                Color(0xFFFF3B30),
                Color(0xFFFF9500),
                Color(0xFFFFCC00),
                Color(0xFF34C759),
                Color(0xFF007AFF),
                Color(0xFF5856D6),
                Color(0xFFFF2D55),
                Color(0xFFFF3B30),
              ],
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
