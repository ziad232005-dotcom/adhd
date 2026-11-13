/// App-wide configuration values.
abstract final class AppConfig {
  /// Backend address. `10.0.2.2` is how the Android emulator reaches the
  /// host machine running the ASP.NET Core backend.
  static const String apiBaseUrl = 'http://10.0.2.2:5187';

  /// How long to wait for a backend response.
  static const Duration requestTimeout = Duration(seconds: 20);

  /// Number of digits in the verification code.
  static const int otpLength = 6;

  /// Seconds the user must wait before requesting a new verification code.
  static const int otpResendCooldownSeconds = 60;
}
