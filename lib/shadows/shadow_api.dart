import '../core/api_client.dart';
import 'shadow_models.dart';

/// Sends applications and loads the approved Shadow Teachers.
class ShadowApi {
  const ShadowApi();

  static const _client = ApiClient();

  /// Returns the reference number of the application.
  Future<int> apply(ShadowApplication application) async {
    final body = await _client.post('/api/shadows', application.toJson());
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
