import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static AudioPlayer? _bgmPlayer;
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static final AudioPlayer _tickPlayer = AudioPlayer();

  static final List<Map<String, String>> chillTracks = [
    {'title': 'Chill Coffee Lounge', 'path': 'audio/calm_music.m4a'},
    {'title': 'Morning Lo-Fi Harmony', 'path': 'audio/chill_lofi_morning.wav'},
    {'title': 'Rainy Day Barista Jazz', 'path': 'audio/barista_rainy_day.wav'},
    {'title': 'Zen Flow Meditation', 'path': 'audio/zen_brew_meditation.wav'},
    {'title': 'Acoustic Sunrise Vibes', 'path': 'audio/acoustic_coffee_vibes.wav'},
  ];

  static int _currentTrackIndex = 0;
  static String currentTrackTitle = 'Chill Coffee Lounge';

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

  /// Memulai pemutaran musik santai saat seduh kopi (acak otomatis & loop)
  /// Menyelesaikan bug freeze/silent pada brew kedua dengan dispose & fresh allocation.
  static Future<void> startBgm({int? specificIndex}) async {
    try {
      await stopBgm();

      if (chillTracks.isEmpty) return;

      _currentTrackIndex = specificIndex ?? Random().nextInt(chillTracks.length);
      final track = chillTracks[_currentTrackIndex];
      currentTrackTitle = track['title'] ?? 'Relaxing Brew';

      _bgmPlayer = AudioPlayer();
      await _bgmPlayer!.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer!.play(AssetSource(track['path']!), volume: 0.55);
      debugPrint('☕ AudioService: Memutar BGM "$currentTrackTitle" (${track['path']})');
    } catch (e) {
      debugPrint('⚠️ AudioService.startBgm error: $e');
    }
  }

  /// Pindah ke musik santai berikutnya saat sedang menyeduh
  static Future<String> nextTrack() async {
    _currentTrackIndex = (_currentTrackIndex + 1) % chillTracks.length;
    await startBgm(specificIndex: _currentTrackIndex);
    return currentTrackTitle;
  }

  /// Menghentikan BGM dan membersihkan alokasi native player
  static Future<void> stopBgm() async {
    try {
      if (_bgmPlayer != null) {
        await _bgmPlayer!.stop();
        await _bgmPlayer!.dispose();
        _bgmPlayer = null;
      }
    } catch (e) {
      debugPrint('⚠️ AudioService.stopBgm error: $e');
    }
  }
}
