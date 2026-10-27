import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_button.dart';
import '../../widgets/fs_dialog.dart';

/// Single-choice dialog; returns `(value)` or null when dismissed. `(null)` = All.
Future<(T?,)?> pickOne<T>(
  BuildContext context,
  String title,
  List<(T, String)> options,
  T? current,
) {
  final l = AppLocalizations.of(context);
  return showFsDialog<(T?,)>(
    context,
    FsDialog(
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (value, label) in [
            (null, l.filterAll),
            ...options.map((o) => (o.$1, o.$2)),
          ])
            _OptionTile(
              label: label,
              selected: value == current,
              onTap: () => Navigator.of(context).pop((value,)),
            ),
        ],
      ),
    ),
  );
}

/// Multi-choice dialog; returns the new set or null when dismissed.
Future<Set<String>?> pickMany(
  BuildContext context,
  String title,
  List<String> options,
  Set<String> current,
) {
  final l = AppLocalizations.of(context);
  var picked = {...current};
  return showFsDialog<Set<String>>(
    context,
    StatefulBuilder(
      builder: (context, setState) => FsDialog(
        title: title,
        actions: [
          FsButton(
            label: l.exploreClear,
            variant: FsButtonVariant.ghost,
            onPressed: () => setState(() => picked = {}),
          ),
          FsButton(
            label: l.filterApply,
            onPressed: () => Navigator.of(context).pop(picked),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final o in options)
              CheckboxListTile(
                value: picked.contains(o),
                title: Text(o, style: context.text.labelLarge),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (v) => setState(
                  () => v == true ? picked.add(o) : picked.remove(o),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

/// Range dialog with a RangeSlider; values are in display units. Returns (min, max) or null.
Future<(double, double)?> pickRange(
  BuildContext context, {
  required String title,
  required double min,
  required double max,
  required (double, double) current,
  required String unit,
  required FsFormat format,
}) {
  final l = AppLocalizations.of(context);
  var v = RangeValues(current.$1.clamp(min, max), current.$2.clamp(min, max));
  return showFsDialog<(double, double)>(
    context,
    StatefulBuilder(
      builder: (context, setState) => FsDialog(
        title: title,
        actions: [
          FsButton(
            label: l.close,
            variant: FsButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
          FsButton(
            label: l.filterApply,
            onPressed: () => Navigator.of(context).pop((v.start, v.end)),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.filterRangeValue(format.sig(v.start), format.sig(v.end), unit),
              style: context.nums.md,
            ),
            const SizedBox(height: FsSpace.s3),
            RangeSlider(
              values: v,
              min: min,
              max: max,
              activeColor: context.fs.microgStrong,
              inactiveColor: context.fs.outline,
              onChanged: (r) => setState(() => v = r),
            ),
          ],
        ),
      ),
    ),
  );
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    return ListTile(
      minTileHeight: FsSize.touch,
      selected: selected,
      selectedTileColor: c.microgTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FsRadius.sm),
      ),
      leading: Icon(
        selected
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_off_rounded,
        size: FsSize.iconInline,
        color: selected ? c.microg : c.textTertiary,
      ),
      title: Text(
        label,
        style: context.text.labelLarge!.copyWith(
          color: selected ? c.microg : null,
        ),
      ),
      onTap: onTap,
    );
  }
}
