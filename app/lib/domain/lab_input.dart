import 'package:flutter/foundation.dart';

/// Every user input of the Fire Lab (PLAN.md §3.3, Phase 7 step 3).
@immutable
class LabInput {
  const LabInput({
    required this.fuelClass,
    required this.thicknessMm,
    required this.densityKgM3,
    required this.o2,
    required this.pressureKpa,
    required this.flowMmS,
    required this.flowDirection,
    required this.gravityG,
    this.material,
  });

  final String fuelClass, flowDirection;
  final double thicknessMm, densityKgM3, o2, pressureKpa, flowMmS, gravityG;

  /// Selected material preset (fuel_name), or null for "Custom".
  final String? material;

  LabInput copyWith({
    String? fuelClass,
    double? thicknessMm,
    double? densityKgM3,
    double? o2,
    double? pressureKpa,
    double? flowMmS,
    String? flowDirection,
    double? gravityG,
    String? Function()? material,
  }) => LabInput(
    fuelClass: fuelClass ?? this.fuelClass,
    thicknessMm: thicknessMm ?? this.thicknessMm,
    densityKgM3: densityKgM3 ?? this.densityKgM3,
    o2: o2 ?? this.o2,
    pressureKpa: pressureKpa ?? this.pressureKpa,
    flowMmS: flowMmS ?? this.flowMmS,
    flowDirection: flowDirection ?? this.flowDirection,
    gravityG: gravityG ?? this.gravityG,
    material: material == null ? this.material : material(),
  );

  /// Shareable query parameters, e.g. `fuel=thin_solid&o2=0.21&p=101.3&flow=100&g=1e-6`.
  Map<String, String> toQuery() => {
    'fuel': fuelClass,
    'mat': ?material,
    'th': queryNumber(thicknessMm),
    'rho': queryNumber(densityKgM3),
    'o2': queryNumber(o2),
    'p': queryNumber(pressureKpa),
    'flow': queryNumber(flowMmS),
    'dir': flowDirection,
    'g': queryNumber(gravityG),
  };

  /// Applies any recognised query parameters on top of [base]; invalid values are ignored.
  static LabInput fromQuery(Map<String, String> q, LabInput base) {
    double? d(String k) {
      final v = double.tryParse(q[k] ?? '');
      return v != null && v.isFinite ? v : null;
    }

    return base.copyWith(
      fuelClass: q['fuel'],
      thicknessMm: d('th'),
      densityKgM3: d('rho'),
      o2: d('o2'),
      pressureKpa: d('p'),
      flowMmS: d('flow'),
      flowDirection: q['dir'],
      gravityG: d('g'),
      material: q.containsKey('mat')
          ? () => q['mat']
          : (q.containsKey('fuel') ? () => null : null),
    );
  }

  /// Compact number for URLs, e.g. 1e-6, 0.21, 101.3.
  static String queryNumber(double v) {
    if (v != 0 && v.abs() < 1e-3) {
      return v.toStringAsExponential(3).replaceAll(RegExp(r'\.?0+e'), 'e');
    }
    final s = v.toStringAsPrecision(6);
    return s.contains('.') ? s.replaceAll(RegExp(r'\.?0+$'), '') : s;
  }

  @override
  bool operator ==(Object other) =>
      other is LabInput &&
      other.fuelClass == fuelClass &&
      other.thicknessMm == thicknessMm &&
      other.densityKgM3 == densityKgM3 &&
      other.o2 == o2 &&
      other.pressureKpa == pressureKpa &&
      other.flowMmS == flowMmS &&
      other.flowDirection == flowDirection &&
      other.gravityG == gravityG &&
      other.material == material;

  @override
  int get hashCode => Object.hash(
    fuelClass,
    thicknessMm,
    densityKgM3,
    o2,
    pressureKpa,
    flowMmS,
    flowDirection,
    gravityG,
    material,
  );
}
