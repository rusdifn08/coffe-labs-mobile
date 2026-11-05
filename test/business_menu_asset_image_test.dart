import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_hub_mobile/features/business_pos/widgets/business_menu_asset_image.dart';
import 'package:coffee_hub_mobile/models/business_pos_models.dart';

void main() {
  group('BusinessMenuAssetImage Widget Tests', () {
    testWidgets('renders fallback icon when assetUrl is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BusinessMenuAssetImage(
              assetUrl: '',
              assetFormat: 'PNG',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.local_cafe), findsOneWidget);
    });

    testWidgets('renders fallback icon gracefully when local file does not exist', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BusinessMenuAssetImage(
              assetUrl: 'C:/non_existent_file_path_12345.png',
              assetFormat: 'PNG',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.local_cafe), findsOneWidget);
    });

    testWidgets('renders local file image if file exists on disk', (tester) async {
      final tempDir = Directory.systemTemp.createTempSync();
      final tempFile = File('${tempDir.path}/test_coffee.png');
      tempFile.writeAsBytesSync([0x89, 0x50, 0x4E, 0x47]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BusinessMenuAssetImage(
              assetUrl: tempFile.path,
              assetFormat: 'PNG',
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);

      tempFile.deleteSync();
      tempDir.deleteSync();
    });

    testWidgets('renders memory image when assetUrl is a base64 PNG Data URI', (tester) async {
      // 1x1 transparent PNG byte array in base64
      const transparentPngBase64 =
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BusinessMenuAssetImage(
              assetUrl: transparentPngBase64,
              assetFormat: 'PNG',
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.local_cafe), findsNothing);
    });

    testWidgets('renders SVG when assetUrl is an SVG Data URI', (tester) async {
      final svgDataUrl =
          'data:image/svg+xml;base64,${base64Encode(utf8.encode('<svg width="10" height="10"><rect width="10" height="10" fill="red"/></svg>'))}';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BusinessMenuAssetImage(
              assetUrl: svgDataUrl,
              assetFormat: 'SVG',
            ),
          ),
        ),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.byIcon(Icons.local_cafe), findsNothing);
    });

    testWidgets('renders memory image when assetUrl is a raw base64 PNG string', (tester) async {
      // Base64 without data: prefix
      const rawPngBase64 =
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BusinessMenuAssetImage(
              assetUrl: rawPngBase64,
              assetFormat: 'PNG',
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.local_cafe), findsNothing);
    });

    testWidgets('gracefully falls back when base64 is corrupted', (tester) async {
      const corruptBase64 = 'data:image/png;base64,!!!NotValidBase64Data###';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BusinessMenuAssetImage(
              assetUrl: corruptBase64,
              assetFormat: 'PNG',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.local_cafe), findsOneWidget);
    });
  });

  group('BusinessMenuItem Model & Logic Tests', () {
    test('showInAod and showInPos default and override cleanly', () {
      const item = BusinessMenuItem(
        id: 'capp_1',
        storeId: 'store_1',
        name: 'Cappuchino',
        description: 'Mantap terbaik pokonyamah',
        category: 'Signature Coffee',
        priceCents: 25000,
        assetUrl: 'C:/menu_123.png',
        assetFormat: 'PNG',
        showInAod: false,
        showInPos: true,
      );

      expect(item.showInAod, isFalse);
      expect(item.showInPos, isTrue);

      final toggled = item.copyWith(showInAod: true);
      expect(toggled.showInAod, isTrue);
      expect(toggled.showInPos, isTrue);

      final json = item.toJson();
      expect(json['show_in_aod'], isFalse);
      expect(json['show_in_pos'], isTrue);

      final restored = BusinessMenuItem.fromJson(json);
      expect(restored.showInAod, isFalse);
      expect(restored.showInPos, isTrue);
    });
  });
}
