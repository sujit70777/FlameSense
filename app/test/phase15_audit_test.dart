import 'dart:convert';

import 'package:flamesense/core/format.dart';
import 'package:flamesense/data/models/physics_params.dart';
import 'package:flamesense/domain/physics_model.dart';
import 'package:flamesense/features/explore/explore_filters.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fixture_data.dart';

/// Minimal RFC 4180 parser for the round-trip check.
List<List<String>> parseCsv(String s) {
  final rows = <List<String>>[];
  var row = <String>[], cell = StringBuffer(), quoted = false;
  for (var i = 0; i < s.length; i++) {
    final ch = s[i];
    if (quoted) {
      if (ch == '"' && i + 1 < s.length && s[i + 1] == '"') {
        cell.write('"');
        i++;
      } else if (ch == '"') {
        quoted = false;
      } else {
        cell.write(ch);
      }
    } else if (ch == '"') {
      quoted = true;
    } else if (ch == ',') {
      row.add(cell.toString());
      cell = StringBuffer();
    } else if (ch == '\n') {
      row.add(cell.toString());
      rows.add(row);
      row = <String>[];
      cell = StringBuffer();
    } else {
      cell.write(ch);
    }
  }
  return rows;
}

void main() {
  test('Explore CSV re-imports with identical values (AUDIT §2)', () async {
    final d = await loadData();
    final csv = runsToCsv(d.runs.columns, d.runs.records);
    final rows = parseCsv(csv);
    expect(rows.first, d.runs.columns);
    expect(rows.length - 1, d.runs.records.length);
    for (var i = 0; i < d.runs.records.length; i++) {
      for (var j = 0; j < d.runs.columns.length; j++) {
        final v = d.runs.records[i][d.runs.columns[j]];
        expect(rows[i + 1][j], v == null ? '' : v.toString());
      }
    }
  });

  test('Bangla digits, unchanged units and decimal point (AUDIT §9)', () {
    final f = FsFormat('bn');
    expect(f.sig(21.5), '২১.৫');
    expect(f.integer(160), '১৬০');
    expect(f.gravity(1e-6), '১০⁻⁶');
    expect(FsFormat.parse('২১.৫'), 21.5);
    expect(FsFormat('en').sig(0.000123), '0.000123');
  });

  test('physics is not applicable to thick solids, concurrent flow and droplets (AUDIT §3)', () async {
    final p = PhysicsModel(
      PhysicsParams.fromJson(
        jsonDecode(await loadFixturePhysics()) as Map<String, dynamic>,
      ),
      requireSignOff: true,
    );
    PhysicsStatus s(String fc, String dir) => p
        .evaluate(
          fuelName: 'fixture-thin',
          fuelClass: fc,
          flowDirection: dir,
          o2: 0.25,
          gravityG: 1,
          flowMmS: 50,
        )
        .status;
    expect(s('thick_solid', 'opposed'), PhysicsStatus.notApplicable);
    expect(s('thin_solid', 'concurrent'), PhysicsStatus.notApplicable);
    expect(s('droplet', 'quiescent'), PhysicsStatus.notApplicable);
    expect(s('thin_solid', 'opposed'), PhysicsStatus.ok);
  });
}
