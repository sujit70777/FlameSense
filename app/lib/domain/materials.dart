import '../data/models/run_record.dart';

/// A material preset derived from the runs (PLAN.md Phase 10, 11B).
class Material {
  const Material({
    required this.name,
    required this.fuelClass,
    required this.thicknessMm,
    required this.densityKgM3,
    required this.nRuns,
  });

  final String name, fuelClass;

  /// Median thickness and density over the material's runs (null if never reported).
  final double? thicknessMm, densityKgM3;
  final int nRuns;
}

double? _median(List<double> v) {
  if (v.isEmpty) return null;
  final s = [...v]..sort();
  final m = s.length ~/ 2;
  return s.length.isOdd ? s[m] : (s[m - 1] + s[m]) / 2;
}

/// Unique fuel names with their most common class and median properties.
List<Material> materialsFrom(List<RunRecord> runs) {
  final byName = <String, List<RunRecord>>{};
  for (final r in runs) {
    if (r.fuelName.isEmpty) continue;
    byName.putIfAbsent(r.fuelName, () => []).add(r);
  }
  final out = <Material>[];
  for (final e in byName.entries) {
    final counts = <String, int>{};
    for (final r in e.value) {
      counts[r.fuelClass] = (counts[r.fuelClass] ?? 0) + 1;
    }
    final cls =
        (counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key;
    out.add(
      Material(
        name: e.key,
        fuelClass: cls,
        thicknessMm: _median(
          e.value.map((r) => r.thicknessMm).nonNulls.toList(),
        ),
        densityKgM3: _median(
          e.value.map((r) => r.densityKgM3).nonNulls.toList(),
        ),
        nRuns: e.value.length,
      ),
    );
  }
  out.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return out;
}
