import 'dart:convert';
import 'dart:io';

import '../core/api_client.dart';
import 'shadow_application.dart';
import 'shadow_models.dart';

/// Sends the form and loads the approved Shadow Teachers.
class ShadowApi {
  const ShadowApi();

  static const _client = ApiClient();

  /// Sends the form with its documents and returns the reference number.
  Future<int> apply(ShadowApplication app) async {
    final documents = <Map<String, dynamic>>[];
    for (final doc in app.documents.values) {
      final path = doc.path;
      if (path == null) {
        throw ApiException('Add "${doc.fileName}" again, it was not saved.');
      }
      final File file = File(path);
      if (!await file.exists()) {
        throw ApiException('Add "${doc.fileName}" again, it was not found.');
      }
      documents.add({
        'kind': doc.kind,
        'fileName': doc.fileName,
        'certificateName': doc.certificateName,
        'issuer': doc.issuer,
        'number': doc.number,
        'obtainedOn': doc.obtainedOn?.toIso8601String(),
        'data': base64Encode(await file.readAsBytes()),
      });
    }

    String? photo;
    final photoPath = app.photoPath;
    if (photoPath != null && await File(photoPath).exists()) {
      photo = base64Encode(await File(photoPath).readAsBytes());
    }

    final body = await _client.post('/api/shadows', {
      'fullName': app.fullName,
      'birthDate': app.birthDate?.toIso8601String(),
      'mobile': app.mobile,
      'email': app.email,
      'governorate': app.governorate,
      'qualification': app.qualification,
      'university': app.university,
      'faculty': app.faculty,
      'department': app.department,
      'graduationYear': app.graduationYear,
      'yearsExperience': app.yearsExperience,
      'currentWorkplace': app.currentWorkplace,
      'previousWorkplaces': app.previousWorkplaces,
      'childExperience': app.childExperience,
      'adhdExperience': app.adhdExperience,
      'skills': app.skills,
      'photo': photo,
      'documents': documents,
    });

    final id = body['id'];
    if (id is! int) {
      throw const ApiException('The server sent something unexpected.');
    }
    return id;
  }

  /// Only teachers the admin approved are returned.
  Future<List<ShadowListing>> approved() async {
    final body = await _client.get('/api/shadows');
    return [
      for (final item in body['shadows'] as List<dynamic>? ?? [])
        if (ShadowListing.fromJson(item) case final listing?) listing,
    ];
  }
}
