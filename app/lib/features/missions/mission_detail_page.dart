import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/breakpoints.dart';
import '../../core/labels.dart';
import '../../core/labels_en.dart';
import '../../core/platform/browser.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/missions_file.dart';
import '../../domain/brief.dart' deferred as brief;
import '../../domain/gravity.dart';
import '../../domain/missions.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_button.dart';
import '../../widgets/fs_page.dart';
import '../../widgets/fs_panel.dart';
import '../../widgets/gravity_chip.dart';
import '../../widgets/inline_notice.dart';
import '../../widgets/skeleton_block.dart';
import '../../widgets/toast.dart';
import '../explore/explore_filters.dart';
import '../not_found/not_found_page.dart';
import 'materials_table.dart';
import 'mission_providers.dart';
import 'mission_row.dart';
import 'wishlist_csv.dart';
import 'wishlist_panel.dart';

/// Mission detail: materials, data gap, wishlist and the Fire Brief (DESIGN.md §11.12, F11–F13).
class MissionDetailPage extends ConsumerStatefulWidget {
  const MissionDetailPage({super.key, required this.missionId, this.targetKey});

  final String missionId;

  /// Tour target (step 5).
  final Key? targetKey;

  @override
  ConsumerState<MissionDetailPage> createState() => _MissionDetailPageState();
}

class _MissionDetailPageState extends ConsumerState<MissionDetailPage> {
  // The wishlist is computed after the first paint (skeletons until then).
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  Future<void> _brief() async {
    final l = AppLocalizations.of(context);
    final en = FsLabelsEn.instance;
    final m = ref.read(missionByIdProvider(widget.missionId))!;
    final data = ref.read(loadedDataProvider);
    final w = ref.read(wishlistProvider(widget.missionId));
    // The pdf package loads only when someone asks for a brief (keeps first load small).
    await brief.loadLibrary();
    final bytes = await brief.buildBrief(
      brief.BriefContent(
        mission: m,
        materials: ref.read(missionAssessmentProvider(widget.missionId)),
        wishlist: w,
        planned: visiblePlanned(data.missions, m.id),
        runsInClass: runsInGravityClass(data.runs.records, m.gravityG),
        citations: {
          for (final r in data.runs.records) r.sourceCitation,
        }.toList()..sort(),
        reasons: [
          for (final c in w?.picks ?? const []) wishReasons(en.l, en.f, c),
        ],
        conditions: [
          for (final c in w?.picks ?? const []) wishConditions(en.l, en.f, c),
        ],
        url: currentOrigin().isEmpty
            ? 'https://flamesense.ehsanur.com'
            : currentOrigin(),
        date: DateTime.now(),
      ),
    );
    final day = csvFileName(DateTime.now()).substring(16, 24);
    downloadBytes(
      'flamesense_brief_${m.id}_$day.pdf',
      bytes,
      'application/pdf',
    );
    if (mounted) {
      showFsToast(context, l.briefDone, icon: Icons.download_done_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final m = ref.watch(missionByIdProvider(widget.missionId));
    if (m == null) return const NotFoundPage();
    final size = FsWidth.of(context);
    final runs = ref.watch(loadedDataProvider).runs.records;
    final n = runsInGravityClass(runs, m.gravityG);
    final rows = _ready ? ref.watch(missionAssessmentProvider(m.id)) : null;
    final sustainOk = ref
        .watch(loadedDataProvider)
        .featureSpec
        .sustain
        .available;
    final materials = FsPanel(
      title: l.missionMaterials,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!sustainOk) ...[
            InlineNotice(message: l.noticeUnavailable(l.outputSustain)),
            const SizedBox(height: FsSpace.s4),
          ],
          if (rows == null)
            for (var i = 0; i < 8; i++)
              const Padding(
                padding: EdgeInsets.only(bottom: FsSpace.s2),
                child: SkeletonBlock(height: 36),
              )
          else
            MaterialsTable(rows: rows),
          if (n < 10) ...[
            const SizedBox(height: FsSpace.s4),
            InlineNotice(
              variant: NoticeVariant.warn,
              message: l.missionGap(
                fmt.integer(n),
                gravityLabel(m.gravityG, l, fmt),
              ),
            ),
          ],
        ],
      ),
    );
    final wish = _ready
        ? WishlistPanel(mission: m, wishlist: ref.watch(wishlistProvider(m.id)))
        : const FsPanel(child: SkeletonBlock(height: 360, radius: FsRadius.md));
    final briefButton = FsButton(
      label: l.briefButton,
      icon: Icons.picture_as_pdf_rounded,
      onPressed: _ready ? _brief : null,
    );
    return FsPage(
      title: l.missionName(m.nameKey),
      description: [
        missionAtmosphere(l, fmt, m),
        l.missionNote(m.noteKey),
      ].nonNulls.join('\n'),
      actions: [briefButton],
      children: [
        GravityChipRow(m: m),
        const SizedBox(height: FsSpace.s4),
        KeyedSubtree(
          key: widget.targetKey,
          child: size.isLargeUp
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: materials),
                    const SizedBox(width: FsSpace.s6),
                    Expanded(flex: 5, child: wish),
                  ],
                )
              : Column(
                  children: [
                    wish,
                    const SizedBox(height: FsSpace.s6),
                    materials,
                  ],
                ),
        ),
      ],
    );
  }
}

/// Gravity chip + unsourced debug notice under the header.
class GravityChipRow extends ConsumerWidget {
  const GravityChipRow({super.key, required this.m});

  final Mission m;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    return Wrap(
      spacing: FsSpace.s3,
      runSpacing: FsSpace.s2,
      children: [
        GravityChip(
          gravityClass: gravityClassOf(m.gravityG),
          label: gravityChipLabel(m.gravityG, l, fmt),
        ),
        if (!m.isSourced)
          InlineNotice(
            variant: NoticeVariant.warn,
            message: l.missionUnsourcedDebug,
          ),
      ],
    );
  }
}
