import 'package:flamesense/features/explore/explore_page.dart';
import 'package:flamesense/features/lab/lab_page.dart';
import 'package:flamesense/features/map/map_page.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

/// Opens a picker by its chip label and picks [option].
Future<void> pick(WidgetTester t, String chip, String option) async {
  await t.tap(find.text(chip).first);
  await settle(t, frames: 10);
  await t.tap(find.text(option).last);
  await settle(t, frames: 10);
}

void main() {
  testWidgets('map: picking a material type keeps the page', (t) async {
    await pumpApp(t, location: '/map', fixtures: false, swap: emptyDataset);
    await t.tap(find.text('Thin solid').first);
    await settle(t, frames: 10);
    expect(find.text('All'), findsNothing); // single choice, no "All" row
    await t.tap(find.text('Thick solid').last);
    await settle(t, frames: 10);
    expect(t.takeException(), isNull);
    expect(find.byType(MapPage), findsOneWidget);
    expect(find.text('Thick solid'), findsOneWidget);
  });

  testWidgets('lab: picking a material keeps the page', (t) async {
    await pumpApp(
      t,
      location: '/lab',
      fixtures: false,
      swap: emptyDataset,
      height: 1600,
    );
    await pick(t, 'Custom', 'Custom');
    expect(t.takeException(), isNull);
    expect(find.byType(LabPage), findsOneWidget);
  });

  testWidgets('explore: "All" in a filter keeps the page', (t) async {
    await pumpApp(t, location: '/explore?tab=runs', height: 1600);
    await pick(t, 'Platform', 'All');
    expect(t.takeException(), isNull);
    expect(find.byType(ExplorePage), findsOneWidget);
  });
}
