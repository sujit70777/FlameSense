import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/format.dart';
import '../core/labels.dart';
import '../core/theme/colors.dart';
import '../data/models/missions_file.dart';
import '../l10n/app_localizations_en.dart';
import 'gravity.dart';
import 'missions.dart';
import 'wishlist.dart';

/// Everything the Mission Fire Brief prints (same values as the screen).
class BriefContent {
  const BriefContent({
    required this.mission,
    required this.materials,
    required this.wishlist,
    required this.planned,
    required this.runsInClass,
    required this.citations,
    required this.reasons,
    required this.conditions,
    required this.url,
    required this.date,
  });

  final Mission mission;
  final List<MaterialAssessment> materials;
  final Wishlist? wishlist;
  final List<PlannedExperiment> planned;
  final int runsInClass;

  /// Unique run citations used by the dataset.
  final List<String> citations;

  /// Reason lines and condition strings per wishlist pick (computed by the screen code).
  final List<List<String>> reasons;
  final List<String> conditions;
  final String url;
  final DateTime date;
}

/// Builds the A4, English-only brief (DESIGN.md §11.13). [regular]/[bold] are static Archivo TTFs.
Future<Uint8List> buildBrief(
  BriefContent b, {
  ByteData? regular,
  ByteData? bold,
  bool compress = true,
}) async {
  final l = AppLocalizationsEn();
  final f = FsFormat('en');
  final reg = pw.Font.ttf(
    regular ?? await rootBundle.load('assets/fonts/Archivo-Regular.ttf'),
  );
  final bld = pw.Font.ttf(
    bold ?? await rootBundle.load('assets/fonts/Archivo-Bold.ttf'),
  );
  final text = const PdfColor.fromInt(0xFF000000 | FsFixedColors.pdfText);
  final space = const PdfColor.fromInt(0xFF000000 | FsFixedColors.pdfSpace);
  final earth = const PdfColor.fromInt(0xFF000000 | FsFixedColors.pdfEarth);
  final name = l.missionName(b.mission.nameKey);
  final title = l.briefTitle(name);
  final date = f.date(b.date);
  pw.TextStyle st(double size, {bool heavy = false, PdfColor? color}) =>
      pw.TextStyle(
        font: heavy ? bld : reg,
        fontSize: size,
        color: color ?? text,
      );
  final (burn, out, unknown) = verdictCounts(b.materials);
  final doc = pw.Document(
    title: title,
    author: 'FlameSense',
    compress: compress,
    theme: pw.ThemeData.withFont(base: reg, bold: bld),
  );
  final footer = l.briefFooter(b.url, date);
  pw.Widget h2(String s) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
    child: pw.Text(s, style: st(13, heavy: true, color: space)),
  );
  final atmosphere = l.missionAtmosphere(
    f.sig(b.mission.pressureKpa),
    f.sig(b.mission.o2 * 100),
    gravityChipLabel(b.mission.gravityG, l, f),
  );
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.copyWith(
        marginLeft: 18 * PdfPageFormat.mm,
        marginRight: 18 * PdfPageFormat.mm,
        marginTop: 18 * PdfPageFormat.mm,
        marginBottom: 18 * PdfPageFormat.mm,
      ),
      footer: (ctx) => pw.Text(footer, style: st(8)),
      build: (ctx) => [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('FlameSense', style: st(12, heavy: true, color: earth)),
            pw.Text(date, style: st(10)),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Text(title, style: st(22, heavy: true)),
        pw.SizedBox(height: 6),
        pw.Text(atmosphere, style: st(11)),
        pw.Text('${l.missionSource}: ${b.mission.source}', style: st(9)),
        pw.SizedBox(height: 8),
        pw.Text(
          l.briefSummary(f.integer(burn), f.integer(out), f.integer(unknown)),
          style: st(11),
        ),
        h2(l.missionMaterials),
        pw.TableHelper.fromTextArray(
          headerStyle: st(10, heavy: true),
          cellStyle: st(10),
          headers: [
            l.missionMaterial,
            l.missionVerdict,
            l.missionWorstCase,
            '${l.missionWorstFlow} (${l.unitMmS})',
            l.missionSupport,
          ],
          data: [
            for (final r in b.materials)
              [
                r.material.name,
                l.verdictLabel(r.verdict),
                r.verdict == Verdict.unknown || r.worstProb == null
                    ? l.notAvailable
                    : '${f.percentPoints(r.worstProb!)}%',
                r.worstFlowMmS == null
                    ? l.notAvailable
                    : f.sig(r.worstFlowMmS!),
                r.support?.name ?? l.notAvailable,
              ],
          ],
        ),
        pw.NewPage(),
        h2(l.briefDataGap),
        pw.Text(
          l.missionGap(
            f.integer(b.runsInClass),
            gravityLabel(b.mission.gravityG, l, f),
          ),
          style: st(10),
        ),
        h2(l.wishlistTitle),
        if (b.wishlist == null)
          pw.Text(l.wishlistEmpty, style: st(10))
        else
          pw.TableHelper.fromTextArray(
            headerStyle: st(10, heavy: true),
            cellStyle: st(9),
            headers: ['#', l.briefConditions, l.briefReasons],
            data: [
              for (var i = 0; i < b.wishlist!.picks.length; i++)
                ['${i + 1}', b.conditions[i], b.reasons[i].join(' ')],
            ],
          ),
        if (b.planned.isNotEmpty) ...[
          h2(l.briefPlanned),
          for (final e in b.planned)
            pw.Text('${l.plannedLabel(e.labelKey)}: ${e.source}', style: st(9)),
        ],
        h2(l.briefDisclaimerTitle),
        pw.Text(l.disclaimer, style: st(10)),
        pw.Text(l.notAffiliated, style: st(10)),
        h2(l.briefCitations),
        for (final c in b.citations) pw.Text(c, style: st(8)),
      ],
    ),
  );
  return doc.save();
}
