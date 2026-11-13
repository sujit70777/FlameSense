import '../../core/format.dart';
import '../../data/models/app_meta.dart';
import '../../l10n/app_localizations.dart';

/// Gap ids the app has copy for; rows with other ids are not shown.
const kGapIds = {'high_o2_solids', 'partial_gravity', 'earth_baseline'};

/// Localized (title, sentence) for a "Biggest gaps" row, filled with the numbers
/// computed at export (`app_meta.json` `home.topGaps[].params`). Unknown ids
/// return empty strings so a new gap never shows untranslated text.
(String, String) gapCopy(AppLocalizations l, FsFormat f, HomeTopGap g) {
  String i(String k) => f.integer(g.n(k));
  switch (g.id) {
    case 'high_o2_solids':
      final title = l.gapHighO2Title(i('limitPct'));
      if (g.n('nHigh') == 0) {
        return (title, l.gapHighO2BodyNone(i('nSolid'), i('limitPct')));
      }
      return (
        title,
        l.gapHighO2Body(
          i('nHigh'),
          i('nSolid'),
          i('limitPct'),
          f.sig(g.x('pressureMinKpa') ?? 0),
          f.sig(g.x('pressureMaxKpa') ?? 0),
          i('nHighWentOut'),
        ),
      );
    case 'partial_gravity':
      return (
        l.gapPartialTitle,
        l.gapPartialBody(
          i('nPartial'),
          i('nTotal'),
          i('nNasa'),
          i('nThirdParty'),
        ),
      );
    case 'earth_baseline':
      return (
        l.gapEarthTitle,
        g.n('nEarth') == 0
            ? l.gapEarthBodyNone
            : l.gapEarthBody(i('nEarth'), i('nTotal')),
      );
  }
  return ('', '');
}
