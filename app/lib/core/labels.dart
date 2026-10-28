import '../domain/gravity.dart';
import '../domain/missions.dart';
import '../l10n/app_localizations.dart';

/// Localised labels for data enums (DESIGN.md §12.2).
extension FsLabels on AppLocalizations {
  /// Fuel class label, e.g. "Thin solid".
  String fuelClassLabel(String v) => switch (v) {
    'thin_solid' => fuelThinSolid,
    'thick_solid' => fuelThickSolid,
    'droplet' => fuelDroplet,
    'gas_jet' => fuelGasJet,
    _ => fuelOther,
  };

  /// Flow direction label ("quiescent" shows as "None").
  String flowDirLabel(String? v) => switch (v) {
    'opposed' => dirOpposed,
    'concurrent' => dirConcurrent,
    'quiescent' => dirQuiescent,
    _ => dirOther,
  };

  /// Platform label.
  String platformLabel(String v) => switch (v) {
    'iss' => platformIss,
    'free_flyer' => platformFreeFlyer,
    'drop_tower' => platformDropTower,
    'parabolic' => platformParabolic,
    'ground' => platformGround,
    _ => v,
  };

  /// Quality flag label.
  String qualityLabel(String v) => switch (v) {
    'estimated' => qualityEstimated,
    'digitized' => qualityDigitized,
    'video_derived' => qualityVideoDerived,
    'suspect' => qualitySuspect,
    _ => qualityOk,
  };

  /// Diluent label.
  String diluentLabel(String? v) => switch (v) {
    'n2' => diluentN2,
    'he' => diluentHe,
    'co2' => diluentCo2,
    _ => diluentOther,
  };

  /// Gravity class label for filters.
  String gravityClassLabel(GravityClass g) => switch (g) {
    GravityClass.micro => gravityClassMicro,
    GravityClass.partial => gravityClassPartial,
    GravityClass.earth => gravityClassEarth,
  };

  /// Label for a slider input by name.
  String inputLabel(String name) => switch (name) {
    'o2_mole_fraction' => featO2,
    'pressure_kpa' => featPressure,
    'flow_velocity_mm_s' => featFlow,
    'gravity_g' => featGravity,
    'fuel_thickness_mm' => featThickness,
    'fuel_density_kg_m3' => featDensity,
    _ => name,
  };

  /// Label for a model feature (Methods feature list).
  String featureLabel(String name) => switch (name) {
    'o2_partial_kpa' => featO2Partial,
    'log10_flow' => featLogFlow,
    'log10_gravity' => featLogGravity,
    'areal_density_kg_m2' => featArealDensity,
    _ when name.startsWith('fuel_class__') =>
      '$featFuelClass: ${fuelClassLabel(name.substring(12))}',
    _ when name.startsWith('flow_direction__') =>
      '$featFlowDir: ${flowDirLabel(name.substring(16))}',
    _ when name.startsWith('diluent__') =>
      '$featDiluent: ${diluentLabel(name.substring(9))}',
    _ => inputLabel(name),
  };

  /// Mission name from its `name_key` (falls back to the key).
  String missionName(String key) => switch (key) {
    'missionIss' => missionIss,
    'missionLunar' => missionLunar,
    'missionMarsTransit' => missionMarsTransit,
    'missionMars' => missionMars,
    'missionEarth' => missionEarth,
    _ => key,
  };

  /// Mission note from its `note_key`, or null.
  String? missionNote(String? key) => switch (key) {
    'missionIssNote' => missionIssNote,
    'missionLunarNote' => missionLunarNote,
    'missionMarsTransitNote' => missionMarsTransitNote,
    'missionMarsNote' => missionMarsNote,
    'missionEarthNote' => missionEarthNote,
    _ => null,
  };

  /// Planned experiment label from its `label_key`.
  String plannedLabel(String key) => switch (key) {
    'plannedFm2' => plannedFm2,
    _ => key,
  };

  /// Verdict text (DESIGN.md §12.5).
  String verdictLabel(Verdict v) => switch (v) {
    Verdict.likelyBurns => verdictBurns,
    Verdict.likelyOut => verdictOut,
    Verdict.unknown => verdictUnknown,
    Verdict.uncertain => verdictUncertain,
  };
}
