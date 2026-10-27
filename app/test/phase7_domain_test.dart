import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flamesense/core/format.dart';
import 'package:flamesense/data/models/physics_params.dart';
import 'package:flamesense/domain/gravity.dart';
import 'package:flamesense/domain/lab_input.dart';
import 'package:flamesense/domain/physics_model.dart';
import 'package:flamesense/domain/predictor.dart';
import 'package:flamesense/domain/sensitivity.dart';
import 'package:flamesense/domain/support_index.dart';
import 'package:flamesense/domain/tree_model.dart';
import 'package:flamesense/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fixture_data.dart';

const base = LabInput(
  fuelClass: 'thin_solid',
  thicknessMm: 0.15,
  densityKgM3: 800,
  o2: 0.25,
  pressureKpa: 101.3,
  flowMmS: 100,
  flowDirection: 'opposed',
  gravityG: 1e-6,
  material: 'fixture-thin',
);

void main() {
  late Predictor p;
  setUpAll(
    () async => p = Predictor.fromData(await loadData(), requireSignOff: true),
  );

  test('Dart trees match LightGBM within 1e-9 for every exported model', () {
    final parity = jsonDecode(
      File('test/fixtures/fixture_parity_fixtures.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(parity.keys, hasLength(4));
    for (final e in parity.entries) {
      final model = TreeModel.fromJson(
        jsonDecode(File('test/fixtures/fixture_${e.key}').readAsStringSync())
            as Map<String, dynamic>,
      );
      for (final row in (e.value as List).cast<Map<String, dynamic>>()) {
        final x = (row['x'] as List).map((v) => (v as num).toDouble()).toList();
        expect(
          (model.raw(x) - (row['raw'] as num)).abs(),
          lessThan(1e-9),
          reason: e.key,
        );
        expect(
          (model.predict(x) - (row['out'] as num)).abs(),
          lessThan(1e-9),
          reason: e.key,
        );
      }
    }
  });

  test('shipped parity fixtures (real models, if any) match within 1e-9', () {
    final parity = jsonDecode(
      File('assets/data/parity_fixtures.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    for (final e in parity.entries) {
      final model = TreeModel.fromJson(
        jsonDecode(File('assets/data/${e.key}').readAsStringSync())
            as Map<String, dynamic>,
      );
      for (final row in (e.value as List).cast<Map<String, dynamic>>()) {
        final x = (row['x'] as List).map((v) => (v as num).toDouble()).toList();
        expect(
          (model.raw(x) - (row['raw'] as num)).abs(),
          lessThan(1e-9),
          reason: e.key,
        );
        expect(
          (model.predict(x) - (row['out'] as num)).abs(),
          lessThan(1e-9),
          reason: e.key,
        );
      }
    }
  });

  test('tree model rejects wrong length and NaN', () {
    expect(() => p.sustain.raw([1, 2]), throwsArgumentError);
    final x = p.vector(p.spec.sustain, base)..[0] = double.nan;
    expect(() => p.sustain.raw(x), throwsArgumentError);
  });

  test('derived features use the PLAN §3.1 formulas (3 hand rows)', () {
    final rows = [
      (base, 25.325, math.log(101) / math.ln10, -6.0, 0.12),
      (
        base.copyWith(
          o2: 0.30,
          pressureKpa: 50,
          flowMmS: 0,
          gravityG: 1.0,
          thicknessMm: 2,
          densityKgM3: 1200,
        ),
        15.0,
        0.0,
        0.0,
        2.4,
      ),
      (
        base.copyWith(
          o2: 0.21,
          pressureKpa: 70,
          flowMmS: 9,
          gravityG: 1e-9,
          thicknessMm: 0.5,
          densityKgM3: 300,
        ),
        14.7,
        1.0,
        -7.0,
        0.15,
      ),
    ];
    for (final (x, partial, logFlow, logG, areal) in rows) {
      final g = p.spec.sustain.groups;
      expect(featureValue('o2_partial_kpa', x, g), closeTo(partial, 1e-12));
      expect(featureValue('log10_flow', x, g), closeTo(logFlow, 1e-12));
      expect(featureValue('log10_gravity', x, g), closeTo(logG, 1e-12));
      expect(featureValue('areal_density_kg_m2', x, g), closeTo(areal, 1e-12));
    }
    expect(
      featureValue('fuel_class__thin_solid', base, p.spec.sustain.groups),
      1,
    );
    expect(
      featureValue('fuel_class__thick_solid', base, p.spec.sustain.groups),
      0,
    );
    expect(featureValue('diluent__n2', base, p.spec.sustain.groups), 1);
  });

  test('gravity mapping round-trips and labels snap within 2%', () {
    for (final g in [1e-6, 1e-4, 0.01, kMoonG, kMarsG, 1.0]) {
      expect(sliderToGravity(gravityToSlider(g)), closeTo(g, g * 1e-9));
    }
    expect(gravityToSlider(1e-6), closeTo(0, 1e-12));
    expect(gravityToSlider(1), 1);
    final l = AppLocalizationsEn(), f = FsFormat('en');
    expect(gravityLabel(1.0, l, f), 'Earth');
    expect(gravityLabel(0.38, l, f), 'Mars');
    expect(gravityLabel(0.165, l, f), 'Moon');
    expect(gravityLabel(1e-6, l, f), 'ISS orbit');
    expect(gravityLabel(1.2e-3, l, f), '1.2 × 10⁻³ g');
    expect(gravityClassOf(kMoonG), GravityClass.partial);
  });

  test('support: training row is high, nearby medium/high, far point low', () {
    final data = p.supportSustain.data;
    final row = data.points.first;
    final raw = [
      for (var i = 0; i < row.length; i++) row[i] * data.std[i] + data.mean[i],
    ];
    expect(
      p.supportSustain.levelFor(p.supportSustain.distance(raw)),
      SupportLevel.high,
    );
    final far = [
      for (var i = 0; i < raw.length; i++) raw[i] + 50 * data.std[i],
    ];
    expect(
      p.supportSustain.levelFor(p.supportSustain.distance(far)),
      SupportLevel.low,
    );
    final mid = data.p95! * 0.99;
    expect(
      p.supportSustain.levelFor(mid),
      data.p50! < mid ? SupportLevel.medium : SupportLevel.high,
    );
  });

  test('outside the training range is flagged per input', () {
    final r = p.predict(base.copyWith(o2: 0.49));
    expect(r.support.outside.map((o) => o.input), contains('o2_mole_fraction'));
    expect(r.has(WarningKind.outsideRange), isTrue);
  });

  test('sensitivity is sorted by |delta| and has at most 4 rows', () {
    final s = sensitivity(p, base);
    expect(s.length, lessThanOrEqualTo(4));
    expect(s, isNotEmpty);
    for (var i = 1; i < s.length; i++) {
      expect(s[i - 1].delta.abs(), greaterThanOrEqualTo(s[i].delta.abs()));
    }
  });

  test('physics hand example (fixture params, not real values)', () {
    final m = p.physics;
    expect(m.enabled, isTrue);
    // V = π/4 · 0.04 · (1000−500) / (1000·2000·0.0005·(500−300)) m/s
    expect(
      m.spreadMmS('fixture-thin', 0.21),
      closeTo(math.pi / 4 * 20 / 200000 * 1000, 1e-12),
    );
    // U_b = (9.80665 · 2.2e-5 · 700/300)^(1/3) m/s
    expect(
      m.buoyantVelocityMmS(1.0),
      closeTo(math.pow(9.80665 * 2.2e-5 * 700 / 300, 1 / 3) * 1000, 1e-9),
    );
    expect(
      m
          .evaluate(
            fuelName: 'fixture-thin',
            fuelClass: 'thick_solid',
            flowDirection: 'opposed',
            o2: 0.21,
            gravityG: 1,
            flowMmS: 100,
          )
          .status,
      PhysicsStatus.notApplicable,
    );
    expect(
      m
          .evaluate(
            fuelName: 'fixture-thin',
            fuelClass: 'thin_solid',
            flowDirection: 'opposed',
            o2: 0.21,
            gravityG: 1e-6,
            flowMmS: 1,
          )
          .status,
      PhysicsStatus.nearExtinction,
    );
  });

  test(
    'physics is unavailable while unsigned in release, or with null values',
    () async {
      final data = await loadData();
      final unsigned = PhysicsParams.fromJson({
        ...jsonDecode(
          File('test/fixtures/fixture_physics_params.json').readAsStringSync(),
        ) as Map<String, dynamic>,
        'signed_off_by_lead': false,
      });
      expect(PhysicsModel(unsigned, requireSignOff: true).enabled, isFalse);
      expect(PhysicsModel(unsigned, requireSignOff: false).enabled, isTrue);
      final real = await loadData(fixtures: false);
      expect(
        PhysicsModel(real.physics, requireSignOff: false).enabled,
        isFalse,
      );
      expect(data.physics.signedOffByLead, isTrue);
    },
  );

  test('spread quantiles never cross across a 1,000-point random sweep', () {
    final rnd = math.Random(1);
    for (var i = 0; i < 1000; i++) {
      final s = p.spread(_random(rnd))!;
      expect(s.$1 <= s.$2 && s.$2 <= s.$3, isTrue);
    }
  });

  test(
    'sustain probability never falls when only oxygen rises (when constrained)',
    () {
      final rnd = math.Random(2);
      for (var i = 0; i < 1000; i++) {
        final x = _random(rnd);
        final lo = p.sustainProbability(x)!,
            hi = p.sustainProbability(x.copyWith(o2: x.o2 + 0.02))!;
        expect(hi, greaterThanOrEqualTo(lo - 1e-12));
      }
    },
    skip:
        'Monotone constraints are off until the lead confirms the signs (Q-2).',
  );

  test('1000 predictions take under 200 ms', () {
    final rnd = math.Random(3);
    final inputs = [for (var i = 0; i < 1000; i++) _random(rnd)];
    p.predict(inputs.first); // warm up
    final sw = Stopwatch()..start();
    for (final x in inputs) {
      p.predict(x);
    }
    sw.stop();
    expect(sw.elapsedMilliseconds, lessThan(200));
  });

  test(
    'real (empty) dataset: both tasks unavailable, no numbers shown',
    () async {
      final real = Predictor.fromData(await loadData(fixtures: false));
      final r = real.predict(base);
      expect(r.sustainProb, isNull);
      expect(r.spreadQ50, isNull);
      expect(r.has(WarningKind.sustainUnavailable), isTrue);
      expect(r.has(WarningKind.spreadUnavailable), isTrue);
      expect(r.has(WarningKind.lowSupport), isFalse);
      expect(sensitivity(real, base), isEmpty);
    },
  );

  test('partial gravity adds the research-gap notice', () {
    expect(
      p
          .predict(base.copyWith(gravityG: kMoonG))
          .has(WarningKind.partialGravity),
      isTrue,
    );
    expect(p.predict(base).has(WarningKind.partialGravity), isFalse);
  });

  test('lab input round-trips through the URL query', () {
    final q = base.toQuery();
    expect(q['g'], '1e-6');
    expect(q['o2'], '0.25');
    expect(
      LabInput.fromQuery(q, base.copyWith(o2: 0.3, material: () => null)),
      base,
    );
    expect(LabInput.fromQuery({'o2': 'abc'}, base), base);
  });
}

LabInput _random(math.Random r) => LabInput(
  fuelClass: r.nextBool() ? 'thin_solid' : 'thick_solid',
  thicknessMm: 0.05 + r.nextDouble() * 10,
  densityKgM3: 300 + r.nextDouble() * 900,
  o2: 0.15 + r.nextDouble() * 0.25,
  pressureKpa: 40 + r.nextDouble() * 70,
  flowMmS: r.nextDouble() * 400,
  flowDirection: r.nextBool() ? 'opposed' : 'concurrent',
  gravityG: math.pow(10, -6 + 6 * r.nextDouble()).toDouble(),
);
