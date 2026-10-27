import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../data/models/physics_params.dart';
import 'gravity.dart';

/// Physics check status (DESIGN.md §9.16).
enum PhysicsStatus { ok, notApplicable, unavailable, nearExtinction }

/// Result of the thin-fuel reference check.
class PhysicsResult {
  const PhysicsResult({
    required this.status,
    this.spreadMmS,
    this.buoyantVelocityMmS,
  });

  static const unavailable = PhysicsResult(status: PhysicsStatus.unavailable);

  final PhysicsStatus status;
  final double? spreadMmS, buoyantVelocityMmS;
}

/// Port of `pipeline/src/flamesense/physics.py` (PLAN.md Phase 4, PHYSICS_SPEC.md).
/// Uses only values from physics_params.json; refuses to run while any required
/// value is null, or while unsigned in a release build.
class PhysicsModel {
  PhysicsModel(this.params, {bool? requireSignOff})
    : requireSignOff = requireSignOff ?? kReleaseMode;

  final PhysicsParams params;
  final bool requireSignOff;

  // Near-extinction thresholds (TODO(Q-1), docs/QUESTIONS.md), same as physics.py.
  static const nearExtinctionO2 = 0.15;
  static const nearExtinctionMicroG = 0.01;
  static const nearExtinctionFlowMmS = 5.0;

  /// True when the parameters are complete and (if required) signed off.
  bool get enabled =>
      params.problems.isEmpty && (!requireSignOff || params.signedOffByLead);

  /// Flame temperature (K) by linear interpolation in O₂, clamped at the table ends.
  double? flameTempK(double o2) {
    final xs = params.flameO2, ys = params.flameTf;
    if (xs.isEmpty ||
        xs.length != ys.length ||
        ys.contains(null) ||
        xs.contains(null)) {
      return null;
    }
    if (o2 <= xs.first!) return ys.first;
    if (o2 >= xs.last!) return ys.last;
    for (var i = 0; i < xs.length - 1; i++) {
      final a = xs[i]!, b = xs[i + 1]!;
      if (o2 <= b) return ys[i]! + (ys[i + 1]! - ys[i]!) * (o2 - a) / (b - a);
    }
    return ys.last;
  }

  /// U_b = (g·α·(T_f − T∞)/T∞)^(1/3) in mm/s, with T_f at O₂ = 0.21 as in physics.py.
  double? buoyantVelocityMmS(double gravityG) {
    if (!enabled || !params.buoyantEnabled) return null;
    final tf = flameTempK(0.21), tInf = params.tInf!, alpha = params.alpha!;
    if (tf == null || tf <= tInf) return null;
    final g = gravityG * kStandardGravity;
    return math.pow(g * alpha * (tf - tInf) / tInf, 1 / 3).toDouble() * 1000;
  }

  /// Regime check mirroring physics.applicability().
  PhysicsStatus applicability(
    String fuelClass,
    String flowDirection,
    double o2,
    double g,
    double flow,
  ) {
    if (fuelClass != 'thin_solid' ||
        !(flowDirection == 'opposed' || flowDirection == 'quiescent')) {
      return PhysicsStatus.notApplicable;
    }
    if (o2 < nearExtinctionO2) return PhysicsStatus.nearExtinction;
    if (g < nearExtinctionMicroG && flow < nearExtinctionFlowMmS) {
      return PhysicsStatus.nearExtinction;
    }
    return PhysicsStatus.ok;
  }

  /// de Ris thin-fuel spread V_f = (π/4)·λ·(T_f − T_v)/(ρ·c·τ·(T_v − T∞)) in mm/s, or null.
  double? spreadMmS(String? fuelName, double o2) {
    final fuel = params.fuels[fuelName];
    if (!enabled || fuel == null) return null;
    final tInf = params.tInf!, lambda = params.lambda!;
    final tv = fuel.tv!,
        rho = fuel.rho!,
        cs = fuel.cs!,
        tau = fuel.halfThicknessM!;
    final tf = flameTempK(o2);
    if (tv <= tInf || tf == null || tf <= tv) return null;
    return (math.pi / 4) *
        lambda *
        (tf - tv) /
        (rho * cs * tau * (tv - tInf)) *
        1000;
  }

  /// Full check for one set of conditions.
  PhysicsResult evaluate({
    required String? fuelName,
    required String fuelClass,
    required String flowDirection,
    required double o2,
    required double gravityG,
    required double flowMmS,
  }) {
    if (!enabled) return PhysicsResult.unavailable;
    final buoyant = buoyantVelocityMmS(gravityG);
    final status = applicability(
      fuelClass,
      flowDirection,
      o2,
      gravityG,
      flowMmS,
    );
    if (status == PhysicsStatus.notApplicable) {
      return PhysicsResult(status: status, buoyantVelocityMmS: buoyant);
    }
    final spread = spreadMmS(fuelName, o2);
    if (spread == null) {
      return PhysicsResult(
        status: PhysicsStatus.notApplicable,
        buoyantVelocityMmS: buoyant,
      );
    }
    return PhysicsResult(
      status: status,
      spreadMmS: spread,
      buoyantVelocityMmS: buoyant,
    );
  }
}
