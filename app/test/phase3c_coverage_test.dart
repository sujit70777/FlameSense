import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

void main() {
  testWidgets('Explore opens on "What NASA has tested" with the matrix', (
    t,
  ) async {
    await pumpApp(t, location: '/explore', height: 1800);
    expect(find.text('What NASA has tested'), findsWidgets);
    expect(find.text('Test runs'), findsOneWidget);
    expect(
      find.text(
        'Built from every NASA combustion investigation we could download. '
        'Empty cells are conditions nobody has tested in this data.',
      ),
      findsOneWidget,
    );
    expect(find.text('Moon/Mars'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(
      find.text(
        '8 of 9 table rows state both oxygen and pressure, '
        'so only they appear in the matrix.',
      ),
      findsOneWidget,
    );
    expect(find.text('FIXTURE droplet study'), findsOneWidget);
    expect(find.text('no row-level outcome or rate column'), findsOneWidget);
    expect(find.text('Open DOI'), findsOneWidget);
    expect(find.textContaining('Showing 160'), findsNothing);
  });

  testWidgets('tapping a cell filters the investigation table', (t) async {
    await pumpApp(t, location: '/explore', height: 1800);
    await t.tap(find.text('5'));
    await settle(t, frames: 4);
    expect(
      find.text('Showing the investigations with runs in the selected cell.'),
      findsOneWidget,
    );
    expect(find.text('FIXTURE droplet study'), findsOneWidget);
    expect(find.text('FIXTURE solid study'), findsNothing);
    await t.tap(find.text('Show all investigations'));
    await settle(t, frames: 4);
    expect(find.text('FIXTURE solid study'), findsOneWidget);
  });

  testWidgets('pressure band switch shows that band', (t) async {
    await pumpApp(t, location: '/explore', height: 1800);
    expect(find.text('1'), findsNothing);
    await t.tap(find.text('>110 kPa'));
    await settle(t, frames: 4);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('5'), findsNothing);
  });

  testWidgets('missing coverage.json hides the tab; Explore is the runs view', (
    t,
  ) async {
    await pumpApp(
      t,
      location: '/explore?tab=coverage',
      missing: {'coverage.json'},
      height: 2000,
    );
    expect(find.text('The investigation list is not built yet'), findsNothing);
    expect(find.text('Test runs'), findsNothing);
    expect(find.text('Showing 160 of 160 runs'), findsOneWidget);
  });

  testWidgets('"Test runs" tab and ?tab=runs show the runs explorer', (
    t,
  ) async {
    await pumpApp(t, location: '/explore', height: 2000);
    await t.tap(find.text('Test runs'));
    await settle(t, frames: 6);
    expect(find.text('Showing 160 of 160 runs'), findsOneWidget);
    await pumpApp(t, location: '/explore?tab=runs', height: 2000);
    expect(find.text('Showing 160 of 160 runs'), findsOneWidget);
  });
}
