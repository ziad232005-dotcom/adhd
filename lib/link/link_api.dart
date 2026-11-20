import '../core/api_client.dart';

/// A short code and how long it lasts.
class ShortCode {
  const ShortCode(this.code, this.lifetime);

  final String code;
  final Duration lifetime;

  /// "ABCD-EFGH", easier to read out and type.
  String get pretty => '${code.substring(0, 4)}-${code.substring(4)}';
}

/// Talks to the backend that swaps a short code for the data in the QR code.
class LinkApi {
  const LinkApi();

  static const _client = ApiClient();

  /// Sends [payload] (the text of the QR code) and returns a short code.
  Future<ShortCode> create(String payload) async {
    final body = await _client.post('/api/link/create', {'payload': payload});
    final code = body['code'];
    final seconds = body['expiresInSeconds'];
    if (code is! String || code.length != 8 || seconds is! int) {
      throw const ApiException('The server sent something unexpected.');
    }
    return ShortCode(code, Duration(seconds: seconds));
  }

  /// Returns the text that the QR code would have carried.
  Future<String> claim(String code) async {
    final body = await _client.post('/api/link/claim', {'code': code});
    final payload = body['payload'];
    if (payload is! String) {
      throw const ApiException('The server sent something unexpected.');
    }
    return payload;
  }
}
