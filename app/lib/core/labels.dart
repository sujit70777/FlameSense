import '../domain/gravity.dart';
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
}
