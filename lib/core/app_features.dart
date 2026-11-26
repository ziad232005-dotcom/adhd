/// Switches for features that are built but not ready to be shown.
class AppFeatures {
  const AppFeatures._();

  /// SMS verification needs an Android phone running "SMS Gateway for
  /// Android" (see SMS_SETUP.md in the backend repository). Set this to
  /// true once the backend is configured to send SMS.
  static const bool smsVerification = false;

  /// Tasks the parent writes by hand will need the admin's approval, which
  /// is not built yet. Until then the parent picks from the ready tasks.
  static const bool customTasks = false;
}
