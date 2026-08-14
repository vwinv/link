import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';

/// Poste + nom d’équipe avec logo, sous le nom sur les cartes pro / membre.
class ProDesignTeamLine extends StatelessWidget {
  const ProDesignTeamLine({
    required this.jobTitle,
    this.companyName,
    this.address,
    this.logoUrl,
    this.alignment = MainAxisAlignment.center,
    this.jobStyle,
    this.companyStyle,
    this.addressStyle,
    super.key,
  });

  final String jobTitle;
  final String? companyName;
  final String? address;
  final String? logoUrl;
  final MainAxisAlignment alignment;
  final TextStyle? jobStyle;
  final TextStyle? companyStyle;
  final TextStyle? addressStyle;

  String get _company {
    return companyName?.trim() ?? '';
  }

  String get _job {
    final job = jobTitle.trim();
    final company = _company;
    if (company.isEmpty) return job;
    if (job == company) return '';
    final suffix = ' - $company';
    if (job.endsWith(suffix)) {
      return job.substring(0, job.length - suffix.length).trim();
    }
    return job;
  }

  @override
  Widget build(BuildContext context) {
    final job = _job;
    final company = _company;
    final addressText = address?.trim() ?? '';
    final logo = logoUrl?.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment == MainAxisAlignment.start
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        if (job.isNotEmpty)
          Text(
            job,
            textAlign: alignment == MainAxisAlignment.start
                ? TextAlign.start
                : TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: jobStyle,
          ),
        if (company.isNotEmpty) ...[
          if (job.isNotEmpty) const SizedBox(height: 8),
          Row(
            mainAxisAlignment: alignment,
            children: [
              if (logo != null && logo.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    logo,
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  company,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: companyStyle ??
                      jobStyle?.copyWith(fontWeight: AppFontWeight.bold),
                ),
              ),
            ],
          ),
        ],
        if (addressText.isNotEmpty) ...[
          if (job.isNotEmpty || company.isNotEmpty) const SizedBox(height: 6),
          Text(
            addressText,
            textAlign: alignment == MainAxisAlignment.start
                ? TextAlign.start
                : TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: addressStyle ??
                jobStyle?.copyWith(
                  fontSize: (jobStyle?.fontSize ?? 14) * 0.92,
                ),
          ),
        ],
      ],
    );
  }
}
