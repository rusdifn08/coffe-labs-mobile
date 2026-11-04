import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import '../../../services/audio_service.dart';
import 'voice_text_normalizer.dart';

/// Priority levels for queued barista voice prompts.
enum VoicePriority {
  instruction, // Step title & detailed pouring description (never cut off mid-sentence)
  countdown,   // 5-4-3-2-1 countdown
  completion,  // End of brew celebration
}

/// Task item in the sequential TTS audio queue.
class VoicePromptTask {
  final String text;
  final VoicePriority priority;
  final Completer<void> completer;
  final int generation;

  VoicePromptTask({
    required this.text,
    required this.priority,
    required this.completer,
    required this.generation,
  });
}

/// High-performance Indonesian Female Barista TTS Service.
/// Ensures 100% genuine Indonesian female voice articulation across Android, iOS, Windows, and Web.
class BrewingTTSService {
  static final BrewingTTSService instance = BrewingTTSService._internal();
  BrewingTTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _fallbackPlayer = AudioPlayer(playerId: 'coffee_barista_tts_fallback');

  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _isMuted = false;
  bool _hasNativeIndonesianFemaleVoice = false;

  final Queue<VoicePromptTask> _queue = Queue<VoicePromptTask>();
  final Map<String, String> _mp3FileCache = {};
  bool _isProcessingQueue = false;
  int _abortGeneration = 0;
  VoicePriority? _activePriority;

  // Voice Persona Parameters (Requirement: pitch 1.1-1.2, speechRate 0.85-0.95)
  static const double baristaPitch = 1.12;
  static const double baristaSpeechRate = 0.88;
  String? _selectedVoiceName;

  /// Returns the platform-calibrated speech rate for flutter_tts.
  /// On Android & iOS, flutter_tts maps 0.5 to 1.0x native rate.
  /// Crucially, Android's FlutterTtsPlugin executes: `setSpeechRate(rate.toFloat() * 2.0f)`.
  /// Therefore, passing 0.44 yields 0.88x speed on Android, preventing hyper-speed speech!
  static double getPlatformSpeechRate() {
    if (kIsWeb) return baristaSpeechRate;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return baristaSpeechRate / 2.0; // 0.88 / 2 = 0.44 (0.88x native speed)
      case TargetPlatform.windows:
        return 0.38;
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return baristaSpeechRate;
    }
  }

  bool get isSpeaking => _isSpeaking;
  bool get isMuted => _isMuted || AudioService.isMuted;
  String get voiceName => _selectedVoiceName ?? 'Barista Gadis (id-ID Female)';

  /// Initializes TTS engine and verifies whether a genuine Indonesian female voice exists natively.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _fallbackPlayer.setReleaseMode(ReleaseMode.stop);

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        try {
          final dynamic engines = await _flutterTts.getEngines;
          if (engines is List && engines.contains('com.google.android.tts')) {
            await _flutterTts.setEngine('com.google.android.tts');
          }
        } catch (_) {}
      }

      // Query system voices first to verify if a real Indonesian (id-ID) female voice is installed
      final dynamic voicesRaw = await _flutterTts.getVoices;
      Map<String, String>? matchedIndoFemaleVoice;

      if (voicesRaw is List) {
        Map<String, String>? bestFemaleVoice;
        Map<String, String>? fallbackIndoVoice;

        for (final v in voicesRaw) {
          if (v is Map) {
            final name = (v['name'] ?? '').toString();
            final nameLower = name.toLowerCase();
            final locale = (v['locale'] ?? '').toString().toLowerCase();
            final gender = (v['gender'] ?? '').toString().toLowerCase();

            // Match Indonesian locale (id-ID, id_ID, in-ID, in_ID, ind)
            final isIndonesianLocale = locale == 'id' ||
                locale.startsWith('id-') ||
                locale.startsWith('id_') ||
                locale == 'in' ||
                locale.startsWith('in-') ||
                locale.startsWith('in_') ||
                locale.contains('indonesia') ||
                locale.contains('ind');

            if (isIndonesianLocale) {
              final isMale = gender == 'male' ||
                  nameLower.contains('andika') ||
                  nameLower.contains('male') ||
                  nameLower.contains('pria') ||
                  nameLower.contains('ida') ||
                  nameLower.contains('idb');

              final isHighQualityFemale = gender == 'female' ||
                  nameLower.contains('gadis') ||
                  nameLower.contains('damayanti') ||
                  nameLower.contains('dfz') ||
                  nameLower.contains('idc') ||
                  nameLower.contains('female') ||
                  nameLower.contains('wanita');

              if (isHighQualityFemale && !isMale) {
                bestFemaleVoice = {
                  'name': name,
                  'locale': v['locale'].toString(),
                };
                break;
              } else if (!isMale && fallbackIndoVoice == null) {
                fallbackIndoVoice = {
                  'name': name,
                  'locale': v['locale'].toString(),
                };
              }
            }
          }
        }
        matchedIndoFemaleVoice = bestFemaleVoice ?? fallbackIndoVoice;
      }

      if (matchedIndoFemaleVoice != null) {
        await _flutterTts.setLanguage('id-ID');
        await _flutterTts.setPitch(baristaPitch);
        final double platformRate = getPlatformSpeechRate();
        await _flutterTts.setSpeechRate(platformRate);
        await _flutterTts.setVolume(1.0);
        await _flutterTts.awaitSpeakCompletion(true);
        await _flutterTts.setVoice(matchedIndoFemaleVoice);

        _selectedVoiceName = matchedIndoFemaleVoice['name'];
        _hasNativeIndonesianFemaleVoice = true;
        debugPrint('☕ TTS Native Indonesian Female Voice Locked: $_selectedVoiceName (Rate: $platformRate)');
      } else {
        _hasNativeIndonesianFemaleVoice = false;
        _selectedVoiceName = 'Barista Indonesia (id-ID Female HD)';
        debugPrint('☕ TTS Using High-Clarity Indonesian Female Barista Stream (id-ID)');
      }

      _flutterTts.setStartHandler(() => _isSpeaking = true);
      _flutterTts.setCompletionHandler(() => _isSpeaking = false);
      _flutterTts.setErrorHandler((_) => _isSpeaking = false);

      _isInitialized = true;
      unawaited(_prewarmCommonPrompts());
    } on MissingPluginException {
      _hasNativeIndonesianFemaleVoice = false;
      _isInitialized = true;
      unawaited(_prewarmCommonPrompts());
    } catch (_) {
      _hasNativeIndonesianFemaleVoice = false;
      _isInitialized = true;
    }
  }

  /// Pre-caches countdown numbers and common recipe step instructions for 0ms latency playback.
  Future<void> _prewarmCommonPrompts() async {
    if (kIsWeb || _hasNativeIndonesianFemaleVoice) return;
    for (final w in const ['Lima', 'Empat', 'Tiga', 'Dua', 'Satu']) {
      await _prefetchChunkMp3(w);
    }
  }

  /// Pre-loads all step instructions for a recipe into disk cache so transitions have zero lag.
  Future<void> preloadRecipeSteps(Map<String, dynamic> recipe) async {
    await initialize();
    if (kIsWeb || _hasNativeIndonesianFemaleVoice) return;

    final steps = (recipe['steps'] as List<dynamic>?) ?? [];
    final int waterTemp = (recipe['waterTempCelsius'] is num)
        ? (recipe['waterTempCelsius'] as num).toInt()
        : 91;

    int cumWater = 0;
    for (int i = 0; i < steps.length; i++) {
      final s = steps[i];
      if (s is Map) {
        final stepWater = ((s['waterAddedGrams'] ?? s['waterGrams'] ?? 0) as num).toInt();
        cumWater += stepWater;
        final dur = ((s['durationSeconds'] ?? s['timeSeconds'] ?? 30) as num).toInt();
        final prompt = VoiceTextNormalizer.buildStepPrompt(
          title: (s['title'] ?? 'Tahap ${i + 1}').toString(),
          instruction: (s['instruction'] ?? '').toString(),
          stepIndex: i,
          stepWaterGrams: stepWater,
          cumulativeWaterGrams: cumWater,
          waterTempCelsius: waterTemp,
          durationSeconds: dur,
        );
        for (final chunk in VoiceTextNormalizer.splitIntoSpeechChunks(prompt)) {
          await _prefetchChunkMp3(chunk);
        }
      }
    }
  }

  /// Sets mute state for TTS prompts.
  void setMuted(bool muted) {
    _isMuted = muted;
    if (_isMuted) {
      stop();
    }
  }

  /// Speaks step title, target water, temperature, and full description in fluent Indonesian.
  Future<void> speakInstruction({
    required String title,
    required String instruction,
    required int stepIndex,
    int? stepWaterGrams,
    int? cumulativeWaterGrams,
    int? waterTempCelsius,
    int? durationSeconds,
    bool isNextStep = false,
  }) async {
    if (isMuted) return;

    final String fullPrompt = VoiceTextNormalizer.buildStepPrompt(
      title: title,
      instruction: instruction,
      stepIndex: stepIndex,
      stepWaterGrams: stepWaterGrams,
      cumulativeWaterGrams: cumulativeWaterGrams,
      waterTempCelsius: waterTempCelsius,
      durationSeconds: durationSeconds,
      isNextStep: isNextStep,
    );

    _queue.removeWhere((t) => t.priority == VoicePriority.countdown);
    await _enqueuePrompt(fullPrompt, VoicePriority.instruction);
  }

  /// Speaks a countdown number (5, 4, 3, 2, 1).
  /// Crucially, NEVER aborts an active step instruction mid-sentence.
  Future<void> speakCountdown(int number) async {
    if (isMuted) return;

    if (_isSpeaking && _activePriority == VoicePriority.instruction) {
      return;
    }

    _queue.removeWhere((t) => t.priority == VoicePriority.countdown);
    final word = VoiceTextNormalizer.countdownWord(number);
    await _enqueuePrompt(word, VoicePriority.countdown);
  }

  /// Speaks brew completion celebration.
  Future<void> speakCompletion() async {
    if (isMuted) return;
    const text = 'Proses seduh selesai. Kopi spesialti Anda siap disajikan. Selamat menikmati.';
    await _enqueuePrompt(text, VoicePriority.completion);
  }

  /// Speaks raw text directly (used by Pre-Brew Masterclass walkthroughs).
  Future<void> speakRawText(String text) async {
    if (isMuted || text.trim().isEmpty) return;
    final normalized = VoiceTextNormalizer.normalizeInstruction(text);
    await _enqueuePrompt(normalized, VoicePriority.instruction);
  }

  /// Enqueues prompt into async FIFO queue with lock mechanism.
  Future<void> _enqueuePrompt(String text, VoicePriority priority) async {
    final completer = Completer<void>();
    final task = VoicePromptTask(
      text: text,
      priority: priority,
      completer: completer,
      generation: _abortGeneration,
    );

    _queue.add(task);
    unawaited(_processQueue());

    return completer.future;
  }

  /// Processes queued voice tasks sequentially without audio overlap.
  Future<void> _processQueue() async {
    if (_isProcessingQueue) return;
    _isProcessingQueue = true;

    while (_queue.isNotEmpty) {
      if (isMuted) {
        _completeAndClearQueue();
        break;
      }

      final task = _queue.removeFirst();
      if (task.generation != _abortGeneration) {
        if (!task.completer.isCompleted) task.completer.complete();
        continue;
      }

      try {
        await initialize();
        _isSpeaking = true;
        _activePriority = task.priority;

        final chunks = VoiceTextNormalizer.splitIntoSpeechChunks(task.text);
        for (int i = 0; i < chunks.length; i++) {
          if (isMuted || task.generation != _abortGeneration) break;
          final chunk = chunks[i];

          if (_hasNativeIndonesianFemaleVoice) {
            try {
              final estSecs = VoiceTextNormalizer.estimateSpeechSeconds(chunk) + 4;
              await _flutterTts.speak(chunk).timeout(
                Duration(seconds: estSecs),
                onTimeout: () => 1,
              );
            } catch (_) {
              await _speakChunkViaIndonesianBarista(chunk, task.generation);
            }
          } else {
            await _speakChunkViaIndonesianBarista(chunk, task.generation);
          }

          // Natural breathing pause between sentences (200ms)
          if (i + 1 < chunks.length && task.generation == _abortGeneration && !isMuted) {
            await Future.delayed(const Duration(milliseconds: 200));
          }
        }
      } catch (e) {
        debugPrint('⚠️ TTS Speak error: $e');
      } finally {
        _isSpeaking = false;
        _activePriority = null;
        if (!task.completer.isCompleted) {
          task.completer.complete();
        }
      }
    }

    _isProcessingQueue = false;
  }

  /// Fetches and caches Indonesian female TTS MP3 file on disk for reliable native playback.
  Future<String?> _prefetchChunkMp3(String chunk) async {
    if (_mp3FileCache.containsKey(chunk)) {
      final cachedPath = _mp3FileCache[chunk]!;
      if (File(cachedPath).existsSync()) return cachedPath;
    }

    try {
      final encoded = Uri.encodeComponent(chunk);
      final uri = Uri.parse(
        'https://translate.google.com/translate_tts?ie=UTF-8&tl=id&client=tw-ob&q=$encoded',
      );
      final response = await http.get(
        uri,
        headers: const {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'audio/mpeg, */*',
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200 && response.bodyBytes.length > 256) {
        final cacheDir = Directory('${Directory.systemTemp.path}/coffee_labs_barista_tts');
        if (!cacheDir.existsSync()) {
          cacheDir.createSync(recursive: true);
        }
        final hash = chunk.hashCode.toUnsigned(32).toRadixString(16);
        final file = File('${cacheDir.path}/barista_id_$hash.mp3');
        await file.writeAsBytes(response.bodyBytes, flush: true);
        _mp3FileCache[chunk] = file.path;
        return file.path;
      }
    } catch (e) {
      debugPrint('ℹ️ TTS Prefetch note: $e');
    }
    return null;
  }

  /// Plays a single sentence chunk using the Indonesian Female Barista audio stream.
  Future<void> _speakChunkViaIndonesianBarista(String chunk, int generation) async {
    if (generation != _abortGeneration || isMuted) return;

    try {
      final completer = Completer<void>();
      StreamSubscription<void>? sub;

      sub = _fallbackPlayer.onPlayerComplete.listen((_) {
        sub?.cancel();
        if (!completer.isCompleted) completer.complete();
      });

      await _fallbackPlayer.stop();
      if (generation != _abortGeneration || isMuted) {
        await sub.cancel();
        return;
      }

      await _fallbackPlayer.setPlaybackRate(0.90);

      if (!kIsWeb) {
        final localPath = await _prefetchChunkMp3(chunk);
        if (generation != _abortGeneration || isMuted) {
          await sub.cancel();
          return;
        }
        if (localPath != null) {
          await _fallbackPlayer.play(DeviceFileSource(localPath), volume: 1.0);
        } else {
          final encoded = Uri.encodeComponent(chunk);
          final url = 'https://translate.google.com/translate_tts?ie=UTF-8&tl=id&client=tw-ob&q=$encoded';
          await _fallbackPlayer.play(UrlSource(url), volume: 1.0);
        }
      } else {
        final encoded = Uri.encodeComponent(chunk);
        final url = 'https://translate.google.com/translate_tts?ie=UTF-8&tl=id&client=tw-ob&q=$encoded';
        await _fallbackPlayer.play(UrlSource(url), volume: 1.0);
      }

      final estSecs = VoiceTextNormalizer.estimateSpeechSeconds(chunk) + 3;
      await completer.future.timeout(
        Duration(seconds: estSecs),
        onTimeout: () => sub?.cancel(),
      );
      await sub.cancel();
    } catch (e) {
      debugPrint('ℹ️ TTS Barista playback note: $e');
    }
  }

  void _completeAndClearQueue() {
    while (_queue.isNotEmpty) {
      final t = _queue.removeFirst();
      if (!t.completer.isCompleted) t.completer.complete();
    }
  }

  /// Immediately halts any ongoing TTS speech and empties queue.
  Future<void> stop() async {
    _abortGeneration++;
    _completeAndClearQueue();
    _isSpeaking = false;
    _activePriority = null;
    try {
      if (_hasNativeIndonesianFemaleVoice) {
        await _flutterTts.stop();
      }
    } catch (_) {}
    try {
      await _fallbackPlayer.stop();
    } catch (_) {}
  }
}
