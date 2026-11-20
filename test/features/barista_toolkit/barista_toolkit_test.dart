import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:coffee_hub_mobile/features/barista_toolkit/data/barista_toolkit_api_service.dart';
import 'package:coffee_hub_mobile/features/barista_toolkit/data/barista_toolkit_seed_data.dart';
import 'package:coffee_hub_mobile/features/barista_toolkit/data/ebook_drm_vault_service.dart';
import 'package:coffee_hub_mobile/features/barista_toolkit/data/lms_video_session_manager.dart';
import 'package:coffee_hub_mobile/features/barista_toolkit/domain/barista_toolkit_models.dart';
import 'package:coffee_hub_mobile/features/barista_toolkit/presentation/brew_doctor/brew_doctor_compass_screen.dart';
import 'package:coffee_hub_mobile/features/barista_toolkit/presentation/ebook_reader/coffee_dictionary_az_screen.dart';
import 'package:coffee_hub_mobile/features/barista_toolkit/presentation/ebook_reader/ebook_library_screen.dart';
import 'package:coffee_hub_mobile/features/barista_toolkit/presentation/ebook_reader/encrypted_ebook_reader_screen.dart';
import 'package:coffee_hub_mobile/features/barista_toolkit/presentation/game_brew/game_brew_v60_screen.dart';
import 'package:coffee_hub_mobile/features/barista_toolkit/presentation/lms_academy/barista_lms_courses_screen.dart';
import 'package:coffee_hub_mobile/features/barista_toolkit/presentation/lms_academy/lms_course_player_screen.dart';
import 'package:coffee_hub_mobile/screens/toolkit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Modul 2.1 Barista Toolkit & Learning Brew Suite', () {
    testWidgets('ToolkitScreen renders Learning Brew section with 4 compact cards',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ToolkitScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Learning Brew'), findsOneWidget);
      expect(find.text('4 MODUL'), findsOneWidget);
      expect(find.text('Game Brew V60'), findsOneWidget);
      expect(find.text('Pustaka E-Book DRM'), findsOneWidget);
      expect(find.text('Akademi Barista LMS'), findsOneWidget);
      expect(find.text('Brew Doctor & Kompas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('Lms100BitTracker enforces 85% anti-skip Hamming weight accurately', () {
      final tracker = Lms100BitTracker();
      for (int i = 0; i < 84; i++) {
        tracker.markSegment(i);
      }
      expect(tracker.completedSegments, 84);
      expect(tracker.isAntiSkipThresholdMet, isFalse);

      tracker.markSegment(84);
      expect(tracker.completedSegments, 85);
      expect(tracker.isAntiSkipThresholdMet, isTrue);
      expect(tracker.toBase64(), isNotEmpty);
    });

    test('Brew Doctor sensory matrix classifies Sour, Bitter, Channeling & Golden Cup',
        () {
      final sour = BaristaToolkitApiService.diagnoseOfflineFallback(
        symptomTags: ['sour'],
        doseG: 15,
        waterMl: 225,
        tempC: 88,
        targetSec: 150,
        actualSec: 115,
      );
      expect(sour.diagnosisCode, 'UNDER_EXTRACTED');
      expect(sour.grindClicksDelta, -2);
      expect(sour.tempCDelta, 2);

      final bitter = BaristaToolkitApiService.diagnoseOfflineFallback(
        symptomTags: ['bitter', 'astringent'],
        doseG: 15,
        waterMl: 225,
        tempC: 96,
        targetSec: 150,
        actualSec: 210,
      );
      expect(bitter.diagnosisCode, 'OVER_EXTRACTED');
      expect(bitter.grindClicksDelta, 2);
      expect(bitter.tempCDelta, -2);

      final channeling = BaristaToolkitApiService.diagnoseOfflineFallback(
        symptomTags: ['sour', 'bitter'],
        doseG: 15,
        waterMl: 225,
        tempC: 92,
        targetSec: 150,
        actualSec: 150,
      );
      expect(channeling.diagnosisCode, 'UNEVEN_CHANNELING');
    });

    test(
        'APK stays lightweight without bundled binaries and Vault AES-256-GCM decrypts & zeroizes RAM',
        () async {
      // Pastikan APK tidak dibebani binary .clbook/.pdf/.epub di assets/ebooks
      final ebooksDir = Directory('assets/ebooks');
      if (await ebooksDir.exists()) {
        final heavyFiles = await ebooksDir
            .list(recursive: true)
            .where(
              (e) =>
                  e is File &&
                  (e.path.endsWith('.clbook') ||
                      e.path.endsWith('.pdf') ||
                      e.path.endsWith('.epub')),
            )
            .toList();
        expect(heavyFiles, isEmpty);
      }

      final vault = EncryptedEbookVaultService.instance;
      const testCode = 'CL-BOOK-UNIT-TEST';
      final cek = vault.deriveBundledTrialCek(testCode);
      final fakePdf = Uint8List.fromList(utf8.encode('%PDF-1.7\n%CoffeeLabsVault\n'));
      final encrypted = await vault.encryptPayloadInIsolate(
        payload: fakePdf,
        cekBytes: cek,
      );

      await vault.saveDownloadedBookPackage(
        bookCode: testCode,
        clbookBytes: encrypted,
        chaptersAst: const [
          EbookChapterAstModel(
            id: 'ch-1',
            chapterNumber: 1,
            titleId: 'Hukum Darcy',
            blocks: [
              EbookDocBlock(
                blockId: 'b-1',
                blockType: 'paragraph',
                textId: 'Aliran perkolasi V60.',
              ),
            ],
          ),
        ],
      );

      expect(await vault.isBookDownloadedOffline(testCode), isTrue);
      final cachedClbk = await vault.readCachedClbookBytes(testCode);
      expect(cachedClbk, isNotNull);

      final decryptedPdf = await vault.decryptClbookInIsolate(
        clbookBytes: cachedClbk!,
        cekBytes: vault.deriveBundledTrialCek(testCode),
      );
      expect(String.fromCharCodes(decryptedPdf.take(5)), '%PDF-');

      EncryptedEbookVaultService.zeroizeBuffer(decryptedPdf);
      expect(decryptedPdf.every((b) => b == 0), isTrue);

      // Verifikasi tampering gagal autentikasi AES-GCM
      final tampered = Uint8List.fromList(cachedClbk);
      tampered[tampered.length - 1] ^= 0xFF;
      expect(
        () => vault.decryptClbookInIsolate(
          clbookBytes: tampered,
          cekBytes: vault.deriveBundledTrialCek(testCode),
        ),
        throwsA(anything),
      );

      EncryptedEbookVaultService.zeroizeBuffer(cek);
      await vault.deleteOfflineBook(testCode);
    });

    test(
        'Offline seed provides 9 LMS courses, 30 detailed subchapters, 12 ebooks, 120+ dictionary terms & 5 Game Brew chapters',
        () async {
      final syncCourses = BaristaToolkitFallbackSeed.offlineCourses();
      expect(syncCourses.length, 9);

      final fullCourses = await BaristaToolkitFallbackSeed.loadOfflineCoursesAsync();
      expect(fullCourses.length, 9);
      final totalLessons =
          fullCourses.fold<int>(0, (sum, c) => sum + c.lessons.length);
      expect(totalLessons, 30);

      final ebooks = await BaristaToolkitFallbackSeed.offlineEbooks();
      expect(ebooks.length, 12);

      final dict = await BaristaToolkitFallbackSeed.offlineDictionary();
      expect(dict.length, greaterThanOrEqualTo(120));

      final chapters = BaristaToolkitFallbackSeed.offlineChapters();
      expect(chapters.length, 5);
      expect(
        chapters.any((c) => (c.physicsConfig['drop_temp_c'] as num?) == 70),
        isTrue,
      );
    });

    testWidgets(
        'GameBrewV60Screen, BaristaLmsCoursesScreen (9 Bab), LmsCoursePlayerScreen, BrewDoctor & EbookLibrary render cleanly at 375x780',
        (tester) async {
      tester.view.physicalSize = const Size(375, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: GameBrewV60Screen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Game Brew V60: Kedai Senja'), findsOneWidget);
      expect(find.text('Tetes Pertama di Kedai Senja'), findsOneWidget);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: BaristaLmsCoursesScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Akademi Barista LMS'), findsOneWidget);
      expect(LmsProgramTrack.catalog.length, 5);
      expect(
        LmsProgramTrack.catalog.where((p) => p.isComingSoon).length,
        4,
      );
      expect(find.text('Sains & Teknik Manual Brew'), findsOneWidget);
      expect(find.text('TERSEDIA'), findsOneWidget);
      expect(
        find.text('Bab 1: Sains Fundamental Ekstraksi, Kimia Air & Termodinamika'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);

      // Verifikasi kartu Coming Soon muncul & menampilkan pratinjau modul saat diketuk
      final espressoCard =
          find.byKey(const Key('lms_program_card_espresso_milk_science'));
      await tester.scrollUntilVisible(espressoCard, 250);
      await tester.pumpAndSettle();
      expect(find.text('Espresso Engineering & Milk Science'), findsOneWidget);
      expect(find.text('COMING SOON'), findsWidgets);
      await tester.tap(espressoCard);
      await tester.pumpAndSettle();
      expect(find.text('Pratinjau Modul yang Sedang Disusun'), findsOneWidget);
      await tester.tap(find.text('Mengerti'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Verifikasi kartu ke-5 (paling bawah) juga ter-render bersih
      final businessCard =
          find.byKey(const Key('lms_program_card_post_harvest_cafe_business'));
      await tester.scrollUntilVisible(businessCard, 300);
      await tester.pumpAndSettle();
      expect(
        find.text('Green Coffee Processing & Cafe Business'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      // Scroll kembali ke Card 1 lalu buka Silabus Sains & Teknik Manual Brew
      final manualBrewCard =
          find.byKey(const Key('lms_program_card_manual_brew_science'));
      await tester.scrollUntilVisible(manualBrewCard, -300);
      await tester.pumpAndSettle();
      await tester.tap(manualBrewCard);
      await tester.pumpAndSettle();
      expect(find.text('LMS Kurikulum Manual Brew'), findsOneWidget);
      expect(
        find.text('Bab 1: Sains Fundamental Ekstraksi, Kimia Air & Termodinamika'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      // Kembali dari Silabus ke Katalog 5 Kartu LMS
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Akademi Barista LMS'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final courses = await BaristaToolkitFallbackSeed.loadOfflineCoursesAsync();
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: LmsCoursePlayerScreen(
              course: courses.first,
              lesson: courses.first.lessons.first,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Lab Simulasi Interaktif'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: BrewDoctorCompassScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Brew Doctor & Kompas SCA'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Buka Brew Timer dengan Parameter Baru'),
        200,
      );
      expect(find.text('Buka Brew Timer dengan Parameter Baru'), findsOneWidget);

      await tester.runAsync(() async {
        await BaristaToolkitFallbackSeed.offlineEbooks();
        await BaristaToolkitFallbackSeed.offlineDictionary();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: EbookLibraryScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pustaka E-Book DRM'), findsOneWidget);
      expect(
        find.text('On-Demand Object Storage • APK Ringan'),
        findsOneWidget,
      );
      expect(find.text('CL-BOOK-01'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: CoffeeDictionaryAzScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Kamus Kopi A–Z (Buku #8)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'EncryptedEbookReaderScreen shows Back button, Tri-Mode bar & navigates back when tapped',
        (tester) async {
      const sampleBook = EbookCatalogItem(
        id: 'b0010001-0000-4000-8000-000000000002',
        bookCode: 'CL-BOOK-02',
        title: 'Physics of V60 Percolation',
        author: 'Dr. Jonathan',
        synopsis: 'Fluid Dynamics',
        category: 'EXTRACTION_PHYSICS',
        requiredTier: 'Trial',
        isUnlocked: true,
        totalPages: 5,
        fileSizeBytes: 1024,
        sha256CiphertextHash: 'abc',
        tocChapters: [
          EbookTocChapter(title: 'Bab 1: Hukum Darcy', startPage: 2),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const EncryptedEbookReaderScreen(ebook: sampleBook),
                      ),
                    ),
                    child: const Text('Buka Ebook'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Ebook'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.byIcon(Icons.toc_rounded), findsOneWidget);
      expect(find.text('Editorial'), findsOneWidget);
      expect(find.text('EPUB3'), findsOneWidget);
      expect(find.text('PDF 120Hz'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Buka Ebook'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test(
      'LmsVideoSessionManager enforces safe Windows S/W config (prevents ANGLE Surface.cpp:528 crash) & guards session tokens',
      () {
        final winCfg = LmsVideoSessionManager.buildVideoControllerConfig(isWindows: true);
        expect(winCfg.enableHardwareAcceleration, isFalse);
        expect(winCfg.hwdec, 'no');
        expect(winCfg.width, 960);
        expect(winCfg.height, 540);

        final mobileCfg = LmsVideoSessionManager.buildVideoControllerConfig(isWindows: false);
        expect(mobileCfg.enableHardwareAcceleration, isTrue);

        expect(LmsVideoSessionManager.computeWindowsSwSize(1920, 1080), (960, 540));
        expect(LmsVideoSessionManager.computeWindowsSwSize(1280, 720), (960, 540));
        expect(LmsVideoSessionManager.computeWindowsSwSize(640, 360), (640, 360));

        // Token ownership safety during pushReplacement
        final mgr = LmsVideoSessionManager.instance;
        final t1 = mgr.acquireSession();
        expect(mgr.isTokenActive(t1), isTrue);

        final t2 = mgr.acquireSession();
        expect(mgr.isTokenActive(t1), isFalse);
        expect(mgr.isTokenActive(t2), isTrue);

        // Stale dispose of Screen 1 must NOT invalidate Screen 2's active session
        mgr.releaseSession(t1);
        expect(mgr.isTokenActive(t2), isTrue);

        // Releasing active Screen 2 invalidates t2 cleanly
        mgr.releaseSession(t2);
        expect(mgr.isTokenActive(t2), isFalse);
      },
    );

    testWidgets(
      'LmsCoursePlayerScreen opens and navigates Back cleanly without errors or leaked timers',
      (tester) async {
        final courses = await BaristaToolkitFallbackSeed.loadOfflineCoursesAsync();
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => LmsCoursePlayerScreen(
                            course: courses.first,
                            lesson: courses.first.lessons.first,
                          ),
                        ),
                      ),
                      child: const Text('Buka LMS Bab 1.1'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Buka LMS Bab 1.1'));
        await tester.pumpAndSettle();
        expect(find.text('Lab Simulasi Interaktif'), findsOneWidget);

        // Tap Back button -> should pop immediately without crash/exception
        await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Buka LMS Bab 1.1'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
