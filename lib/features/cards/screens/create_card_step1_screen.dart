import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/core/bootstrap/user_workspace_bootstrap.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/cards/widgets/create_card_avatar_picker.dart';
import 'package:linkflutter/features/cards/widgets/create_card_header.dart';
import 'package:linkflutter/features/cards/widgets/create_card_step_indicator.dart';
import 'package:linkflutter/providers/cards_provider.dart';
import 'package:linkflutter/providers/create_card_provider.dart';
import 'package:linkflutter/shared/widgets/link_primary_button.dart';
import 'package:linkflutter/shared/widgets/link_text_field.dart';
import 'package:linkflutter/shared/widgets/responsive_layout.dart';
import 'package:provider/provider.dart';

class CreateCardStep1Screen extends StatefulWidget {
  const CreateCardStep1Screen({super.key});

  @override
  State<CreateCardStep1Screen> createState() => _CreateCardStep1ScreenState();
}

class _CreateCardStep1ScreenState extends State<CreateCardStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _jobTitleController;
  late final TextEditingController _companyController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirectIfCardExists());
    final draft = context.read<CreateCardProvider>().draft;
    _fullNameController = TextEditingController(text: draft.fullName);
    _jobTitleController = TextEditingController(text: draft.jobTitle);
    _companyController = TextEditingController(text: draft.company);
    _emailController = TextEditingController(text: draft.email);
    _phoneController = TextEditingController(text: draft.phone);
    _fullNameController.addListener(() => setState(() {}));
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

  void _redirectIfCardExists() {
    if (!mounted) return;

    final cards = context.read<CardsProvider>();
    final createCard = context.read<CreateCardProvider>();
    if (cards.hasPersonalCard && createCard.card == null) {
      context.go(RoutePaths.home);
    }
  }

  String _initialsFromName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'XX';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;

    final createCard = context.read<CreateCardProvider>();
    createCard.updateStep1(
      fullName: _fullNameController.text.trim(),
      jobTitle: _jobTitleController.text.trim(),
      company: _companyController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    final success = await createCard.saveStep1();
    if (!mounted) return;

    if (success) {
      final card = createCard.card;
      if (card != null) {
        context.read<CardsProvider>().replaceCard(card);
        await persistUserWorkspace(context);
      }
      createCard.initSocialLinks();
      createCard.goToStep(2);
      context.go(RoutePaths.createCardStep2);
      return;
    }

    final message = createCard.errorMessage;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isSaving = context.watch<CreateCardProvider>().isSaving;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.sm,
              ),
              child: CreateCardHeader(),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: ResponsiveLayout(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.lg),
                        CreateCardStepIndicator(
                          currentStep: 1,
                          stepLabel: l10n.createCardStepInfo,
                        ),
                        SizedBox(
                          height: context.responsive(
                            mobile: AppSpacing.xxl,
                            tablet: AppSpacing.xxxl,
                          ),
                        ),
                        Text(
                          l10n.createCardYourInfoTitle,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontSize: context.rs(AppFontSize.xl),
                                fontWeight: AppFontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.createCardYourInfoSubtitle,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Center(
                          child: CreateCardAvatarPicker(
                            initials: _initialsFromName(_fullNameController.text),
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
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
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
                label: l10n.commonContinue,
                isLoading: isSaving,
                onPressed: isSaving ? null : _continue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
