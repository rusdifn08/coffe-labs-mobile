import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_hub_mobile/features/brew/tts/voice_text_normalizer.dart';
import 'package:coffee_hub_mobile/features/brew/tts/brewing_tts_service.dart';

void main() {
  group('VoiceTextNormalizer & Barista Persona', () {
    test('normalizes technical recipe text into natural conversational Indonesian with English coffee phonetics', () {
      const raw = '1. Double-Weight Bloom. Tuang 30ml air (2x berat kopi) pada suhu 90°C–91°C, tunggu 35s untuk pelepasan gas CO2 maksimal.';
      final normalized = VoiceTextNormalizer.normalizeInstruction(raw);

      expect(normalized, contains('Tahap satu'));
      expect(normalized, contains('Dabel Weit Blum'));
      expect(normalized, contains('30 mililiter air'));
      expect(normalized, contains('dua kali berat kopi'));
      expect(normalized, contains('90 sampai 91 derajat celcius'));
      expect(normalized, contains('35 detik'));
      expect(normalized, contains('karbon dioksida'));
      expect(normalized, isNot(contains('CO2')));
      expect(normalized, isNot(contains('ml')));
    });

    test('phoneticizes English coffee loanwords for authentic pronunciation', () {
      const rawEnglish = 'Steady Circle Main Pour, pastikan tidak ada channeling dan tunggu drawdown selesai sebelum final pour.';
      final spoken = VoiceTextNormalizer.normalizeInstruction(rawEnglish);

      // 'Pour' becomes 'por', 'Steady Circle Main Pour' becomes 'Stedi Serkel Mein Por'
      expect(spoken, contains('Stedi Serkel Mein Por'));
      expect(spoken, contains('tseneling'));
      expect(spoken, contains('drodaun'));
      expect(spoken.toLowerCase(), contains('fainel por'));
      expect(spoken, isNot(contains('pour')));
    });

    test('builds complete step prompt with title, pour grams, temperature, and full description', () {
      final prompt = VoiceTextNormalizer.buildStepPrompt(
        title: '1. Blooming',
        instruction: 'Tuang 45g air 90°C secara perlahan di area tengah until luar tanpa menyentuh kertas filter.',
        stepIndex: 0,
        stepWaterGrams: 45,
        cumulativeWaterGrams: 45,
        waterTempCelsius: 90,
        durationSeconds: 30,
      );

      expect(prompt, contains('Tahap satu'));
      expect(prompt, contains('bluming'));
      expect(prompt, contains('45 gram air'));
      expect(prompt, contains('90 derajat celcius'));
      expect(prompt, contains('secara perlahan di area tengah hingga luar tanpa menyentuh kertas filter'));
      expect(prompt, isNot(contains('until')));
    });

    test('builds next step announcement with 5-second transition cue', () {
      final prompt = VoiceTextNormalizer.buildStepPrompt(
        title: '2. Center Pour',
        instruction: 'Tuang 60g air fokus di tengah.',
        stepIndex: 1,
        stepWaterGrams: 60,
        cumulativeWaterGrams: 105,
        waterTempCelsius: 91,
        durationSeconds: 30,
        isNextStep: true,
      );

      expect(prompt, contains('Bersiap tahap dua'));
      expect(prompt, contains('Senter Por'));
      expect(prompt, contains('60 gram air'));
    });

    test('splits long step prompts into clean speech chunks under 150 characters', () {
      final longPrompt = VoiceTextNormalizer.buildStepPrompt(
        title: '2. Osmotic Center Pour',
        instruction:
            'Tuang 105g air suhu 90°C fokus tepat di titik tengah kubah kopi dengan ketinggian 3cm dari permukaan bubuk kopi hingga timbangan mencapai 150g dalam waktu 55 detik.',
        stepIndex: 1,
        stepWaterGrams: 105,
        cumulativeWaterGrams: 150,
        waterTempCelsius: 90,
        durationSeconds: 55,
      );

      final chunks = VoiceTextNormalizer.splitIntoSpeechChunks(longPrompt);
      expect(chunks, isNotEmpty);
      for (final chunk in chunks) {
        expect(chunk.length, lessThanOrEqualTo(150));
      }
    });

    test('normalizes ratios, microns, and gram weights', () {
      const raw = 'Rasio 1:15 dengan gilingan 900µm dan 15g bubuk kopi.';
      final normalized = VoiceTextNormalizer.normalizeInstruction(raw);

      expect(normalized, contains('satu banding 15'));
      expect(normalized, contains('900 mikron'));
      expect(normalized, contains('15 gram'));
    });

    test('converts countdown seconds to natural Indonesian spoken numbers', () {
      expect(VoiceTextNormalizer.countdownWord(5), equals('Lima'));
      expect(VoiceTextNormalizer.countdownWord(4), equals('Empat'));
      expect(VoiceTextNormalizer.countdownWord(3), equals('Tiga'));
      expect(VoiceTextNormalizer.countdownWord(2), equals('Dua'));
      expect(VoiceTextNormalizer.countdownWord(1), equals('Satu'));
    });

    test('verifies female barista voice persona tuning parameters', () {
      expect(BrewingTTSService.baristaPitch, inInclusiveRange(1.1, 1.2));
      expect(BrewingTTSService.baristaSpeechRate, inInclusiveRange(0.85, 0.95));
    });

    test('verifies platform speech rate prevents Android hyper-speed 1.72x glitch', () {
      final rate = BrewingTTSService.getPlatformSpeechRate();
      // On Windows test environment, rate is calibrated to 0.38
      // On Android it will be 0.44 (0.88 / 2), preventing the 2.0f multiplier from accelerating to 1.76x
      expect(rate, lessThanOrEqualTo(0.5));
      expect(rate, greaterThanOrEqualTo(0.35));
    });
  });
}
