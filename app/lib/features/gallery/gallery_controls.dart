import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_segmented.dart';
import '../../widgets/fs_slider.dart';

/// Interactive controls for the gallery (slider, log slider, segmented).
class GalleryControls extends StatefulWidget {
  const GalleryControls({super.key});

  @override
  State<GalleryControls> createState() => _GalleryControlsState();
}

class _GalleryControlsState extends State<GalleryControls> {
  double _o2 = 0.21, _flow = 100, _g = 1e-6;
  String _dir = 'opposed';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FsSlider(
          label: l.featO2,
          value: _o2,
          min: 0.15,
          max: 0.40,
          step: 0.005,
          displayScale: 100,
          unit: l.unitPercent,
          markers: [FsSliderMarker(0.21, l.labMarkerEarthAir)],
          onChanged: (v) => setState(() => _o2 = v),
        ),
        const SizedBox(height: FsSpace.s4),
        FsSlider(
          label: l.featFlow,
          value: _flow,
          min: 0,
          max: 1000,
          decimals: 0,
          scale: FsSliderScale.log1p,
          unit: l.unitMmS,
          onChanged: (v) => setState(() => _flow = v),
        ),
        const SizedBox(height: FsSpace.s4),
        FsSlider(
          label: l.featGravity,
          value: _g,
          min: 1e-6,
          max: 1,
          decimals: 6,
          scale: FsSliderScale.log,
          showField: false,
          unit: l.unitG,
          snaps: [
            FsSliderSnap(1e-6, l.gIss),
            FsSliderSnap(0.1652, l.gMoon),
            FsSliderSnap(0.3783, l.gMars),
            FsSliderSnap(1, l.gEarth),
          ],
          onChanged: (v) => setState(() => _g = v),
        ),
        const SizedBox(height: FsSpace.s4),
        FsSegmented<String>(
          segments: [
            FsSegment('opposed', l.dirOpposed),
            FsSegment('concurrent', l.dirConcurrent),
            FsSegment('quiescent', l.dirQuiescent),
          ],
          selected: _dir,
          onChanged: (v) => setState(() => _dir = v),
        ),
      ],
    );
  }
}
