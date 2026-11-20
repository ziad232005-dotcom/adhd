import 'dart:typed_data';

import 'package:flutter/services.dart' show ByteData;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../care/medications_screen.dart' show formatDate;
import 'cars_comparison.dart';
import 'cars_models.dart';

/// Builds the CARS report as a PDF: score, comparison with the previous
/// assessment, every area in detail and the history.
class CarsPdf {
  const CarsPdf._();

  static const _purple = PdfColor.fromInt(0xFF6C4BD6);
  static const _dark = PdfColor.fromInt(0xFF30285E);
  static const _muted = PdfColor.fromInt(0xFF6F6A87);
  static const _soft = PdfColor.fromInt(0xFFF0EDFF);
  static const _green = PdfColor.fromInt(0xFF2E9E6B);
  static const _red = PdfColor.fromInt(0xFFD64545);
  static const _amber = PdfColor.fromInt(0xFFB7791F);

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
          style: const pw.TextStyle(fontSize: 8, color: _muted),
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
          _title('Every area in detail'),
          _areasTable(current, comparison),
          pw.SizedBox(height: 14),
          _attention(current),
          if (current.note.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            _title('Parent note'),
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

  static pw.Widget _title(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Text(
          text,
          style: const pw.TextStyle(fontSize: 13, color: _purple),
        ),
      );

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
              style: const pw.TextStyle(fontSize: 20, color: _dark),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              '$name, age $age',
              style: const pw.TextStyle(fontSize: 12, color: _muted),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'MAZID',
              style: const pw.TextStyle(fontSize: 16, color: _purple),
            ),
            pw.Text(
              formatDate(current.takenAt),
              style: const pw.TextStyle(fontSize: 10, color: _muted),
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
        color: _soft,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            '${current.total} / ${CarsQuestionnaire.maxScore}',
            style: const pw.TextStyle(fontSize: 30, color: _purple),
          ),
          pw.SizedBox(width: 18),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  current.band.label,
                  style: const pw.TextStyle(fontSize: 13, color: _dark),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  current.band.description,
                  style: const pw.TextStyle(fontSize: 10, color: _muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static PdfColor _trendColor(CarsTrend trend) => switch (trend) {
        CarsTrend.improved => _green,
        CarsTrend.worse => _red,
        _ => _amber,
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
            style: const pw.TextStyle(fontSize: 11, color: _muted),
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
              style: const pw.TextStyle(fontSize: 9, color: _muted),
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
        _title('Progress over time (total score, lower is better)'),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            for (final r in shown)
              pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.Text(
                      '${r.total}',
                      style: const pw.TextStyle(fontSize: 10, color: _dark),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Container(
                      width: 22,
                      height: chartHeight * r.total / CarsQuestionnaire.maxScore,
                      color: _purple,
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      formatDate(r.takenAt),
                      style: const pw.TextStyle(fontSize: 7.5, color: _muted),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _cell(
    String text, {
    PdfColor color = _dark,
    double size = 9.5,
    pw.Alignment align = pw.Alignment.centerLeft,
  }) {
    return pw.Container(
      alignment: align,
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: pw.Text(text, style: pw.TextStyle(fontSize: size, color: color)),
    );
  }

  static pw.Widget _areasTable(CarsResult current, CarsComparison c) {
    final hasBefore = c.previous != null;

    final rows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _soft),
        children: [
          _cell('Area', color: _purple),
          if (hasBefore)
            _cell('Before', color: _purple, align: pw.Alignment.center),
          _cell('Now', color: _purple, align: pw.Alignment.center),
          if (hasBefore)
            _cell('Change', color: _purple, align: pw.Alignment.center),
          _cell('Level now', color: _purple),
        ],
      ),
      for (var i = 0; i < CarsQuestionnaire.itemCount; i++)
        pw.TableRow(
          children: [
            _cell(CarsQuestionnaire.items[i].title),
            if (hasBefore)
              _cell('${c.areas[i].before}', align: pw.Alignment.center),
            _cell('${current.scores[i]}', align: pw.Alignment.center),
            if (hasBefore) _changeCell(c.areas[i].change),
            _cell(
              CarsQuestionnaire.levels[current.scores[i] - 1].label,
              color: current.scores[i] >= 3 ? _red : _dark,
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
        horizontalInside: pw.BorderSide(color: _soft, width: 0.8),
        bottom: pw.BorderSide(color: _soft, width: 0.8),
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
    final color = change < 0 ? _green : (change > 0 ? _red : _muted);
    return _cell(text, color: color, align: pw.Alignment.center);
  }

  static pw.Widget _attention(CarsResult current) {
    final names = <String>[
      for (var i = 0; i < current.scores.length; i++)
        if (current.scores[i] >= 3) CarsQuestionnaire.items[i].title,
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _title('Areas worth discussing with the doctor'),
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
        _title('How each area is scored'),
        for (final level in CarsQuestionnaire.levels)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Text(
              '${level.score} = ${level.label}: ${level.description}',
              style: const pw.TextStyle(fontSize: 9.5, color: _muted),
            ),
          ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Total: below 30 typical range, 30 to 36 mild to moderate '
          'differences, 37 and above many differences.',
          style: const pw.TextStyle(fontSize: 9.5, color: _muted),
        ),
      ],
    );
  }

  static pw.Widget _disclaimer() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFFFF4DB),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(
        'This report is based on a parent’s observations. It is not a '
        'diagnosis and does not replace a professional assessment. Please '
        'share it with a qualified clinician.',
        style: const pw.TextStyle(fontSize: 9.5, color: _amber),
      ),
    );
  }
}
