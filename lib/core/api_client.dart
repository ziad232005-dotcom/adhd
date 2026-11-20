import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

/// The server could not do what was asked; [message] is fit to show.
class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Small JSON client for the MAZID backend. Every failure becomes an
/// [ApiException] with a message the person can read.
class ApiClient {
  const ApiClient();

  static const _timeout = Duration(seconds: 15);

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) =>
      _send(
        () => http.post(
          ApiConfig.uri(path),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        ),
      );

  Future<Map<String, dynamic>> get(String path) =>
      _send(() => http.get(ApiConfig.uri(path)));

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request,
  ) async {
    if (!ApiConfig.canConnect) {
      throw const ApiException('The server address is not secure (https).');
    }

    final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on TimeoutException {
      throw const ApiException('The server did not answer. Try again.');
    } catch (_) {
      throw const ApiException(
        'Could not reach the server. Check the internet and try again.',
      );
    }

    Map<String, dynamic>? json;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) json = decoded;
    } catch (_) {
      json = null;
    }

    if (response.statusCode == 429) {
      throw const ApiException('Too many tries. Wait a minute and retry.');
    }
    if (response.statusCode != 200 || json == null) {
      throw ApiException(
        json?['message'] as String? ?? 'Something went wrong. Try again.',
      );
    }
    return json;
  }
}
