import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../care/medications_screen.dart' show formatDate;
import '../reports/pdf_style.dart';
import 'cars_comparison.dart';
import 'cars_models.dart';

/// Builds the CARS report as a PDF: score, comparison with the previous
/// assessment, every area in detail and the history.
class CarsPdf {
  const CarsPdf._();

  /// [history] is every saved result of the child, newest first, and
  /// must contain [current].
  static Future<Uint8List> build({
    required String childName,
    required int childAge,
    required CarsResult current,
    required List<CarsResult> history,
    required ByteData fontData,
  }) async {
    final font = pw.Font.ttf(fontData);
    final index = history.indexWhere((r) => r.takenAt == current.takenAt);
    final previous = (index != -1 && index + 1 < history.length)
        ? history[index + 1]
        : null;
    final comparison = CarsComparison.compare(current, previous);
    final chronological = history.reversed.toList();
    final shown = chronological.length > 6
        ? chronological.sublist(chronological.length - 6)
        : chronological;

    final doc = pw.Document(
      title: 'CARS report - $childName',
      author: 'MAZID',
      theme: pw.ThemeData.withFont(base: font, bold: font),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        footer: (context) => pw.Text(
          'MAZID  |  Page ${context.pageNumber} of ${context.pagesCount}  |  '
          'Parent-reported observations. Not a diagnosis.',
          style: const pw.TextStyle(fontSize: 8, color: PdfStyle.muted),
        ),
        build: (context) => [
          _header(childName, childAge, current),
          pw.SizedBox(height: 16),
          _scoreBox(current),
          pw.SizedBox(height: 14),
          _comparisonBox(comparison),
          if (shown.length > 1) ...[
            pw.SizedBox(height: 14),
            _historyChart(shown),
          ],
          pw.SizedBox(height: 16),
          PdfStyle.title('Every area in detail'),
          _areasTable(current, comparison),
          pw.SizedBox(height: 14),
          _attention(current),
          if (current.note.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            PdfStyle.title('Parent note'),
            pw.Text(current.note, style: const pw.TextStyle(fontSize: 10.5)),
          ],
          pw.SizedBox(height: 16),
          _guide(),
          pw.SizedBox(height: 14),
          _disclaimer(),
        ],
      ),
    );

    return doc.save();
  }

  // -------------------------------------------------------------- pieces

  static pw.Widget _header(String name, int age, CarsResult current) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'CARS observation report',
              style: const pw.TextStyle(fontSize: 20, color: PdfStyle.dark),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              '$name, age $age',
              style: const pw.TextStyle(fontSize: 12, color: PdfStyle.muted),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'MAZID',
              style: const pw.TextStyle(fontSize: 16, color: PdfStyle.purple),
            ),
            pw.Text(
              formatDate(current.takenAt),
              style: const pw.TextStyle(fontSize: 10, color: PdfStyle.muted),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _scoreBox(CarsResult current) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfStyle.soft,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            '${current.total} / ${CarsQuestionnaire.maxScore}',
            style: const pw.TextStyle(fontSize: 30, color: PdfStyle.purple),
          ),
          pw.SizedBox(width: 18),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  current.band.label,
                  style: const pw.TextStyle(fontSize: 13, color: PdfStyle.dark),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  current.band.description,
                  style: const pw.TextStyle(fontSize: 10, color: PdfStyle.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static PdfColor _trendColor(CarsTrend trend) => switch (trend) {
        CarsTrend.improved => PdfStyle.green,
        CarsTrend.worse => PdfStyle.red,
        _ => PdfStyle.amber,
      };

  static pw.Widget _comparisonBox(CarsComparison c) {
    final previous = c.previous;
    final color = _trendColor(c.trend);

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 1.2),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Compared with the previous assessment',
            style: const pw.TextStyle(fontSize: 11, color: PdfStyle.muted),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            c.headline,
            style: pw.TextStyle(fontSize: 13, color: color),
          ),
          if (previous != null) ...[
            pw.SizedBox(height: 6),
            pw.Text(
              '${formatDate(previous.takenAt)}: ${previous.total}/'
              '${CarsQuestionnaire.maxScore} (${previous.band.label})\n'
              '${formatDate(c.current.takenAt)}: ${c.current.total}/'
              '${CarsQuestionnaire.maxScore} (${c.current.band.label})',
              style: const pw.TextStyle(fontSize: 10.5),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              '${c.improvedAreas.length} areas improved, '
              '${c.worsenedAreas.length} areas got worse, '
              '${c.unchangedAreas} stayed the same.'
              '${c.bandChanged ? ' The overall band changed.' : ''}',
              style: const pw.TextStyle(fontSize: 10.5),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'A lower score means fewer difficulties. Changes of '
              '${CarsComparison.stableMargin} points or less are treated as '
              'normal variation between two days.',
              style: const pw.TextStyle(fontSize: 9, color: PdfStyle.muted),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _historyChart(List<CarsResult> shown) {
    const chartHeight = 80.0;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        PdfStyle.title('Progress over time (total score, lower is better)'),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            for (final r in shown)
              pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.Text(
                      '${r.total}',
                      style: const pw.TextStyle(fontSize: 10, color: PdfStyle.dark),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Container(
                      width: 22,
                      height: chartHeight * r.total / CarsQuestionnaire.maxScore,
                      color: PdfStyle.purple,
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      formatDate(r.takenAt),
                      style: const pw.TextStyle(fontSize: 7.5, color: PdfStyle.muted),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _areasTable(CarsResult current, CarsComparison c) {
    final hasBefore = c.previous != null;

    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfStyle.soft),
        children: [
          PdfStyle.cell('Area', color: PdfStyle.purple),
          if (hasBefore)
            PdfStyle.cell('Before', color: PdfStyle.purple, align: pw.Alignment.center),
          PdfStyle.cell('Now', color: PdfStyle.purple, align: pw.Alignment.center),
          if (hasBefore)
            PdfStyle.cell('Change', color: PdfStyle.purple, align: pw.Alignment.center),
          PdfStyle.cell('Level now', color: PdfStyle.purple),
        ],
      ),
      for (var i = 0; i < CarsQuestionnaire.itemCount; i++)
        pw.TableRow(
          children: [
            PdfStyle.cell(CarsQuestionnaire.items[i].title),
            if (hasBefore)
              PdfStyle.cell('${c.areas[i].before}', align: pw.Alignment.center),
            PdfStyle.cell('${current.scores[i]}', align: pw.Alignment.center),
            if (hasBefore) _changeCell(c.areas[i].change),
            PdfStyle.cell(
              CarsQuestionnaire.levels[current.scores[i] - 1].label,
              color: current.scores[i] >= 3 ? PdfStyle.red : PdfStyle.dark,
            ),
          ],
        ),
    ];

    // Area, [before], now, [change], level.
    final widths = hasBefore
        ? const [3.0, 1.0, 1.0, 1.2, 2.6]
        : const [3.0, 1.0, 2.6];

    return pw.Table(
      border: const pw.TableBorder(
        horizontalInside: pw.BorderSide(color: PdfStyle.soft, width: 0.8),
        bottom: pw.BorderSide(color: PdfStyle.soft, width: 0.8),
      ),
      columnWidths: {
        for (final entry in widths.asMap().entries)
          entry.key: pw.FlexColumnWidth(entry.value),
      },
      children: rows,
    );
  }

  static pw.Widget _changeCell(int change) {
    final text = change == 0 ? '0' : CarsComparison.signed(change);
    final color = change < 0 ? PdfStyle.green : (change > 0 ? PdfStyle.red : PdfStyle.muted);
    return PdfStyle.cell(text, color: color, align: pw.Alignment.center);
  }

  static pw.Widget _attention(CarsResult current) {
    final names = <String>[
      for (var i = 0; i < current.scores.length; i++)
        if (current.scores[i] >= 3) CarsQuestionnaire.items[i].title,
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        PdfStyle.title('Areas worth discussing with the doctor'),
        pw.Text(
          names.isEmpty
              ? 'No area was rated moderately or severely different.'
              : 'Rated 3 or 4: ${names.join(', ')}.',
          style: const pw.TextStyle(fontSize: 10.5),
        ),
      ],
    );
  }

  static pw.Widget _guide() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        PdfStyle.title('How each area is scored'),
        for (final level in CarsQuestionnaire.levels)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Text(
              '${level.score} = ${level.label}: ${level.description}',
              style: const pw.TextStyle(fontSize: 9.5, color: PdfStyle.muted),
            ),
          ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Total: below 30 typical range, 30 to 36 mild to moderate '
          'differences, 37 and above many differences.',
          style: const pw.TextStyle(fontSize: 9.5, color: PdfStyle.muted),
        ),
      ],
    );
  }

  static pw.Widget _disclaimer() => PdfStyle.notice(
        'This report is based on a parent\u2019s observations. It is not a '
        'diagnosis and does not replace a professional assessment. Please '
        'share it with a qualified clinician.',
      );
}
