import 'dart:math' as math;

import '../data/models/investigation.dart';

/// Overlap of one condition across the compared investigations.
enum RangeRelation { overlapping, disjoint, notReported }

/// Computed similarities and differences of 2–3 investigations (PLAN Phase 3D step 4).
class Comparison {
  const Comparison({
    required this.sameHardware,
    required this.hardware,
    required this.sharedFuelStates,
    required this.conditions,
    required this.sharedVaried,
    required this.sharedMeasurements,
  });

  final bool sameHardware;
  final List<String> hardware;
  final Set<String> sharedFuelStates, sharedVaried, sharedMeasurements;

  /// 'o2', 'pressure', 'airflow' -> relation across all compared investigations.
  final Map<String, RangeRelation> conditions;
}

Set<String> _shared(Iterable<Iterable<String>> lists) => lists
    .map((l) => l.map((s) => s.toLowerCase().trim()).toSet())
    .reduce((a, b) => a.intersection(b));

RangeRelation _relation(List<Range?> ranges) {
  if (ranges.any((r) => r == null)) return RangeRelation.notReported;
  final lo = ranges.map((r) => r!.lo).reduce(math.max);
  final hi = ranges.map((r) => r!.hi).reduce(math.min);
  return lo <= hi ? RangeRelation.overlapping : RangeRelation.disjoint;
}

/// Compares 2–3 investigations; throws [ArgumentError] for other counts.
Comparison compareInvestigations(List<InvestigationRecord> items) {
  if (items.length < 2 || items.length > 3) {
    throw ArgumentError(
      'compare needs 2 or 3 investigations, got ${items.length}',
    );
  }
  final hw = items.map((r) => r.hardwareFamily).toList();
  return Comparison(
    sameHardware: hw.toSet().length == 1 && hw.first != 'other',
    hardware: hw,
    sharedFuelStates: _shared(items.map((r) => r.fuelStates)),
    conditions: {
      'o2': _relation(items.map((r) => r.o2Pct).toList()),
      'pressure': _relation(items.map((r) => r.pressureKpa).toList()),
      'airflow': _relation(items.map((r) => r.airflowMmS).toList()),
    },
    sharedVaried: _shared(items.map((r) => r.variedVariables)),
    sharedMeasurements: _shared(items.map((r) => r.measurementTypes)),
  );
}
