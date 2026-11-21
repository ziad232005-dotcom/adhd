import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../parent/parent_ui.dart';
import 'report_library.dart';

/// Shows a PDF that is stored in the reports folder. The parent can read,
/// print or send it from here.
class SavedReportScreen extends StatelessWidget {
  const SavedReportScreen({
    super.key,
    required this.childId,
    required this.childName,
    required this.report,
  });

  final int childId;
  final String childName;
  final SavedReport report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, report.title),
      body: FutureBuilder<Uint8List>(
        future: ReportLibrary.instance.read(childId, report),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'This report file could not be opened. Go back and make it again.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final bytes = snapshot.data!;

          return PdfPreview(
            build: (_) => bytes,
            pdfFileName: 'MAZID-$childName-${report.fileName}',
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
            previewPageMargin: const EdgeInsets.all(8),
          );
        },
      ),
    );
  }
}
