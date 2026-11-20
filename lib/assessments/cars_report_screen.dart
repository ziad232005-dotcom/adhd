import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:printing/printing.dart';

import '../parent/parent_store.dart';
import '../parent/parent_ui.dart';
import 'cars_models.dart';
import 'cars_pdf.dart';
import 'cars_store.dart';

/// The CARS report as a PDF the parent can read, save, print or send.
/// It compares the result with the assessment before it.
class CarsReportScreen extends StatelessWidget {
  const CarsReportScreen({
    super.key,
    required this.child,
    required this.result,
  });

  final ParentChild child;
  final CarsResult result;

  Future<Uint8List> _build() async {
    final font = await rootBundle.load('fonts/Cairo-Regular.ttf');

    return CarsPdf.build(
      childName: child.name,
      childAge: child.age,
      current: result,
      history: carsStore.of(child.id),
      fontData: font,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, 'CARS report'),
      body: PdfPreview(
        build: (_) => _build(),
        pdfFileName: 'MAZID-CARS-${child.name}.pdf',
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
