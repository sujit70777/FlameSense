import 'json_utils.dart';

/// Thin-fuel parameters for one material (PLAN.md §3.7).
class FuelParams {
  const FuelParams({
    required this.fuelClass,
    this.rho,
    this.cs,
    this.tv,
    this.halfThicknessM,
    required this.source,
  });

  /// Parses one `fuels` entry.
  factory FuelParams.fromJson(Map<String, dynamic> j) => FuelParams(
    fuelClass: asString(j['fuel_class']) ?? 'other',
    rho: asDouble(j['rho_kg_m3']),
    cs: asDouble(j['c_j_kgk']),
    tv: asDouble(j['t_v_k']),
    halfThicknessM: asDouble(j['half_thickness_m']),
    source: asString(j['source']) ?? '',
  );

  final String fuelClass, source;
  final double? rho, cs, tv, halfThicknessM;
}

/// `physics_params.json`: owned by the lead; the app never fills a value.
class PhysicsParams {
  const PhysicsParams({
    required this.signedOffByLead,
    this.signedOffOn,
    this.lambda,
    this.alpha,
    this.tInf,
    required this.gasSource,
    required this.fuels,
    required this.flameO2,
    required this.flameTf,
    required this.flameSource,
    required this.buoyantEnabled,
    required this.buoyantSource,
  });

  /// Parses physics_params.json.
  factory PhysicsParams.fromJson(Map<String, dynamic> j) {
    final gas = asMap(j['gas']);
    final flame = asMap(j['flame_temp_vs_o2']);
    final buoyant = asMap(j['buoyant_velocity']);
    return PhysicsParams(
      signedOffByLead: asBool(j['signed_off_by_lead']) ?? false,
      signedOffOn: asString(j['signed_off_on']),
      lambda: asDouble(gas['lambda_w_mk']),
      alpha: asDouble(gas['alpha_m2_s']),
      tInf: asDouble(gas['t_inf_k']),
      gasSource: asString(gas['source']) ?? '',
      fuels: asMap(j['fuels'])
          .map((k, v) => MapEntry(k, FuelParams.fromJson(asMap(v)))),
      flameO2: asDoubleList(flame['o2']),
      flameTf: asDoubleList(flame['t_f_k']),
      flameSource: asString(flame['source']) ?? '',
      buoyantEnabled: asBool(buoyant['enabled']) ?? false,
      buoyantSource: asString(buoyant['source']) ?? '',
    );
  }

  final bool signedOffByLead, buoyantEnabled;
  final String? signedOffOn;
  final double? lambda, alpha, tInf;
  final String gasSource, flameSource, buoyantSource;
  final Map<String, FuelParams> fuels;
  final List<double?> flameO2, flameTf;

  /// Problems that make the physics check unavailable (mirrors physics.validate_params).
  List<String> get problems {
    final p = <String>[];
    if (lambda == null || alpha == null || tInf == null) {
      p.add('gas values missing');
    }
    if (gasSource.trim().isEmpty) p.add('gas source missing');
    if (flameO2.isEmpty ||
        flameO2.length != flameTf.length ||
        flameTf.any((t) => t == null)) {
      p.add('flame temperature table incomplete');
    }
    if (flameSource.trim().isEmpty) p.add('flame temperature source missing');
    if (fuels.isEmpty) p.add('no fuels');
    for (final e in fuels.entries) {
      final f = e.value;
      if ([f.rho, f.cs, f.tv, f.halfThicknessM].contains(null) ||
          f.source.trim().isEmpty) {
        p.add('fuel ${e.key} incomplete');
      }
    }
    if (buoyantEnabled && buoyantSource.trim().isEmpty) {
      p.add('buoyant source missing');
    }
    return p;
  }
}
