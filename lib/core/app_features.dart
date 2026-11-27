/// Switches for features that are built but not ready to be shown.
class AppFeatures {
  const AppFeatures._();

  /// SMS verification needs an Android phone running "SMS Gateway for
  /// Android" (see SMS_SETUP.md in the backend repository). Set this to
  /// true once the backend is configured to send SMS.
  static const bool smsVerification = false;

  /// The parent's "QR for the child's own phone" button. The code and the
  /// child's scan screen are built; the button is hidden until after the
  /// discussion. Set this to true to bring it back.
  static const bool parentChildQr = false;
}
