import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../care/medications_screen.dart' show formatDate;
import '../reports/pdf_style.dart';
import 'tova_comparison.dart';
import 'tova_record.dart';

/// Builds the TOVA activity report as a PDF: the result, the comparison
/// with the previous activity of the same kind, and the details.
class TovaPdf {
  const TovaPdf._();

  /// [history] is every saved record of the child, newest first, and
  /// must contain [current].
  static Future<Uint8List> build({
    required String childName,
    required int childAge,
    required TovaRecord current,
    required List<TovaRecord> history,
    required ByteData fontData,
  }) async {
    final font = pw.Font.ttf(fontData);
    final comparison = TovaComparison.compare(current, history);

    final doc = pw.Document(
      title: 'TOVA report - $childName',
      author: 'MAZID',
      theme: pw.ThemeData.withFont(base: font, bold: font),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        footer: (context) => pw.Text(
          'MAZID  |  Page ${context.pageNumber} of ${context.pagesCount}  |  '
          'Not a diagnosis.',
          style: const pw.TextStyle(fontSize: 8, color: PdfStyle.muted),
        ),
        build: (context) => [
          _header(childName, childAge, current),
          pw.SizedBox(height: 16),
          _resultBox(current),
          pw.SizedBox(height: 14),
          _comparisonBox(comparison),
          pw.SizedBox(height: 16),
          PdfStyle.title('Details'),
          _details(current),
          pw.SizedBox(height: 16),
          PdfStyle.notice(
            'These are descriptive results from a short test. They are '
            'not official TOVA scores, do not show whether a child has ADHD, '
            'and should not be used to decide on treatment or medication. '
            'Share them with a clinician.',
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _header(String name, int age, TovaRecord current) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Attention test report',
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

  static pw.Widget _resultBox(TovaRecord r) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfStyle.soft,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            '${r.accuracyPct.round()}%',
            style: const pw.TextStyle(fontSize: 30, color: PdfStyle.purple),
          ),
          pw.SizedBox(width: 18),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  r.modeTitle,
                  style:
                      const pw.TextStyle(fontSize: 13, color: PdfStyle.dark),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  '${r.trials} trials, '
                  '${r.completed ? 'completed' : 'ended early'}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfStyle.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _number(double? v, String unit) {
    if (v == null) return '-';
    if (unit.isEmpty) return v.round().toString();
    return unit == 'ms' ? '${v.round()} ms' : '${v.toStringAsFixed(1)} $unit';
  }

  static pw.Widget _comparisonBox(TovaComparison c) {
    final color = switch (c.trend) {
      TovaTrend.improved => PdfStyle.green,
      TovaTrend.worse => PdfStyle.red,
      _ => PdfStyle.amber,
    };

    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfStyle.soft),
        children: [
          PdfStyle.cell('Measure', color: PdfStyle.purple),
          PdfStyle.cell('Now', color: PdfStyle.purple),
          PdfStyle.cell('Before', color: PdfStyle.purple),
          PdfStyle.cell('Result', color: PdfStyle.purple),
        ],
      ),
      for (final m in c.measures)
        pw.TableRow(
          children: [
            PdfStyle.cell(m.label),
            PdfStyle.cell(_number(m.now, m.unit)),
            PdfStyle.cell(_number(m.before, m.unit)),
            PdfStyle.cell(
              switch (m.verdict) {
                1 => 'Better',
                -1 => 'Worse',
                0 => 'Same',
                _ => '-',
              },
              color: switch (m.verdict) {
                1 => PdfStyle.green,
                -1 => PdfStyle.red,
                _ => PdfStyle.muted,
              },
            ),
          ],
        ),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        PdfStyle.title('Compared with last time'),
        pw.Text(
          c.headline,
          style: pw.TextStyle(fontSize: 12, color: color),
        ),
        if (c.previous != null) ...[
          pw.SizedBox(height: 3),
          pw.Text(
            'Last test: ${formatDate(c.previous!.takenAt)}',
            style: const pw.TextStyle(fontSize: 9.5, color: PdfStyle.muted),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: const pw.TableBorder(
              horizontalInside: pw.BorderSide(color: PdfStyle.soft),
            ),
            columnWidths: const {
              0: pw.FlexColumnWidth(3),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(2),
              3: pw.FlexColumnWidth(2),
            },
            children: rows,
          ),
        ],
      ],
    );
  }

  static pw.Widget _details(TovaRecord r) {
    final items = <(String, String)>[
      ('Target hits', '${r.hits}'),
      ('Missed targets', '${r.omissions}'),
      ('Wrong presses', '${r.commissions}'),
      ('Correct rejections', '${r.correctRejections}'),
      ('Early presses (under 150 ms)', '${r.anticipatory}'),
      ('Mean response time', _number(r.meanRtMs, 'ms')),
      ('Response-time variability (SD)', _number(r.sdRtMs, 'ms')),
    ];

    return pw.Table(
      border: const pw.TableBorder(
        horizontalInside: pw.BorderSide(color: PdfStyle.soft),
      ),
      columnWidths: const {
        0: pw.FlexColumnWidth(4),
        1: pw.FlexColumnWidth(2),
      },
      children: [
        for (final item in items)
          pw.TableRow(
            children: [
              PdfStyle.cell(item.$1),
              PdfStyle.cell(item.$2, align: pw.Alignment.centerRight),
            ],
          ),
      ],
    );
  }
}
