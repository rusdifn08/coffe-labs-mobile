import 'dart:typed_data';

import 'package:coffee_hub_mobile/features/roastery/controllers/roastery_catalog_controller.dart';
import 'package:coffee_hub_mobile/features/roastery/data/services/roastery_media_uploader.dart';
import 'package:coffee_hub_mobile/features/roastery/screens/business_roastery_studio_screen.dart';
import 'package:coffee_hub_mobile/features/roastery/screens/roastery_detail_screen.dart';
import 'package:coffee_hub_mobile/features/roastery/widgets/coffee_lineup_editor_sheet.dart';
import 'package:coffee_hub_mobile/models/roastery.dart';
import 'package:coffee_hub_mobile/screens/coffee_roastery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRoasteryCatalogController extends RoasteryCatalogController {
  final RoasteryCatalogState initialState;
  _FakeRoasteryCatalogController(this.initialState);

  @override
  RoasteryCatalogState build() => initialState;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> refreshCatalog() async {}

  @override
  Future<Roastery> fetchLatestDetail(Roastery current) async => current;
}

Roastery _sampleBusinessRoastery({
  String ownerId = 'user-biz-1',
  List<CoffeeLineupItem>? lineups,
}) {
  return Roastery(
    id: 'roastery-biz-1',
    ownerUserId: ownerId,
    slug: 'senja-sangrai-labs',
    name: 'Senja Sangrai Labs',
    location: 'Bandung',
    address: 'Jl. Dago No. 88, Bandung',
    latitude: -6.885,
    longitude: 107.613,
    description: 'Micro-roastery eksperimental fokus pada slow-roast filter & omni roast.',
    specialties: 'Anaerobic Natural & Competition Filter',
    cluster: 'Roastery Bisnis',
    imageUrl: 'assets/images/avatars/generic_fallback.jpg',
    whatsappNumber: '081234567890',
    instagramHandle: '@senjasangrai',
    rating: 4.9,
    salesHighlight: 'Fresh Roast Tiap Senin',
    isVerifiedBusiness: true,
    isPublished: true,
    totalLineupsCount: (lineups ?? const []).length,
    lineups: lineups ??
        const [
          CoffeeLineupItem(
            id: 'lineup-1',
            name: 'Pantan Musara Anaerobic',
            origin: 'Aceh Gayo, 1650 MDPL',
            roastProfile: 'Light to Medium',
            variety: 'Abyssinia, Timtim',
            process: 'Anaerobic Natural',
            tastingNotes: 'Blackberry Jam, Jasmine, Dark Cacao',
            netWeightGrams: 250,
            priceIdr: 189000,
            price100g: 'Rp75.600',
            price200g: 'Rp151.200',
            originalPackage: 'Asli: Rp189.000 / 250g',
            badge: 'Seasonal',
            recommendedBrewMethod: 'V60',
            recommendedTempC: 92,
            recommendedRatio: '1:15',
          ),
        ],
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('CoffeeLineupItem unit pricing math & JSON serialization work identically to Rust backend', () {
    final labels = CoffeeLineupItem.computeUnitLabels(250, 189000);
    expect(labels.price100g, 'Rp75.600');
    expect(labels.price200g, 'Rp151.200');
    expect(labels.originalPackage, 'Asli: Rp189.000 / 250g');

    final roastery = _sampleBusinessRoastery();
    final roundtrip = Roastery.fromJson(roastery.toJson());
    expect(roundtrip.id, roastery.id);
    expect(roundtrip.ownerUserId, 'user-biz-1');
    expect(roundtrip.isVerifiedBusiness, isTrue);
    expect(roundtrip.whatsappNumber, '081234567890');
    expect(roundtrip.lineups.length, 1);
    expect(roundtrip.lineups.first.price100g, 'Rp75.600');
  });

  test('RoasteryMediaUploader crops & compresses 16:9 photo to square 1:1 720px in background Isolate', () async {
    final source = img.Image(width: 1600, height: 900);
    img.fill(source, color: img.ColorRgb8(92, 58, 33));
    final sourceBytes = Uint8List.fromList(img.encodeJpg(source, quality: 90));

    final processed = await RoasteryMediaUploader.cropAndCompressInIsolate(
      sourceBytes: sourceBytes,
      targetAspectRatio: 1.0,
      maxDimension: 720,
    );

    final decoded = img.decodeImage(processed);
    expect(decoded, isNotNull);
    expect(decoded!.width, 720);
    expect(decoded.height, 720);
  });

  testWidgets('Tapping a roastery card opens full-screen RoasteryDetailScreen without bottom-sheet popup or overflow at 375x780',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final bizRoastery = _sampleBusinessRoastery();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          roasteryCatalogProvider.overrideWith(
            () => _FakeRoasteryCatalogController(
              RoasteryCatalogState(
                isLoading: false,
                isBusinessUser: false,
                businessRoasteries: [bizRoastery],
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: CoffeeRoasteryScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Senja Sangrai Labs'), findsOneWidget);
    expect(find.text('Roastery Bisnis'), findsOneWidget);

    await tester.tap(find.text('Senja Sangrai Labs'));
    await tester.pumpAndSettle();

    expect(find.byType(RoasteryDetailScreen), findsOneWidget);
    expect(find.text('Official Business Roastery'), findsOneWidget);
    expect(find.text('WhatsApp Roastery'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Pantan Musara Anaerobic'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Pantan Musara Anaerobic'), findsOneWidget);
    expect(find.text('Rp75.600 / 100g  •  Rp151.200 / 200g'), findsOneWidget);
    expect(find.text('Seduh'), findsOneWidget);
  });

  testWidgets('Non-Business user sees upgrade gate & Business user sees 1-roastery studio setup vs management',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // 1. Trial/Pro -> Upgrade gate
    await tester.pumpWidget(
      ProviderScope(
        key: const ValueKey('gate'),
        overrides: [
          roasteryCatalogProvider.overrideWith(
            () => _FakeRoasteryCatalogController(
              const RoasteryCatalogState(
                isLoading: false,
                isBusinessUser: false,
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: BusinessRoasteryStudioScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Eksklusif Coffee Labs Business'), findsOneWidget);
    expect(find.text('Upgrade ke Business (Rp 249.000)'), findsOneWidget);

    // 2. Business without roastery -> Registration wizard + Live Card Preview
    await tester.pumpWidget(
      ProviderScope(
        key: const ValueKey('wizard'),
        overrides: [
          roasteryCatalogProvider.overrideWith(
            () => _FakeRoasteryCatalogController(
              const RoasteryCatalogState(
                isLoading: false,
                isBusinessUser: true,
                currentUserId: 'user-biz-1',
                myRoastery: null,
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: BusinessRoasteryStudioScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('1 Akun Business = 1 Profil Roastery Resmi (Dapat diedit kapan saja)'),
      findsOneWidget,
    );
    expect(find.text('Pratinjau Kartu Direktori Anda'), findsOneWidget);

    // 3. Business already owns 1 roastery -> Manage Studio Dashboard
    final mine = _sampleBusinessRoastery();
    await tester.pumpWidget(
      ProviderScope(
        key: const ValueKey('manage'),
        overrides: [
          roasteryCatalogProvider.overrideWith(
            () => _FakeRoasteryCatalogController(
              RoasteryCatalogState(
                isLoading: false,
                isBusinessUser: true,
                currentUserId: 'user-biz-1',
                myRoastery: mine,
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: BusinessRoasteryStudioScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('+ Tambah Lineup Kopi Baru'), findsOneWidget);
    expect(find.text('Pantan Musara Anaerobic'), findsOneWidget);
    expect(find.text('Halaman Publik'), findsOneWidget);
  });

  testWidgets('CoffeeLineupEditorSheet renders smart price calculator and AI scan banner cleanly',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CoffeeLineupEditorSheet(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('✨ Auto-Isi dari Foto Kemasan (AI Scan)'),
      findsOneWidget,
    );
    // Scroll down ListView to verify Section 3 live smart pricing (250g + 135000 = Rp54.000 / 100g • Rp108.000 / 200g)
    await tester.scrollUntilVisible(
      find.text('Rp54.000 / 100g • Rp108.000 / 200g'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Rp54.000 / 100g • Rp108.000 / 200g'), findsOneWidget);
  });
}
