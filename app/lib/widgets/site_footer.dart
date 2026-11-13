import 'package:flutter/material.dart';

import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';
import '../l10n/app_localizations.dart';

/// Caption footer: disclaimer, credits and the not-affiliated line (DESIGN.md §11.1, §12.1).
class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final style = context.text.labelSmall;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FsSpace.s6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: FsSpace.s4),
          Text(l.disclaimer, style: style),
          const SizedBox(height: FsSpace.s1),
          Text(l.credits, style: style),
          const SizedBox(height: FsSpace.s1),
          Text(l.notAffiliated, style: style),
        ],
      ),
    );
  }
}
