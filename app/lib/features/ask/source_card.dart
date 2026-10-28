import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/models/ask_models.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/citation_chip.dart';
import '../../widgets/fs_button.dart';

/// One numbered source row; [pulse] increments trigger the 900 ms highlight (DESIGN.md §9.10).
class SourceCard extends ConsumerStatefulWidget {
  const SourceCard({super.key, required this.citation, required this.pulse});

  final AskCitation citation;
  final int pulse;

  @override
  ConsumerState<SourceCard> createState() => _SourceCardState();
}

class _SourceCardState extends ConsumerState<SourceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: FsMotion.citationPulse,
  );
  bool _static = false;

  @override
  void didUpdateWidget(SourceCard old) {
    super.didUpdateWidget(old);
    if (widget.pulse != old.pulse) {
      if (MediaQuery.disableAnimationsOf(context)) {
        setState(() => _static = true);
      } else {
        _c.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final c = widget.citation;
    final fs = context.fs;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _static ? 1.0 : (1 - (2 * _c.value - 1).abs());
        return Container(
          padding: const EdgeInsets.all(FsSpace.s3),
          decoration: BoxDecoration(
            color: Color.lerp(Colors.transparent, fs.microgTint, t),
            borderRadius: BorderRadius.circular(FsRadius.md),
          ),
          child: child,
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: CitationChip(n: c.n, tooltip: c.title, onTap: () {}),
          ),
          const SizedBox(width: FsSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title, style: context.text.titleMedium),
                if (c.page != null)
                  Text(
                    l.askPage(fmt.integer(c.page!)),
                    style: context.text.labelSmall,
                  ),
                const SizedBox(height: FsSpace.s1),
                Text(
                  c.snippet,
                  style: context.text.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (c.url.isNotEmpty)
                  FsButton(
                    label: l.askOpenDoc,
                    icon: Icons.open_in_new_rounded,
                    variant: FsButtonVariant.ghost,
                    size: FsButtonSize.sm,
                    semanticLabel: '${l.askOpenDoc}. ${l.openInNewTab}',
                    onPressed: () => launchUrl(
                      Uri.parse(c.url),
                      webOnlyWindowName: '_blank',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
