import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A calm background sound while the child focuses or breathes. It is made
/// for this app (sounds/calm_loop.wav) and repeats without a gap. The child
/// can turn it off; the choice is remembered.
class Ambient extends ChangeNotifier {
  Ambient._();

  static final Ambient instance = Ambient._();

  static const asset = 'sounds/calm_loop.wav';
  static const _prefsKey = 'mazid_ambient_on';

  AudioPlayer? _player;
  bool _enabled = true;
  bool _loaded = false;

  bool get enabled => _enabled;

  Future<void> _load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool(_prefsKey) ?? true;
    } catch (_) {
      // The default is kept.
    }
    // The player looks inside "assets/" unless told otherwise.
    AudioCache.instance = AudioCache(prefix: '');
  }

  Future<void> toggle() async {
    await _load();
    _enabled = !_enabled;
    notifyListeners();
    if (!_enabled) await pause();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, _enabled);
    } catch (_) {
      // Not remembering is fine.
    }
  }

  /// Starts the sound, or continues it after a pause. Never throws.
  Future<void> start() async {
    try {
      await _load();
      if (!_enabled) return;

      final player = _player ??= AudioPlayer();
      if (player.state == PlayerState.paused) {
        await player.resume();
        return;
      }
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource(asset), volume: 0.35);
    } catch (e) {
      debugPrint('Could not play the calm sound: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _player?.pause();
    } catch (_) {
      // Nothing to pause.
    }
  }

  Future<void> stop() async {
    try {
      await _player?.stop();
    } catch (_) {
      // Nothing to stop.
    }
  }
}
