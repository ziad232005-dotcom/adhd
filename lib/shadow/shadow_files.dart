import 'package:file_picker/file_picker.dart';

/// A PDF the person chose.
class PickedPdf {
  const PickedPdf({required this.name, required this.sizeBytes, this.path});

  final String name;
  final int sizeBytes;
  final String? path;
}

/// Opens the system file picker for certificates.
/// Keeping it here means a change of picker package touches one file.
class ShadowFiles {
  const ShadowFiles._();

  static const int maxBytes = 10 * 1024 * 1024;

  /// Returns null when the person cancels.
  static Future<PickedPdf?> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    return PickedPdf(name: file.name, sizeBytes: file.size, path: file.path);
  }
}
