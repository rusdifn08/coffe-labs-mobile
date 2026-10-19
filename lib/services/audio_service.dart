import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static final AudioPlayer _tickPlayer = AudioPlayer();

  static Future<void> playClick() async {
    try {
      await _sfxPlayer.play(AssetSource('audio/click.wav'), volume: 0.5);
    } catch (_) {
      // Ignore
    }
  }

  static Future<void> playTick() async {
    try {
      await _tickPlayer.play(AssetSource('audio/tick.wav'), volume: 0.7);
    } catch (_) {
      // Ignore
    }
  }

  static Future<void> playTransition() async {
    try {
      await _sfxPlayer.play(AssetSource('audio/transition.wav'), volume: 1.0);
    } catch (_) {
      // Ignore
    }
  }

  static Future<void> playEnjoy() async {
    try {
      await _sfxPlayer.play(AssetSource('audio/enjoy.wav'), volume: 1.0);
    } catch (_) {
      // Ignore
    }
  }

  static Future<void> startBgm() async {
    try {
      _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(AssetSource('audio/calm_music.m4a'), volume: 0.6);
    } catch (_) {
      // Ignore
    }
  }

  static Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
    } catch (_) {
      // Ignore
    }
  }
}
