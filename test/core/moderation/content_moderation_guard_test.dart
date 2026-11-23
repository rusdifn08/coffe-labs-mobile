import 'package:coffee_hub_mobile/core/moderation/content_moderation_guard.dart';
import 'package:coffee_hub_mobile/services/social_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ContentModerationGuard - Multilingual Profanity Engine', () {
    test('Blocks profanity across Indonesian, regional languages, English, and 13+ global languages', () {
      const blockedSamples = [
        // Indonesia & Daerah
        'bangsat lu',
        'dasar kontol',
        'memek',
        'ngentot',
        'jancok tenan',
        'jancuk',
        'anjing lo',
        'bajingan tengik',
        'keparat',
        'brengsek',
        'pukimak',
        'pantek',
        'lonte',
        'goblok banget',
        'tolol',
        'asu',
        // English
        'fuck',
        'what the fuck is this',
        'motherfucker',
        'bullshit',
        'bitch',
        'cunt',
        'asshole',
        'bastard',
        // Filipino / Tagalog
        'putangina mo',
        'gago ka',
        'tarantado',
        // Spanish & Portuguese
        'mierda',
        'pendejo',
        'hijo de puta',
        'caralho',
        'porra',
        // French, German, Italian
        'putain de merde',
        'scheisse',
        'scheiße',
        'arschloch',
        'hurensohn',
        'vaffanculo',
        'stronzo',
        // Russian (Latin & Cyrillic)
        'cyka blyat',
        'блять',
        'сука',
        'пиздец',
        // Korean (Romanized & Hangul)
        'shibal',
        '씨발',
        '개새끼',
        // Japanese
        'kusoyaro',
        'くそ',
        '死ね',
        // Chinese
        'caonima',
        '操你妈',
        '傻逼',
        // Arabic
        'sharmouta',
        'شرموطة',
        'كس امك',
        // Hindi
        'madarchod',
        'bhenchod',
        'मादरचोद',
        // Turkish & Polish & Gambling Spam
        'siktir git',
        'orospu',
        'kurwa',
        'slot gacor maxwin88',
      ];

      for (final sample in blockedSamples) {
        final verdict = ContentModerationGuard.inspect(sample);
        expect(
          verdict.isAllowed,
          isFalse,
          reason: 'Expected profanity to be blocked: "$sample"',
        );
        expect(verdict.reasonCode, 'PROFANITY_DETECTED');
        expect(verdict.userMessage, isNotEmpty);
      }
    });

    test('Defeats leetspeak, repeated characters, wildcards, spacing evasion, and zero-width chars', () {
      const evasionSamples = [
        'k0nt0l',
        'b4ngs4t',
        '@nj1ng',
        '5h1t',
        'fuuuuuuuck',
        'kontooooool',
        'scheiiiiisse',
        'vaffffanculo',
        'f u c k',
        'k.o.n.t.o.l',
        'b-a-n-g-s-a-t',
        'a n j i n g',
        'f*ck',
        'k*nt*l',
        'b*ngs*t',
        'sh*t',
        'm*m*k',
        'f\u200Bu\u200Bc\u200Bk',
        'k\u200Bo\u200Bn\u200Bt\u200Bo\u200Bl',
      ];

      for (final sample in evasionSamples) {
        expect(
          ContentModerationGuard.containsProfanity(sample),
          isTrue,
          reason: 'Expected obfuscated profanity to be caught: "$sample"',
        );
      }
    });

    test('Zero false positives on legitimate Indonesian & English specialty coffee text', () {
      const cleanCoffeeSamples = [
        'V60 Kintamani classic pour over 15g/240ml suhu 92C',
        'Proses memekarkan bloom 35 detik lalu analisis TDS 1.38%',
        'Rasa passion fruit manis, cocok dan suka banget!',
        'Masuk akal, kasus ekstraksi bitter bisa diatasi dengan grind size lebih halus',
        'Send a pic of your espresso extraction, love that citrus bite!',
        'Tangkai daun kopi di pantai Bali, bintang lima!',
        'Metode Multi-Pour Neo Brew (2026) 20g kopi 300ml air 96C',
        'Selamat datang semuanya di komunitas Social Coffee!',
        'Mengocok carafe perlahan agar aroma floral keluar',
        'Asuransi pengiriman biji kopi roasted dari Aceh Gayo & Flores Bajawa',
      ];

      for (final sample in cleanCoffeeSamples) {
        final verdict = ContentModerationGuard.inspect(sample);
        expect(
          verdict.isAllowed,
          isTrue,
          reason: 'False positive on legitimate coffee text: "$sample"',
        );
      }
    });

    test('Service layer rejects profane Social Coffee posts & comments with ContentModerationException', () async {
      await expectLater(
        () => SocialService.createPost(content: 'fuck'),
        throwsA(isA<ContentModerationException>()),
      );
      await expectLater(
        () => SocialService.createPost(content: 'k.o.n.t.o.l'),
        throwsA(isA<ContentModerationException>()),
      );
      await expectLater(
        () => SocialService.addComment('post-1', 'dasar bangsat'),
        throwsA(isA<ContentModerationException>()),
      );
    });

    test('Defensive display sanitizer masks legacy profanity while keeping clean words intact', () {
      final masked = ContentModerationGuard.sanitizeForDisplay('Halo bangsat apa kabar');
      expect(masked.toLowerCase(), isNot(contains('bangsat')));
      expect(masked, contains('Halo'));
      expect(masked, contains('apa kabar'));
    });
  });
}
