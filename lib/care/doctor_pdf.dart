import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../reports/pdf_style.dart';
import 'doctor_report.dart';

/// The doctor report as a PDF. It uses the same text as the copyable
/// report, so the two always say the same thing.
class DoctorPdf {
  const DoctorPdf._();

  static Future<Uint8List> build({
    required DoctorReportData data,
    required ByteData fontData,
  }) async {
    final font = pw.Font.ttf(fontData);
    final lines = DoctorReport.build(data).split('\n');

    final doc = pw.Document(
      title: 'Doctor report - ${data.childName}',
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
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfStyle.soft,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Report for the doctor',
                  style: const pw.TextStyle(
                    fontSize: 18,
                    color: PdfStyle.purple,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '${data.childName}, age ${data.childAge}',
                  style: const pw.TextStyle(fontSize: 12, color: PdfStyle.dark),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          ..._body(lines),
        ],
      ),
    );

    return doc.save();
  }

  /// A heading is an all-capitals line that follows a blank line.
  static bool _isHeading(String line, bool afterBlank) =>
      afterBlank &&
      line.isNotEmpty &&
      line == line.toUpperCase() &&
      line != line.toLowerCase();

  static List<pw.Widget> _body(List<String> lines) {
    final widgets = <pw.Widget>[];
    var afterBlank = false;

    // The first lines (title, date, notice) come before the first heading.
    for (final line in lines) {
      if (line.trim().isEmpty) {
        afterBlank = true;
        continue;
      }

      if (_isHeading(line, afterBlank)) {
        widgets
          ..add(pw.SizedBox(height: 10))
          ..add(PdfStyle.title(line));
      } else {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Text(
              line,
              style: const pw.TextStyle(fontSize: 10.5, color: PdfStyle.dark),
            ),
          ),
        );
      }
      afterBlank = false;
    }

    return widgets;
  }
}
