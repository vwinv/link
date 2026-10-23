import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';

class PortfolioPreviewSkill {
  const PortfolioPreviewSkill(this.label, this.progress);

  final String label;
  final double progress;
}

/// Cadre d’aperçu du portfolio sur l’accueil.
/// Sans slug, c’est l’illustration. Avec un slug, le même cadre montre le portfolio.
class PortfolioHomePreview extends StatelessWidget {
  const PortfolioHomePreview({
    this.slug,
    this.name = 'Xxxxxx Xxxxxx',
    this.role = 'Xxxxxx xxxxxx\n& xxxxxxxxxx',
    this.photoUrl,
    this.journeyTitle = 'Xxxxxx xxxxxx...',
    this.journeyMeta = 'Xxxxxx · xxxx – xxxxxx...',
    this.skills = const [
      PortfolioPreviewSkill('Xxxxxx xxxxxx', 0.92),
      PortfolioPreviewSkill('Xxxxxx xxxxxx', 0.78),
      PortfolioPreviewSkill('Xxxxxx xxxxxx', 0.55),
    ],
    super.key,
  });

  final String? slug;
  final String name;
  final String role;
  final String? photoUrl;
  final String? journeyTitle;
  final String? journeyMeta;
  final List<PortfolioPreviewSkill> skills;

  bool get _placeholder => slug == null;

  @override
  Widget build(BuildContext context) {
    final host = _placeholder ? 'dropone.me/xxxxxx' : 'dropone.me/$slug';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C1B33).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BrowserBar(host: host),
          _PreviewCanvas(
            placeholder: _placeholder,
            name: name,
            role: role,
            photoUrl: photoUrl,
            journeyTitle: _placeholder ? journeyTitle : _blankToNull(journeyTitle),
            journeyMeta: _placeholder ? journeyMeta : _blankToNull(journeyMeta),
            skills: skills,
          ),
        ],
      ),
    );
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _BrowserBar extends StatelessWidget {
  const _BrowserBar({required this.host});

  final String host;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          const _WindowDots(),
          const SizedBox(width: 8),
          Expanded(child: _UrlBar(host: host)),
        ],
      ),
    );
  }
}

class _WindowDots extends StatelessWidget {
  const _WindowDots();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _Dot(Color(0xFFFF5F57)),
        SizedBox(width: 5),
        _Dot(Color(0xFFFEBC2E)),
        SizedBox(width: 5),
        _Dot(Color(0xFF28C840)),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _UrlBar extends StatelessWidget {
  const _UrlBar({required this.host});

  final String host;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded, size: 12, color: AppColors.textTertiaire),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              host,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: AppFontWeight.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewCanvas extends StatelessWidget {
  const _PreviewCanvas({
    required this.placeholder,
    required this.name,
    required this.role,
    required this.photoUrl,
    required this.journeyTitle,
    required this.journeyMeta,
    required this.skills,
  });

  final bool placeholder;
  final String name;
  final String role;
  final String? photoUrl;
  final String? journeyTitle;
  final String? journeyMeta;
  final List<PortfolioPreviewSkill> skills;

  @override
  Widget build(BuildContext context) {
    final showJourney = journeyTitle != null;
    final showSkills = skills.isNotEmpty;
    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E8A86), Color(0xFF1A4E9A)],
        ),
      ),
      child: Column(
        children: [
          _IdentityRow(
            placeholder: placeholder,
            name: name,
            role: role,
            photoUrl: photoUrl,
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showJourney)
                  Expanded(
                    child: _JourneyColumn(
                      title: journeyTitle!,
                      meta: journeyMeta,
                    ),
                  ),
                if (showJourney && showSkills) const SizedBox(width: 14),
                if (showSkills)
                  Expanded(
                    child: _SkillsColumn(skills: skills),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityRow extends StatelessWidget {
  const _IdentityRow({
    required this.placeholder,
    required this.name,
    required this.role,
    required this.photoUrl,
  });

  final bool placeholder;
  final String name;
  final String role;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Avatar(
          placeholder: placeholder,
          photoUrl: photoUrl,
          initials: _initials(name),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: AppFontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              if (role.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  role,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFD7F3EF),
                    fontSize: 13,
                    height: 1.25,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _initials(String value) {
    final parts = value
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty && part != '—')
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.placeholder,
    required this.initials,
    this.photoUrl,
  });

  final bool placeholder;
  final String initials;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    return Container(
      width: 72,
      height: 72,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF8EE8DC),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF16324F),
        ),
        child: ClipOval(
          child: url != null && url.isNotEmpty
              ? Image.network(
                  url,
                  width: 66,
                  height: 66,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _fallback(),
                )
              : _fallback(),
        ),
      ),
    );
  }

  Widget _fallback() {
    if (placeholder || initials.isEmpty) {
      return const Icon(Icons.person_rounded, color: Colors.white, size: 40);
    }
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: AppFontWeight.bold,
        ),
      ),
    );
  }
}

class _JourneyColumn extends StatelessWidget {
  const _JourneyColumn({required this.title, this.meta});

  final String title;
  final String? meta;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('PARCOURS'),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 5),
              child: _Dot(Color(0xFF8EE8DC)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: AppFontWeight.bold,
                    ),
                  ),
                  if (meta != null && meta!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      meta!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFD7F3EF),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SkillsColumn extends StatelessWidget {
  const _SkillsColumn({required this.skills});

  final List<PortfolioPreviewSkill> skills;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('SKILLS'),
        const SizedBox(height: 8),
        for (var index = 0; index < skills.length; index++) ...[
          if (index > 0) const SizedBox(height: 8),
          _SkillLine(skills[index].label, skills[index].progress),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF8EE8DC),
        fontSize: 11,
        fontWeight: AppFontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _SkillLine extends StatelessWidget {
  const _SkillLine(this.label, this.progress);

  final String label;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: AppFontWeight.semiBold,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 5,
            backgroundColor: Colors.white.withValues(alpha: 0.22),
            color: const Color(0xFF8EE8DC),
          ),
        ),
      ],
    );
  }
}
