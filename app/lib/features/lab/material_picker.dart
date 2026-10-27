import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../domain/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_chip.dart';
import '../explore/filter_dialogs.dart';

/// Material dropdown: presets from the runs, plus "Custom" (DESIGN.md §11.3).
class MaterialPicker extends ConsumerWidget {
  const MaterialPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final x = ref.watch(labInputProvider);
    final materials = ref.watch(materialsProvider);
    final notifier = ref.read(labInputProvider.notifier);
    const custom = '\u0000custom';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.labMaterial, style: context.text.labelLarge),
        const SizedBox(height: FsSpace.s2),
        FsChip(
          label: x.material ?? l.labMaterialCustom,
          dropdown: true,
          onTap: () async {
            final r = await pickOne<String>(context, l.labMaterial, [
              for (final m in materials) (m.name, m.name),
              (custom, l.labMaterialCustom),
            ], x.material ?? custom);
            if (r == null) return;
            final picked = materials.where((m) => m.name == r.$1);
            notifier.selectMaterial(picked.isEmpty ? null : picked.first);
          },
        ),
        const SizedBox(height: FsSpace.s1),
        Text(
          l.labMaterialSummary(
            l.fuelClassLabel(x.fuelClass),
            fmt.sig(x.thicknessMm),
          ),
          style: context.text.bodyMedium,
        ),
      ],
    );
  }
}
