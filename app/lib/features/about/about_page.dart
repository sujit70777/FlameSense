import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_info.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_button.dart';
import '../../widgets/fs_page.dart';
import '../../widgets/section_header.dart';
import '../methods/methods_data.dart';

/// About (DESIGN.md §11.8): team, challenge, open source, AI use, licenses, privacy, contact.
class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatProvider);
    final d = ref.watch(loadedDataProvider);
    final body = context.text.bodyLarge;
    final sources = sourceSummaries(d.runs.records);
    final built = DateTime.tryParse(d.meta.buildTimeUtc);
    void open(String url) =>
        launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
    Widget section(String title, List<Widget> children) => Padding(
      padding: const EdgeInsets.only(bottom: FsSpace.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title),
          ...children,
        ],
      ),
    );
    return FsPage(
      title: l.aboutTitle,
      description: l.aboutDesc,
      maxWidth: FsSize.readingColumn,
      children: [
        section(l.aboutWhatTitle, [Text(l.aboutWhatBody, style: body)]),
        section(l.aboutTeamTitle, [
          Text(l.aboutTeamBody, style: body),
        ]), // TODO(Q-6)
        section(l.aboutChallengeTitle, [
          Text(l.aboutChallengeBody, style: body),
        ]),
        section(l.aboutOpenSourceTitle, [
          Text(l.aboutOpenSourceBody, style: body),
          const SizedBox(height: FsSpace.s3),
          FsButton(
            label: l.aboutGithub,
            icon: Icons.open_in_new_rounded,
            variant: FsButtonVariant.secondary,
            semanticLabel: '${l.aboutGithub}. ${l.openInNewTab}',
            onPressed: () => open(kRepoUrl),
          ),
        ]),
        section(l.aboutAiTitle, [Text(l.aboutAiBody, style: body)]),
        section(l.aboutLicensesTitle, [
          Text(l.aboutLicenseCode, style: body),
          Text(l.aboutLicenseFonts, style: body),
          const SizedBox(height: FsSpace.s2),
          Text(
            sources.isEmpty
                ? l.aboutDataCreditsPending
                : l.aboutDataCredits(sources.map((s) => s.citation).join('; ')),
            style: body,
          ),
          const SizedBox(height: FsSpace.s2),
          Text(l.notAffiliated, style: context.text.labelLarge),
          const SizedBox(height: FsSpace.s3),
          FsButton(
            label: l.aboutViewLicenses,
            variant: FsButtonVariant.ghost,
            onPressed: () => showLicensePage(
              context: context,
              applicationName: l.appName,
              applicationVersion: kAppVersion,
            ),
          ),
        ]),
        section(l.aboutPrivacyTitle, [Text(l.aboutPrivacy, style: body)]),
        section(l.aboutContactTitle, [
          Text(l.aboutContactBody, style: body),
          const SizedBox(height: FsSpace.s3),
          FsButton(
            label: l.aboutContactButton,
            icon: Icons.open_in_new_rounded,
            variant: FsButtonVariant.secondary,
            semanticLabel: '${l.aboutContactButton}. ${l.openInNewTab}',
            onPressed: () => open(kIssuesUrl),
          ),
        ]),
        Text(
          l.aboutVersion(
            kAppVersion,
            d.meta.dataVersion.isEmpty ? l.notAvailable : d.meta.dataVersion,
            built == null ? l.notAvailable : f.date(built),
          ),
          style: context.text.labelSmall,
        ),
        const SizedBox(height: FsSpace.s1),
        Text(l.disclaimer, style: context.text.labelSmall),
      ],
    );
  }
}
