import 'package:flutter/material.dart';

import '../core/breakpoints.dart';
import '../core/theme/colors.dart';
import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';
import '../l10n/app_localizations.dart';
import 'fs_icon_button.dart';

/// Dialog body: h2 title, close button, content and actions (DESIGN.md §9.18).
class FsDialog extends StatelessWidget {
  const FsDialog({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
    this.maxWidth = FsSize.dialogMaxConfirm,
    this.header,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;
  final double maxWidth;

  /// Optional widget under the title (chips, status line).
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    final compact = FsWidth.of(context).isCompact;
    final radius = BorderRadius.circular(compact ? FsRadius.md : FsRadius.xl);
    return Dialog(
      backgroundColor: c.isDark ? c.surface3 : c.surface1,
      surfaceTintColor: Colors.transparent,
      insetPadding: EdgeInsets.all(compact ? FsSpace.s4 : FsSpace.s10),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: c.isDark ? c.outlineStrong : c.outline),
      ),
      shadowColor: c.isDark
          ? Colors.transparent
          : FsFixedColors.raisedShadowLight,
      elevation: c.isDark ? 0 : 12,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(title, style: context.text.headlineMedium),
                    ),
                  ),
                  FsIconButton(
                    icon: Icons.close_rounded,
                    tooltip: AppLocalizations.of(context).close,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
              if (header != null) ...[
                const SizedBox(height: FsSpace.s3),
                header!,
              ],
              const SizedBox(height: FsSpace.s4),
              Flexible(child: SingleChildScrollView(child: child)),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: FsSpace.s6),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: FsSpace.s3,
                  runSpacing: FsSpace.s3,
                  children: actions,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows [dialog] with the FlameSense scrim; Esc closes and focus returns to the opener.
Future<T?> showFsDialog<T>(BuildContext context, Widget dialog) =>
    showDialog<T>(
      context: context,
      barrierColor: context.fs.scrim,
      builder: (_) => dialog,
    );
