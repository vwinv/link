import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linkflutter/config/routes/app_navigation.dart';
import 'package:linkflutter/config/routes/route_paths.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/l10n/l10n_extensions.dart';
import 'package:linkflutter/core/utils/responsive.dart';
import 'package:linkflutter/features/contacts/models/link_contact.dart';
import 'package:linkflutter/providers/contacts_provider.dart';
import 'package:provider/provider.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _searchController = TextEditingController();
  var _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadContacts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() {
    return context.read<ContactsProvider>().load();
  }

  List<LinkContact> _visibleContacts(ContactsProvider provider) {
    if (_searchQuery.isEmpty) return provider.contacts;

    return provider.contacts.where((contact) {
      final haystack = [
        contact.fullName,
        contact.subtitle,
        contact.email ?? '',
        contact.phone ?? '',
        contact.company ?? '',
        contact.jobTitle ?? '',
      ].join(' ').toLowerCase();

      return haystack.contains(_searchQuery);
    }).toList();
  }

  String _contactsCountLabel(BuildContext context, int count) {
    final l10n = context.l10n;
    if (count == 0) return l10n.contactsCountZero;
    if (count == 1) return l10n.contactsCountOne;
    return l10n.contactsCountMany(count);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = context.watch<ContactsProvider>();
    final contacts = _visibleContacts(provider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: provider.isLoading && !provider.hasLoaded
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadContacts,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    AppSpacing.lg,
                    AppSpacing.screenHorizontal,
                    AppSpacing.xl,
                  ),
                  children: [
                    Text(
                      l10n.contactsTitle,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.rs(28),
                        fontWeight: AppFontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _contactsCountLabel(context, provider.contacts.length),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: context.rs(AppFontSize.md),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _ContactsSearchField(
                      controller: _searchController,
                      hintText: l10n.contactsSearchHint,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _ScanPaperCardBanner(
                      onTap: () => context.go(RoutePaths.scan),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      l10n.contactsAll,
                      style: TextStyle(
                        color: AppColors.textTertiaire,
                        fontSize: context.rs(12),
                        fontWeight: AppFontWeight.semiBold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (contacts.isEmpty)
                      _ContactsEmptyState(
                        hasSearch: _searchQuery.isNotEmpty,
                        emptyMessage: l10n.contactsEmpty,
                        emptySearchMessage: l10n.contactsEmptySearch,
                      )
                    else
                      for (final contact in contacts) ...[
                        ContactListTile(
                          contact: contact,
                          onTap: () => openContactDetail(context, contact),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                  ],
                ),
              ),
      ),
    );
  }
}

class ContactListTile extends StatelessWidget {
  const ContactListTile({
    required this.contact,
    this.onTap,
    super.key,
  });

  final LinkContact contact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final timeLabel = contact.shortAddedAgo.isNotEmpty
        ? contact.shortAddedAgo
        : contact.addedAgo;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: contact.avatarColor,
                child: Text(
                  contact.initials,
                  style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontWeight: AppFontWeight.bold,
                    fontSize: AppFontSize.sm,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.rs(AppFontSize.md),
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                    if (contact.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        contact.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: context.rs(AppFontSize.sm),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                timeLabel,
                style: TextStyle(
                  color: AppColors.textTertiaire,
                  fontSize: context.rs(12),
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiaire,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactsSearchField extends StatelessWidget {
  const _ContactsSearchField({
    required this.controller,
    required this.hintText,
  });

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: context.rs(AppFontSize.md),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.textTertiaire,
          fontSize: context.rs(AppFontSize.md),
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.textTertiaire,
        ),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.bleu_primaire),
        ),
      ),
    );
  }
}

class _ScanPaperCardBanner extends StatelessWidget {
  const _ScanPaperCardBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppColors.bleu_clair,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.bleu_primaire,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.document_scanner_outlined,
                  color: AppColors.onPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.contactsScanPaperTitle,
                      style: TextStyle(
                        color: AppColors.bleu_primaire,
                        fontSize: context.rs(AppFontSize.md),
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.contactsScanPaperSubtitle,
                      style: TextStyle(
                        color: AppColors.bleu_primaire.withValues(alpha: 0.75),
                        fontSize: context.rs(AppFontSize.sm),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.bleu_primaire.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactsEmptyState extends StatelessWidget {
  const _ContactsEmptyState({
    required this.hasSearch,
    required this.emptyMessage,
    required this.emptySearchMessage,
  });

  final bool hasSearch;
  final String emptyMessage;
  final String emptySearchMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        hasSearch ? emptySearchMessage : emptyMessage,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: context.rs(AppFontSize.sm),
          height: 1.5,
        ),
      ),
    );
  }
}
