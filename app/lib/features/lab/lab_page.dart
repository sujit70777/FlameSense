import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/breakpoints.dart';
import '../../core/theme/tokens.dart';
import '../../domain/lab_input.dart';
import '../../domain/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_page.dart';
import 'conditions_panel.dart';
import 'lab_flame_panel.dart';
import 'lab_providers.dart';
import 'lab_sticky_bar.dart';
import 'prediction_panel.dart';

/// Fire Lab (DESIGN.md §11.3, F3). The URL query mirrors the conditions.
class LabPage extends ConsumerStatefulWidget {
  const LabPage({super.key, this.conditionsKey, this.predictionKey});

  /// Tour targets (steps 2 and 3).
  final Key? conditionsKey, predictionKey;

  @override
  ConsumerState<LabPage> createState() => _LabPageState();
}

class _LabPageState extends ConsumerState<LabPage> {
  String? _appliedQuery;
  final _scroll = ScrollController();
  final _gaugeKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Apply shared links, reloads and back/forward (each distinct query once).
    final uri = GoRouterState.of(context).uri;
    if (uri.path == '/lab' && uri.query != _appliedQuery) {
      _appliedQuery = uri.query;
      final q = uri.queryParameters;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(labInputProvider.notifier).applyQuery(q);
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _reflectUrl(LabInput x) {
    if (!mounted || GoRouterState.of(context).uri.path != '/lab') return;
    final path = labPath(x);
    _appliedQuery = Uri.parse(path).query;
    SystemNavigator.routeInformationUpdated(
      uri: Uri.parse(path),
      replace: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(labInputProvider, (_, x) => _reflectUrl(x));
    final l = AppLocalizations.of(context);
    final size = FsWidth.of(context);
    final conditions = KeyedSubtree(
      key: widget.conditionsKey,
      child: const ConditionsPanel(),
    );
    final prediction = KeyedSubtree(
      key: widget.predictionKey,
      child: PredictionPanel(gaugeKey: _gaugeKey),
    );
    const gap = SizedBox(width: FsSpace.s6, height: FsSpace.s6);
    final Widget body = switch (size) {
      FsWidth.large || FsWidth.xl => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 360, child: conditions),
          gap,
          const Expanded(child: LabFlamePanel(height: 360)),
          gap,
          SizedBox(width: 400, child: prediction),
        ],
      ),
      FsWidth.expanded => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 340, child: conditions),
          gap,
          Expanded(
            child: Column(
              children: [const LabFlamePanel(height: 300), gap, prediction],
            ),
          ),
        ],
      ),
      _ => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const LabFlamePanel(height: 240),
          gap,
          prediction,
          gap,
          conditions,
        ],
      ),
    };
    final page = FsPage(
      controller: _scroll,
      title: l.labTitle,
      description: l.labDesc,
      children: [body],
    );
    if (!size.isCompact) return page;
    return Stack(
      children: [
        page,
        LabStickyBar(scroll: _scroll, gaugeKey: _gaugeKey),
      ],
    );
  }
}
