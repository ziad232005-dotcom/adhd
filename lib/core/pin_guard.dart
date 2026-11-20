/// Slows down someone who guesses a PIN. After a few wrong tries the PIN
/// is locked for a while, and each lock lasts twice as long as the one
/// before (up to 15 minutes). A 4-digit PIN has only 10,000 possibilities,
/// so without this it could be found by trying them all.
class PinGuard {
  PinGuard({
    this.maxAttempts = 5,
    this.firstLock = const Duration(seconds: 30),
    this.longestLock = const Duration(minutes: 15),
  });

  /// One guard per child, kept while the app runs, so closing and opening
  /// the PIN screen does not reset the count.
  static final Map<int, PinGuard> _byChild = {};

  static PinGuard forChild(int childId) =>
      _byChild.putIfAbsent(childId, PinGuard.new);

  final int maxAttempts;
  final Duration firstLock;
  final Duration longestLock;

  int _wrongInRow = 0;
  int _locks = 0;
  DateTime? _lockedUntil;

  /// Time left until another try is allowed, or null when it is allowed.
  Duration? lockRemaining([DateTime? now]) {
    final until = _lockedUntil;
    if (until == null) return null;

    final left = until.difference(now ?? DateTime.now());
    return left > Duration.zero ? left : null;
  }

  /// Checks a PIN. Returns false for a wrong PIN and also while locked
  /// (the right PIN is not accepted during a lock).
  bool attempt(String entered, String correct, [DateTime? now]) {
    final time = now ?? DateTime.now();
    if (lockRemaining(time) != null) return false;

    if (entered == correct) {
      _wrongInRow = 0;
      _locks = 0;
      _lockedUntil = null;
      return true;
    }

    _wrongInRow++;
    if (_wrongInRow >= maxAttempts) {
      final seconds = firstLock.inSeconds * (1 << _locks.clamp(0, 10));
      final lock = Duration(
        seconds: seconds > longestLock.inSeconds
            ? longestLock.inSeconds
            : seconds,
      );
      _lockedUntil = time.add(lock);
      _locks++;
      _wrongInRow = 0;
    }
    return false;
  }
}
