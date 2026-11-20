import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';

/// A short code and how long it lasts.
class ShortCode {
  const ShortCode(this.code, this.lifetime);

  final String code;
  final Duration lifetime;

  /// "ABCD-EFGH", easier to read out and type.
  String get pretty => '${code.substring(0, 4)}-${code.substring(4)}';
}

/// The server could not do what was asked; [message] is fit to show.
class LinkException implements Exception {
  const LinkException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Talks to the backend that swaps a short code for the data in the QR code.
class LinkApi {
  const LinkApi();

  static const _timeout = Duration(seconds: 10);

  /// Sends [payload] (the text of the QR code) and returns a short code.
  Future<ShortCode> create(String payload) async {
    final body = await _post('/api/link/create', {'payload': payload});
    final code = body['code'];
    final seconds = body['expiresInSeconds'];
    if (code is! String || code.length != 8 || seconds is! int) {
      throw const LinkException('The server sent something unexpected.');
    }
    return ShortCode(code, Duration(seconds: seconds));
  }

  /// Returns the text that the QR code would have carried.
  Future<String> claim(String code) async {
    final body = await _post('/api/link/claim', {'code': code});
    final payload = body['payload'];
    if (payload is! String) {
      throw const LinkException('The server sent something unexpected.');
    }
    return payload;
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    if (!ApiConfig.canConnect) {
      throw const LinkException('The server address is not secure (https).');
    }

    final http.Response response;
    try {
      response = await http
          .post(
            ApiConfig.uri(path),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const LinkException('The server did not answer. Try again.');
    } catch (_) {
      throw const LinkException(
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
      throw const LinkException('Too many tries. Wait a minute and retry.');
    }
    if (response.statusCode != 200 || json == null) {
      throw LinkException(
        json?['message'] as String? ?? 'Something went wrong. Try again.',
      );
    }
    return json;
  }
}
