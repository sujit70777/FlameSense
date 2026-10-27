import 'dart:typed_data';

import 'package:flamesense/domain/predictor.dart';
import 'package:flamesense/features/map/map_grid.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fixture_data.dart';
import 'helpers/test_app.dart';

const key = MapKey(
  fuelClass: 'thin_solid',
  thicknessMm: 0.15,
  densityKgM3: 800,
  pressureKpa: 101.3,
  gravityG: 1e-6,
  flowDirection: 'opposed',
);

void main() {
  late Predictor p;
  late dynamic spec;
  setUpAll(() async {
    final d = await loadData();
    p = Predictor.fromData(d);
    spec = d.featureSpec;
  });

  test('grid is deterministic, memoized and computed in < 250 ms', () {
    clearMapMemo();
    final sw = Stopwatch()..start();
    final a = computeMapGrid(p, spec, key)!;
    sw.stop();
    expect(sw.elapsedMilliseconds, lessThan(250));
    clearMapMemo();
    final b = computeMapGrid(p, spec, key)!;
    expect(a.prob, b.prob);
    expect(identical(computeMapGrid(p, spec, key), b), isTrue);
    expect(a.prob.length, kMapCols * kMapRows);
    expect(a.prob.every((v) => v >= 0 && v <= 1), isTrue);
    // Bottom row is the lowest oxygen.
    expect(a.o2At(0), lessThan(a.o2At(kMapRows - 1.0)));
  });

  test('grid cell input round-trips to axes', () {
    final g = computeMapGrid(p, spec, key)!;
    final x = g.inputAt(10, 20);
    expect(g.colOf(x.flowMmS), closeTo(10.5, 1e-9));
    expect(g.rowOf(x.o2), closeTo(20.5, 1e-9));
  });

  test('marching squares finds a vertical 50% line on a synthetic grid', () {
    const cols = 6, rows = 4;
    final v = Float64List(cols * rows);
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        v[r * cols + c] = c / (cols - 1); // 0.5 between columns 2 and 3
      }
    }
    final segs = contourSegments(v, cols, rows, 0.5);
    expect(segs, hasLength(rows - 1));
    for (final (a, b) in segs) {
      expect(a.dx, closeTo(2.5, 1e-9));
      expect(b.dx, closeTo(2.5, 1e-9));
    }
    expect(contourSegments(Float64List(cols * rows), cols, rows, 0.5), isEmpty);
  });

  testWidgets('empty data shows the map unavailable state', (tester) async {
    await pumpApp(tester, location: '/map', fixtures: false, height: 1800);
    expect(find.text('Not enough data to draw the map'), findsOneWidget);
    expect(find.text('Show the runs in Explore'), findsOneWidget);
  });

  testWidgets(
    'fixture map renders; Moon shows the data-gap notice; overflow-free at 360',
    (tester) async {
      await pumpApp(tester, location: '/map?g=0.1652', height: 2000);
      expect(find.text('Likely to keep burning'), findsOneWidget);
      expect(
        find.textContaining('No NASA fire tests at Moon gravity'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('compact map has a settings button and no overflow', (
    tester,
  ) async {
    await pumpApp(tester, location: '/map', width: 360, height: 2400);
    expect(find.text('Map settings'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
