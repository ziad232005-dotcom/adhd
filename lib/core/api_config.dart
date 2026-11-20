import 'package:flutter/foundation.dart';

/// Where the backend lives.
///
/// The default address only works in the Android emulator (10.0.2.2 is the
/// computer running it). For a real phone or a release build run with
/// `--dart-define=API_BASE_URL=https://your-server`.
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5187',
  );

  /// Plain http sends codes and emails readable to anyone on the network,
  /// so release builds only talk to https servers.
  static bool get canConnect => !kReleaseMode || baseUrl.startsWith('https://');

  static Uri uri(String path) => Uri.parse('$baseUrl$path');
}
