import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static AudioPlayer? _bgmPlayer;
  static final AudioPlayer _sfxPlayer = AudioPlayer(playerId: 'coffee_sfx');
  static final AudioPlayer _tickPlayer = AudioPlayer(playerId: 'coffee_tick');
  static bool _isInitialized = false;
  static bool _shouldBePlayingBgm = false;
  static StreamSubscription<PlayerState>? _bgmStateSub;

  // Track favorit pengguna: Chill Coffee Lounge
  static const String chillTrackPath = 'audio/calm_music.m4a';
  static const String currentTrackTitle = 'Chill Coffee Lounge';

  // Audio context: Jangan meminta Audio Focus eksklusif agar SFX & BGM bisa overlap tanpa saling memutus
  static final AudioContext _bgmContext = AudioContext(
    android: const AudioContextAndroid(
      isSpeakerphoneOn: false,
      stayAwake: true,
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.media,
      audioFocus: AndroidAudioFocus.none,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: const {
        AVAudioSessionOptions.mixWithOthers,
      },
    ),
  );

  static final AudioContext _sfxContext = AudioContext(
    android: const AudioContextAndroid(
      isSpeakerphoneOn: false,
      stayAwake: false,
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.assistanceSonification,
      audioFocus: AndroidAudioFocus.none,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.ambient,
      options: const {
        AVAudioSessionOptions.mixWithOthers,
      },
    ),
  );

  static Future<void> _initContext() async {
    if (_isInitialized) return;
    try {
      await AudioPlayer.global.setAudioContext(_bgmContext);
      await _sfxPlayer.setAudioContext(_sfxContext);
      await _sfxPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _tickPlayer.setAudioContext(_sfxContext);
      await _tickPlayer.setPlayerMode(PlayerMode.lowLatency);
      _isInitialized = true;
    } catch (e) {
      debugPrint('⚠️ AudioService._initContext warning: $e');
    }
  }

  static Future<void> playClick() async {
    try {
      await _initContext();
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/click.wav'), volume: 0.5);
      ensureBgmPlaying();
    } catch (_) {}
  }

  static Future<void> playTick() async {
    try {
      await _initContext();
      await _tickPlayer.stop();
      await _tickPlayer.play(AssetSource('audio/tick.wav'), volume: 0.6);
      ensureBgmPlaying();
    } catch (_) {}
  }

  static Future<void> playTransition() async {
    try {
      await _initContext();
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/transition.wav'), volume: 0.85);
      ensureBgmPlaying();
    } catch (_) {}
  }

  static Future<void> playEnjoy() async {
    try {
      await _initContext();
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/enjoy.wav'), volume: 1.0);
    } catch (_) {}
  }

  /// Memulai pemutaran musik santai 'Chill Coffee Lounge' saat menyeduh
  static Future<void> startBgm() async {
    try {
      await _initContext();
      _shouldBePlayingBgm = true;

      // Bersihkan player lama jika ada
      if (_bgmPlayer != null) {
        await _bgmStateSub?.cancel();
        _bgmStateSub = null;
        await _bgmPlayer?.stop();
        await _bgmPlayer?.dispose();
        _bgmPlayer = null;
      }

      final player = AudioPlayer(playerId: 'coffee_bgm');
      _bgmPlayer = player;
      await player.setAudioContext(_bgmContext);
      await player.setPlayerMode(PlayerMode.mediaPlayer);
      await player.setReleaseMode(ReleaseMode.loop);

      // Auto-resume jika OS Android mencoba menghentikan BGM saat transisi step atau countdown tick
      _bgmStateSub = player.onPlayerStateChanged.listen((state) {
        if (_shouldBePlayingBgm && state == PlayerState.paused) {
          debugPrint('☕ AudioService: Auto-resuming BGM after OS interrupt');
          player.resume();
        }
      });

      await player.play(AssetSource(chillTrackPath), volume: 0.55);
      debugPrint('☕ AudioService: Memutar $currentTrackTitle ($chillTrackPath)');
    } catch (e) {
      debugPrint('⚠️ AudioService.startBgm error: $e');
    }
  }

  /// Memastikan BGM tetap aktif & berputar jika sempat di-pause oleh sistem
  static void ensureBgmPlaying() {
    if (_shouldBePlayingBgm && _bgmPlayer != null) {
      if (_bgmPlayer!.state == PlayerState.paused) {
        _bgmPlayer!.resume();
      }
    }
  }

  /// Menghentikan BGM dan membersihkan alokasi native player
  static Future<void> stopBgm() async {
    _shouldBePlayingBgm = false;
    try {
      await _bgmStateSub?.cancel();
      _bgmStateSub = null;
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
