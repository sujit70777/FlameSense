import '../../core/format.dart';
import '../../core/labels.dart';
import '../../domain/wishlist.dart';
import '../../l10n/app_localizations.dart';

/// Reasons for one pick, from its score terms (DESIGN.md §12.5); at least one is always given.
List<String> wishReasons(AppLocalizations l, FsFormat f, WishCandidate c) {
  final out = [
    if (c.unsure) l.wishlistReasonUnsure(f.fixed(c.p, 2)),
    if (c.far) l.wishlistReasonFar,
    if (c.wide) l.wishlistReasonWide,
  ];
  if (out.isNotEmpty) return out;
  final terms = [
    (0.45 * c.u, l.wishlistReasonUnsure(f.fixed(c.p, 2))),
    (0.45 * c.n, l.wishlistReasonFar),
    (0.10 * c.w, l.wishlistReasonWide),
  ];
  terms.sort((a, b) => b.$1.compareTo(a.$1));
  return [terms.first.$2];
}

/// Conditions line, e.g. "29% O₂, 56 kPa, 40 mm/s, Thin solid".
String wishConditions(AppLocalizations l, FsFormat f, WishCandidate c) =>
    l.wishlistConditions(
      f.sig(c.input.o2 * 100),
      f.sig(c.input.pressureKpa),
      f.sig(c.input.flowMmS),
      l.fuelClassLabel(c.input.fuelClass),
    );

/// Test-matrix CSV (English, model units) for the 5 picks.
String wishlistCsv(String missionId, Wishlist w) {
  final f = FsFormat('en');
  final b = StringBuffer(
    'rank,mission,o2_mole_fraction,pressure_kpa,flow_velocity_mm_s,fuel_class,gravity_g,'
    'sustain_probability,uncertainty_u,distance_n,spread_width_w,score\n',
  );
  for (var i = 0; i < w.picks.length; i++) {
    final c = w.picks[i];
    b.writeln(
      [
        i + 1,
        missionId,
        f.sig(c.input.o2, digits: 4),
        f.sig(c.input.pressureKpa, digits: 4),
        f.sig(c.input.flowMmS, digits: 4),
        c.input.fuelClass,
        c.input.gravityG,
        f.fixed(c.p, 4),
        f.fixed(c.u, 4),
        f.fixed(c.n, 4),
        f.fixed(c.w, 4),
        f.fixed(c.score, 4),
      ].join(','),
    );
  }
  return b.toString();
}

/// "Top {pct}%" as computed, truncated to one decimal (never rounded up).
String truncPercent(FsFormat f, double pct) =>
    f.digits(((pct * 10).floor() / 10).toString());
