import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

/// Semantic label of the widget that has primary focus.
String? focusedLabel() {
  String? label;
  FocusManager.instance.primaryFocus?.context?.visitAncestorElements((e) {
    final w = e.widget;
    if (w is Semantics && w.properties.label != null) {
      label = w.properties.label;
      return false;
    }
    return true;
  });
  return label;
}

void main() {
  testWidgets(
    'Tab reaches content buttons, top-bar actions and every rail item (AUDIT §6)',
    (tester) async {
      await pumpApp(tester, location: '/about', height: 1000);
      final seen = <String>[];
      for (var i = 0; i < 20; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final l = focusedLabel();
        if (l != null) seen.add(l);
      }
      for (final expected in [
        'View all licenses',
        'Take the tour',
        'EN',
        'Home',
        'Missions',
        'Fire Lab',
        'Methods',
        'About',
      ]) {
        expect(seen, contains(expected), reason: expected);
      }
    },
  );

  testWidgets('Enter activates the focused rail item', (tester) async {
    await pumpApp(tester, location: '/about', height: 1000);
    for (var i = 0; i < 30 && focusedLabel() != 'Map'; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await settle(tester, frames: 6);
    expect(find.text('Flammability map'), findsWidgets);
  });
}
