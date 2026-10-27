import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/breakpoints.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../domain/gravity.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fs_button.dart';
import '../../widgets/fs_page.dart';
import '../../widgets/fs_panel.dart';
import '../../widgets/fs_sheet.dart';
import '../../widgets/inline_notice.dart';
import '../../widgets/skeleton_block.dart';
import 'map_controls.dart';
import 'map_inspector.dart';
import 'map_legend.dart';
import 'map_providers.dart';
import 'map_view.dart';

/// Flammability map (DESIGN.md §11.4, F4).
class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key, this.mapKey});

  /// Tour target (step 4).
  final Key? mapKey;

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  String? _applied;
  bool _drawn = false;
  (int, int)? _hover;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uri = GoRouterState.of(context).uri;
    if (uri.path == '/map' && uri.query != _applied) {
      _applied = uri.query;
      final q = uri.queryParameters;
      if (q.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) ref.read(mapSettingsProvider.notifier).applyQuery(q);
        });
      }
    }
    if (!_drawn) {
      // Skeleton on the very first draw only, while the grid is computed.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _drawn = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final size = FsWidth.of(context);
    final s = ref.watch(mapSettingsProvider);
    final cls = gravityClassOf(s.gravityG);
    final grid = _drawn ? ref.watch(mapGridProvider) : null;
    final runs = s.showRuns ? ref.watch(mapRunsProvider) : const <Never>[];
    final aspect = size.isCompact ? 1.0 : 4 / 3;
    final body = gravityName(s.gravityG, l);
    final Widget mapArea = !_drawn
        ? AspectRatio(
            aspectRatio: aspect,
            child: const SkeletonBlock(radius: FsRadius.lg),
          )
        : Stack(
            children: [
              MapView(
                key: widget.mapKey,
                grid: grid,
                runs: runs,
                showContour: s.showContour,
                pinned: s.pinned,
                aspect: aspect,
                onPin: (c) => ref
                    .read(mapSettingsProvider.notifier)
                    .set(s.copyWith(pinned: () => c)),
                onHover: (c) => setState(() => _hover = c),
              ),
              if (grid == null)
                Positioned.fill(
                  child: EmptyState(
                    icon: Icons.layers_clear_rounded,
                    title: l.mapEmptyTitle,
                    body: l.mapEmptyBody,
                    primaryLabel: l.mapEmptyCta,
                    onPrimary: () => context.go('/explore'),
                  ),
                ),
            ],
          );
    final side = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MapInspector(
          grid: grid,
          cell: _hover ?? s.pinned,
          pinned: _hover == null && s.pinned != null,
        ),
        const SizedBox(height: FsSpace.s6),
        const MapLegend(),
      ],
    );
    final controls = size.isCompact
        ? FsButton(
            label: l.mapSettings,
            icon: Icons.tune_rounded,
            variant: FsButtonVariant.secondary,
            onPressed: () => showFsSheet<void>(
              context,
              (_) => const Padding(
                padding: EdgeInsets.all(FsSpace.s4),
                child: MapControls(),
              ),
            ),
          )
        : const MapControls();
    return FsPage(
      title: l.mapTitle,
      description: l.mapDesc,
      children: [
        controls,
        const SizedBox(height: FsSpace.s4),
        if (cls == GravityClass.partial) ...[
          // The "no tests" wording is only true when there are none; otherwise the general notice.
          InlineNotice(
            message: ref.watch(mapGravityClassCountProvider) == 0
                ? l.mapGapNotice(body ?? l.gCustom, fmt.integer(0))
                : l.noticePartialG,
          ),
          const SizedBox(height: FsSpace.s4),
        ],
        if (size.hasRail)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FsPanel(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 880),
                    child: mapArea,
                  ),
                ),
              ),
              const SizedBox(width: FsSpace.s6),
              SizedBox(width: 300, child: FsPanel(child: side)),
            ],
          )
        else ...[
          FsPanel(child: mapArea),
          const SizedBox(height: FsSpace.s4),
          FsPanel(child: side),
        ],
      ],
    );
  }
}
