import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:printing/printing.dart';

import '../parent/parent_ui.dart';
import 'tova_pdf.dart';
import 'tova_record.dart';

/// The TOVA activity report as a PDF the parent can read, save, print or
/// send. It compares the result with the previous activity of the same kind.
class TovaReportScreen extends StatelessWidget {
  const TovaReportScreen({
    super.key,
    required this.childName,
    required this.childAge,
    required this.record,
    required this.history,
  });

  final String childName;
  final int childAge;
  final TovaRecord record;
  final List<TovaRecord> history;

  Future<Uint8List> _build() async {
    final font = await rootBundle.load('fonts/Cairo-Regular.ttf');

    return TovaPdf.build(
      childName: childName,
      childAge: childAge,
      current: record,
      history: history,
      fontData: font,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, 'TOVA report'),
      body: PdfPreview(
        build: (_) => _build(),
        pdfFileName: 'MAZID-TOVA-$childName.pdf',
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        previewPageMargin: const EdgeInsets.all(8),
        onError: (context, error) => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'The report could not be created. Please try again.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
