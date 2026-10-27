import '../../domain/gravity.dart';
import 'json_utils.dart';

/// One experiment run (PLAN.md §3.1 canonical schema plus derived columns).
class RunRecord {
  const RunRecord(this._values);

  final Map<String, Object?> _values;

  /// Raw value of [column] (null when missing).
  Object? operator [](String column) => _values[column];

  /// Every non-null column, in schema order.
  Map<String, Object?> get nonNull =>
      Map.fromEntries(_values.entries.where((e) => e.value != null));

  String get runId => asString(_values['run_id']) ?? '';
  String get groupId => asString(_values['group_id']) ?? '';
  String get experiment => asString(_values['experiment']) ?? '';
  String get platform => asString(_values['platform']) ?? '';
  double get gravityG => asDouble(_values['gravity_g']) ?? 1.0;
  String get fuelName => asString(_values['fuel_name']) ?? '';
  String get fuelClass => asString(_values['fuel_class']) ?? 'other';
  double? get thicknessMm => asDouble(_values['fuel_thickness_mm']);
  double? get densityKgM3 => asDouble(_values['fuel_density_kg_m3']);
  double get o2 => asDouble(_values['o2_mole_fraction']) ?? 0;
  double get pressureKpa => asDouble(_values['pressure_kpa']) ?? 0;
  String? get diluent => asString(_values['diluent']);
  double? get flowMmS => asDouble(_values['flow_velocity_mm_s']);
  String? get flowDirection => asString(_values['flow_direction']);
  bool? get ignited => asBool(_values['ignited']);
  bool? get sustained => asBool(_values['sustained']);
  double? get spreadMmS => asDouble(_values['flame_spread_rate_mm_s']);
  double? get burningRate => asDouble(_values['burning_rate_k_mm2_s']);
  String? get extinctionReason => asString(_values['extinction_reason']);
  String get sourceId => asString(_values['source_id']) ?? '';
  String get sourceFile => asString(_values['source_file']) ?? '';
  String get sourceCitation => asString(_values['source_citation']) ?? '';
  String? get sourceUrl => asString(_values['source_url']);
  String get qualityFlag => asString(_values['quality_flag']) ?? 'ok';
  String? get notes => asString(_values['notes']);

  /// Gravity class from the platform and value (DESIGN.md §10.2).
  GravityClass get gravityClass {
    if (platform == 'ground' || gravityG >= 0.9) return GravityClass.earth;
    if (gravityG >= 0.05) return GravityClass.partial;
    return GravityClass.micro;
  }
}

/// `runs.json`: columnar-by-row table (PLAN.md §3.2).
class RunsTable {
  const RunsTable({required this.columns, required this.records});

  /// Parses runs.json rows into records keyed by column name.
  factory RunsTable.fromJson(Map<String, dynamic> j) {
    final columns = asList(j['columns']).map((c) => c.toString()).toList();
    final records = asList(j['rows']).map((row) {
      final values = asList(row);
      return RunRecord({
        for (var i = 0; i < columns.length; i++)
          columns[i]: i < values.length ? values[i] : null,
      });
    }).toList();
    return RunsTable(columns: columns, records: records);
  }

  final List<String> columns;
  final List<RunRecord> records;

  /// Record with [runId], or null.
  RunRecord? byId(String runId) {
    for (final r in records) {
      if (r.runId == runId) return r;
    }
    return null;
  }
}
