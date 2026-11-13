import 'json_utils.dart';

/// One mission preset (PLAN.md §3.10). Values come only from missions.json.
class Mission {
  const Mission({
    required this.id,
    required this.nameKey,
    required this.gravityG,
    required this.pressureKpa,
    required this.o2,
    required this.source,
    required this.noteKey,
  });

  /// Parses one mission; null when a required number is missing.
  static Mission? tryParse(Map<String, dynamic> j) {
    final g = asDouble(j['gravity_g']),
        p = asDouble(j['pressure_kpa']),
        o2 = asDouble(j['o2']);
    final id = asString(j['id']);
    if (g == null || p == null || o2 == null || id == null) return null;
    return Mission(
      id: id,
      nameKey: asString(j['name_key']) ?? id,
      gravityG: g,
      pressureKpa: p,
      o2: o2,
      source: asString(j['source']) ?? '',
      noteKey: asString(j['note_key']),
    );
  }

  final String id, nameKey, source;
  final String? noteKey;
  final double gravityG, pressureKpa, o2;

  bool get isSourced => source.trim().isNotEmpty;
}

/// A point of a planned NASA experiment.
class PlannedPoint {
  const PlannedPoint({required this.o2, required this.pressureKpa});
  final double o2, pressureKpa;
}

/// A planned NASA experiment copied exactly from its NASA document.
class PlannedExperiment {
  const PlannedExperiment({
    required this.id,
    required this.labelKey,
    required this.missionId,
    required this.gravityG,
    required this.points,
    required this.flowNote,
    required this.source,
  });

  /// Parses one planned experiment.
  factory PlannedExperiment.fromJson(Map<String, dynamic> j) =>
      PlannedExperiment(
        id: asString(j['id']) ?? '',
        labelKey: asString(j['label_key']) ?? '',
        missionId: asString(j['mission_id']) ?? '',
        gravityG: asDouble(j['gravity_g']) ?? 0,
        points: asList(j['points'])
            .map(asMap)
            .where(
              (p) =>
                  asDouble(p['o2']) != null &&
                  asDouble(p['pressure_kpa']) != null,
            )
            .map(
              (p) => PlannedPoint(
                o2: asDouble(p['o2'])!,
                pressureKpa: asDouble(p['pressure_kpa'])!,
              ),
            )
            .toList(),
        flowNote: asString(j['flow_note']) ?? '',
        source: asString(j['source']) ?? '',
      );

  final String id, labelKey, missionId, flowNote, source;
  final double gravityG;
  final List<PlannedPoint> points;

  bool get isSourced => source.trim().isNotEmpty;
}

/// `missions.json`.
class MissionsFile {
  const MissionsFile({
    required this.signedOffByLead,
    required this.missions,
    required this.planned,
    required this.sweepMin,
    required this.sweepMax,
    required this.sweepN,
  });

  /// Empty file used when missions.json is absent.
  static const empty = MissionsFile(
    signedOffByLead: false,
    missions: [],
    planned: [],
    sweepMin: 0,
    sweepMax: null,
    sweepN: 24,
  );

  /// Parses missions.json.
  factory MissionsFile.fromJson(Map<String, dynamic> j) {
    final sweep = asMap(j['airflow_sweep_mm_s']);
    return MissionsFile(
      signedOffByLead: asBool(j['signed_off_by_lead']) ?? false,
      missions: asList(j['missions'])
          .map((m) => Mission.tryParse(asMap(m)))
          .nonNulls
          .toList(),
      planned: asList(j['planned_experiments'])
          .map((p) => PlannedExperiment.fromJson(asMap(p)))
          .toList(),
      sweepMin: asDouble(sweep['min']) ?? 0,
      sweepMax: asDouble(sweep['max']),
      sweepN: asInt(sweep['n']) ?? 24,
    );
  }

  final bool signedOffByLead;
  final List<Mission> missions;
  final List<PlannedExperiment> planned;
  final double sweepMin;
  final double? sweepMax;
  final int sweepN;
}
