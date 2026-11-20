import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../care/medications_screen.dart' show formatDate;
import 'pdf_style.dart';
import 'weekly_stats.dart';

/// Builds the weekly report: how the week went and whether it was better
/// or worse than the week before.
class WeeklyPdf {
  const WeeklyPdf._();

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static Future<Uint8List> build({
    required String childName,
    required int childAge,
    required WeeklyComparison comparison,
    required ByteData fontData,
  }) async {
    final font = pw.Font.ttf(fontData);
    final week = comparison.current;

    final doc = pw.Document(
      title: 'Weekly report - $childName',
      author: 'MAZID',
      theme: pw.ThemeData.withFont(base: font, bold: font),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        footer: (context) => pw.Text(
          'MAZID  |  Page ${context.pageNumber} of ${context.pagesCount}  |  '
          'Based on what the family recorded in the app.',
          style: const pw.TextStyle(fontSize: 8, color: PdfStyle.muted),
        ),
        build: (context) => [
          _header(childName, childAge, week.week),
          pw.SizedBox(height: 14),
          _verdict(comparison),
          pw.SizedBox(height: 14),
          PdfStyle.title('This week compared with the week before'),
          _comparisonTable(comparison),
          pw.SizedBox(height: 14),
          _takeaways(comparison),
          pw.SizedBox(height: 14),
          PdfStyle.title('Day by day'),
          _dayTable(week),
          pw.SizedBox(height: 14),
          ..._details(week),
          pw.SizedBox(height: 14),
          PdfStyle.notice(
            'This report only shows what was recorded in the app. A quiet '
            'week may simply mean fewer entries. It is not a diagnosis. '
            'Please discuss any worries with your child’s doctor.',
          ),
        ],
      ),
    );

    return doc.save();
  }

  // -------------------------------------------------------------- pieces

  static String _range(ReportWeek week) {
    final last = week.end.subtract(const Duration(days: 1));
    return '${formatDate(week.start)} to ${formatDate(last)}';
  }

  static pw.Widget _header(String name, int age, ReportWeek week) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Weekly report',
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
              _range(week),
              style: const pw.TextStyle(fontSize: 10, color: PdfStyle.muted),
            ),
          ],
        ),
      ],
    );
  }

  static PdfColor _trendColor(WeeklyTrend trend) => switch (trend) {
        WeeklyTrend.improved => PdfStyle.green,
        WeeklyTrend.worse => PdfStyle.red,
        _ => PdfStyle.amber,
      };

  static pw.Widget _verdict(WeeklyComparison c) {
    final color = _trendColor(c.trend);
    final label = switch (c.trend) {
      WeeklyTrend.improved => 'BETTER THAN LAST WEEK',
      WeeklyTrend.worse => 'HARDER THAN LAST WEEK',
      WeeklyTrend.mixed => 'MIXED WEEK',
      WeeklyTrend.stable => 'ABOUT THE SAME',
      WeeklyTrend.noPrevious => 'FIRST WEEK ON RECORD',
    };

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 1.4),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 15, color: color)),
          pw.SizedBox(height: 4),
          pw.Text(c.headline, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  static String _value(double? value, String unit) {
    if (value == null) return 'no data';
    final text = value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
    return '$text$unit';
  }

  static pw.Widget _comparisonTable(WeeklyComparison c) {
    const center = pw.Alignment.center;

    return pw.Table(
      border: const pw.TableBorder(
        horizontalInside: pw.BorderSide(color: PdfStyle.soft, width: 0.8),
        bottom: pw.BorderSide(color: PdfStyle.soft, width: 0.8),
      ),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(1.6),
        2: pw.FlexColumnWidth(1.6),
        3: pw.FlexColumnWidth(1.4),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfStyle.soft),
          children: [
            PdfStyle.cell('', color: PdfStyle.purple),
            PdfStyle.cell('Week before', color: PdfStyle.purple, align: center),
            PdfStyle.cell('This week', color: PdfStyle.purple, align: center),
            PdfStyle.cell('Result', color: PdfStyle.purple, align: center),
          ],
        ),
        for (final m in c.metrics)
          pw.TableRow(
            children: [
              PdfStyle.cell(m.label),
              PdfStyle.cell(_value(m.before, m.unit), align: center),
              PdfStyle.cell(_value(m.after, m.unit), align: center),
              _resultCell(m),
            ],
          ),
      ],
    );
  }

  static pw.Widget _resultCell(MetricChange m) {
    if (!m.comparable) {
      return PdfStyle.cell('-',
          color: PdfStyle.muted, align: pw.Alignment.center);
    }

    final (text, color) = switch (m.trend) {
      MetricTrend.better => ('Better', PdfStyle.green),
      MetricTrend.worse => ('Worse', PdfStyle.red),
      MetricTrend.same => ('Same', PdfStyle.muted),
    };
    return PdfStyle.cell(text, color: color, align: pw.Alignment.center);
  }

  static pw.Widget _takeaways(WeeklyComparison c) {
    final better = [
      for (final m in c.metrics)
        if (m.trend == MetricTrend.better) m.label.toLowerCase(),
    ];
    final worse = [
      for (final m in c.metrics)
        if (m.trend == MetricTrend.worse) m.label.toLowerCase(),
    ];

    if (better.isEmpty && worse.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        PdfStyle.title('What changed'),
        if (better.isNotEmpty)
          pw.Text(
            'Improved: ${better.join(', ')}.',
            style: const pw.TextStyle(fontSize: 10.5, color: PdfStyle.green),
          ),
        if (worse.isNotEmpty)
          pw.Text(
            'Needs attention: ${worse.join(', ')}.',
            style: const pw.TextStyle(fontSize: 10.5, color: PdfStyle.red),
          ),
      ],
    );
  }

  static pw.Widget _dayTable(WeekStats week) {
    const center = pw.Alignment.center;

    return pw.Table(
      border: const pw.TableBorder(
        horizontalInside: pw.BorderSide(color: PdfStyle.soft, width: 0.8),
        bottom: pw.BorderSide(color: PdfStyle.soft, width: 0.8),
      ),
      columnWidths: const {
        0: pw.FlexColumnWidth(2.2),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1.4),
        3: pw.FlexColumnWidth(1.2),
        4: pw.FlexColumnWidth(1.2),
        5: pw.FlexColumnWidth(1.4),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfStyle.soft),
          children: [
            for (final h in ['Day', 'Tasks', 'Mood', 'Sleep', 'Meals', 'Hard'])
              PdfStyle.cell(
                h,
                color: PdfStyle.purple,
                align: h == 'Day' ? pw.Alignment.centerLeft : center,
              ),
          ],
        ),
        for (final r in week.dayRows)
          pw.TableRow(
            children: [
              PdfStyle.cell(
                '${_weekdays[r.day.weekday - 1]} ${r.day.day}/${r.day.month}',
              ),
              PdfStyle.cell('${r.tasks}', align: center),
              PdfStyle.cell(r.mood ?? '-', align: center),
              PdfStyle.cell(
                r.sleepHours == null ? '-' : '${_value(r.sleepHours, '')} h',
                align: center,
              ),
              PdfStyle.cell(r.meals == null ? '-' : '${r.meals}/3',
                  align: center),
              PdfStyle.cell(
                '${r.hardMoments}',
                color: r.hardMoments > 0 ? PdfStyle.red : PdfStyle.dark,
                align: center,
              ),
            ],
          ),
      ],
    );
  }

  static List<pw.Widget> _details(WeekStats week) {
    pw.Widget line(String text) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 2),
          child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
        );

    return [
      PdfStyle.title('Details'),
      line('Points earned: ${week.points}'),
      line(
        week.moodCounts.isEmpty
            ? 'Mood check-ins: none this week.'
            : 'Mood check-ins: ${week.moodCounts.entries.map((e) => '${e.key} ${e.value}').join(', ')}.',
      ),
      if (week.topTasks.isNotEmpty)
        line(
          'Most completed tasks: '
          '${week.topTasks.map((t) => '${t.$1} (${t.$2})').join(', ')}.',
        ),
      if (week.triggerTexts.isNotEmpty)
        line('Before hard moments: ${week.triggerTexts.join('; ')}.'),
      if (week.noteTexts.isNotEmpty) ...[
        pw.SizedBox(height: 4),
        PdfStyle.title('From school'),
        for (final note in week.noteTexts) line('- $note'),
      ],
    ];
  }
}
