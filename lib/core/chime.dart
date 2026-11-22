import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// A soft two-note bell for the end of focus time and of the calm minute.
/// The sound is made for this app (sounds/chime.wav), so it has no licence
/// to worry about. A phone that cannot play it simply stays quiet.
class Chime {
  const Chime._();

  static const asset = 'sounds/chime.wav';

  static AudioPlayer? _player;

  static Future<void> play() async {
    try {
      final player = _player ??= AudioPlayer();
      await player.stop();
      await player.play(AssetSource(asset), volume: 0.6);
    } catch (e) {
      debugPrint('Could not play the chime: $e');
    }
  }
}
