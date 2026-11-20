/// Switches for features that are built but not ready to be shown.
class AppFeatures {
  const AppFeatures._();

  /// SMS verification needs an Android phone running "SMS Gateway for
  /// Android" (see SMS_SETUP.md in the backend repository). Set this to
  /// true once the backend is configured to send SMS.
  static const bool smsVerification = false;

  /// Demo helpers for the graduation demo: an "Admin review" entry on the
  /// role screen and a button that lets a sample teacher accept a request.
  ///
  /// They let anyone approve themselves as a verified Shadow Teacher, so
  /// they exist only in debug builds. For a demo from a release build run
  /// with `--dart-define=DEMO_MODE=true`. Remove them when a real backend
  /// handles reviews and accounts.
  static const bool demoMode = bool.fromEnvironment(
    'DEMO_MODE',
    defaultValue: !bool.fromEnvironment('dart.vm.product'),
  );
}
