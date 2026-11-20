import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Colors and small building blocks shared by the PDF reports.
class PdfStyle {
  const PdfStyle._();

  static const purple = PdfColor.fromInt(0xFF6C4BD6);
  static const dark = PdfColor.fromInt(0xFF30285E);
  static const muted = PdfColor.fromInt(0xFF6F6A87);
  static const soft = PdfColor.fromInt(0xFFF0EDFF);
  static const green = PdfColor.fromInt(0xFF2E9E6B);
  static const red = PdfColor.fromInt(0xFFD64545);
  static const amber = PdfColor.fromInt(0xFFB7791F);
  static const amberSoft = PdfColor.fromInt(0xFFFFF4DB);

  static pw.Widget title(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Text(
          text,
          style: const pw.TextStyle(fontSize: 13, color: purple),
        ),
      );

  static pw.Widget cell(
    String text, {
    PdfColor color = dark,
    double size = 9.5,
    pw.Alignment align = pw.Alignment.centerLeft,
  }) {
    return pw.Container(
      alignment: align,
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: pw.Text(text, style: pw.TextStyle(fontSize: size, color: color)),
    );
  }

  static pw.Widget notice(String text) => pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: amberSoft,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Text(
          text,
          style: const pw.TextStyle(fontSize: 9.5, color: amber),
        ),
      );
}
