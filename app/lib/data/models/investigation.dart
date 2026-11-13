import 'json_utils.dart';

/// Inclusive numeric range [lo, hi], or null when not reported.
typedef Range = ({double lo, double hi});

Range? _range(Object? v) {
  final l = asDoubleList(v);
  if (l.length != 2 || l[0] == null || l[1] == null) return null;
  return (lo: l[0]!, hi: l[1]!);
}

/// One investigation from investigations.json (PLAN Phase 3D).
class InvestigationRecord {
  const InvestigationRecord({
    required this.psiId,
    required this.acronym,
    required this.title,
    required this.hardwareFamily,
    required this.fuelStates,
    required this.pillars,
    required this.o2Pct,
    required this.pressureKpa,
    required this.airflowMmS,
    required this.variedVariables,
    required this.measurementTypes,
    required this.rows,
    required this.hasOutcome,
  });

  /// Parses one `investigations[]` record.
  factory InvestigationRecord.fromJson(Map<String, dynamic> j) {
    final c = asMap(j['conditions']);
    final d = asMap(j['data_richness']);
    List<String> strings(Object? v, String key) =>
        asList(v)
            .map((e) => asString(asMap(e)[key]) ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
    return InvestigationRecord(
      psiId: asString(j['psi_id']) ?? '',
      acronym: asString(j['acronym']) ?? '',
      title: asString(j['title']) ?? '',
      hardwareFamily: asString(j['hardware_family']) ?? 'other',
      fuelStates: asList(j['fuel_state']).map((e) => '$e').toList(),
      pillars: strings(j['pillars'], 'pillar'),
      o2Pct: _range(c['o2_pct']),
      pressureKpa: _range(c['pressure_kpa']),
      airflowMmS: _range(c['airflow_mm_s']),
      variedVariables: strings(j['varied'], 'variable'),
      measurementTypes: strings(j['measurements'], 'type'),
      rows: asInt(d['n_rows']) ?? 0,
      hasOutcome: asBool(d['has_outcome']) ?? false,
    );
  }

  final String psiId, acronym, title, hardwareFamily;
  final List<String> fuelStates, pillars, variedVariables, measurementTypes;
  final Range? o2Pct, pressureKpa, airflowMmS;
  final int rows;
  final bool hasOutcome;
}
