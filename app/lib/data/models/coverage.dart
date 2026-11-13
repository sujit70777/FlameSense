import 'json_utils.dart';

/// One PSI combustion investigation in the coverage atlas (coverage.json, PLAN Phase 3C).
class CoverageInvestigation {
  const CoverageInvestigation({
    required this.psiId,
    required this.acronym,
    required this.title,
    required this.doi,
    required this.platform,
    required this.years,
    required this.rows,
    required this.usedInModels,
    required this.whyNotUsed,
  });

  /// Parses one `investigations[]` record.
  factory CoverageInvestigation.fromJson(Map<String, dynamic> j) =>
      CoverageInvestigation(
        psiId: asString(j['psi_id']) ?? '',
        acronym: asString(j['acronym']) ?? '',
        title: asString(j['title']) ?? '',
        doi: asString(j['doi']) ?? '',
        platform: asString(j['platform']) ?? '',
        years: asString(j['years']) ?? '',
        rows: asInt(j['n_rows']) ?? 0,
        usedInModels: asBool(j['used_in_models']) ?? false,
        whyNotUsed: asString(j['why_not_used']) ?? '',
      );

  final String psiId, acronym, title, doi, platform, years, whyNotUsed;
  final int rows;
  final bool usedInModels;

  /// Short name: the acronym, or the PSI id for studies without one.
  String get label => acronym.isEmpty ? psiId : acronym;
}

/// Runs in one gravity class x O2 band x pressure band cell.
class CoverageCell {
  const CoverageCell({
    required this.gravityClass,
    required this.o2Band,
    required this.pressureBand,
    required this.runs,
    required this.investigations,
  });

  /// Parses one `matrix[]` record.
  factory CoverageCell.fromJson(Map<String, dynamic> j) => CoverageCell(
    gravityClass: asString(j['gravity_class']) ?? '',
    o2Band: asString(j['o2_band']) ?? '',
    pressureBand: asString(j['pressure_band']) ?? '',
    runs: asInt(j['n_runs']) ?? 0,
    investigations: asList(j['investigations']).map((e) => '$e').toList(),
  );

  final String gravityClass, o2Band, pressureBand;
  final int runs;
  final List<String> investigations;
}

/// The coverage atlas; [CoverageFile.empty] until the pipeline `catalog` command has run.
class CoverageFile {
  const CoverageFile({
    required this.investigations,
    required this.cells,
    required this.o2Bands,
    required this.pressureBands,
    required this.totalRows,
    required this.rowsInMatrix,
  });

  static const empty = CoverageFile(
    investigations: [],
    cells: [],
    o2Bands: [],
    pressureBands: [],
    totalRows: 0,
    rowsInMatrix: 0,
  );

  /// Gravity classes in display order (rows of the matrix).
  static const gravityClasses = ['microgravity', 'moon_mars', 'earth'];

  /// Parses coverage.json.
  factory CoverageFile.fromJson(Map<String, dynamic> j) {
    final totals = asMap(j['totals']);
    return CoverageFile(
      investigations: asList(j['investigations'])
          .map((e) => CoverageInvestigation.fromJson(asMap(e)))
          .toList(),
      cells: asList(j['matrix'])
          .map((e) => CoverageCell.fromJson(asMap(e)))
          .toList(),
      o2Bands: asList(j['o2_bands_pct']).map((e) => '$e').toList(),
      pressureBands: asList(j['pressure_bands_kpa']).map((e) => '$e').toList(),
      totalRows: asInt(totals['rows']) ?? 0,
      rowsInMatrix: asInt(totals['rows_in_matrix']) ?? 0,
    );
  }

  final List<CoverageInvestigation> investigations;
  final List<CoverageCell> cells;
  final List<String> o2Bands, pressureBands;
  final int totalRows, rowsInMatrix;

  bool get isEmpty => investigations.isEmpty;

  /// The cell for a gravity class, O2 band and pressure band (zero runs if absent).
  CoverageCell cell(String gravity, String o2, String pressure) =>
      cells.firstWhere(
        (c) =>
            c.gravityClass == gravity &&
            c.o2Band == o2 &&
            c.pressureBand == pressure,
        orElse: () => CoverageCell(
          gravityClass: gravity,
          o2Band: o2,
          pressureBand: pressure,
          runs: 0,
          investigations: const [],
        ),
      );
}
