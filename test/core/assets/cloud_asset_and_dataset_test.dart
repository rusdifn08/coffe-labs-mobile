import 'dart:convert';
import 'package:coffee_hub_mobile/core/assets/cloud_asset_manager.dart';
import 'package:coffee_hub_mobile/core/assets/cloud_dataset_service.dart';
import 'package:coffee_hub_mobile/core/network/backend_endpoint_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CloudAssetManager', () {
    test('detects offloaded cloud media vs local boot assets', () {
      expect(
        CloudAssetManager.isCloudAsset('assets/images/beans/mknd_aceh_gayo.jpg'),
        isTrue,
      );
      expect(
        CloudAssetManager.isCloudAsset('assets/images/avatars/covers/james_hoffmann.jpg'),
        isTrue,
      );
      expect(
        CloudAssetManager.isCloudAsset('assets/images/avatars/portraits/tetsu_kasuya.jpg'),
        isTrue,
      );
      expect(
        CloudAssetManager.isCloudAsset('assets/images/roasteries/mknd_logo.png'),
        isTrue,
      );
      expect(
        CloudAssetManager.isCloudAsset('assets/images/methods/hario_v60.png'),
        isTrue,
      );
      expect(
        CloudAssetManager.isCloudAsset('assets/audio/calm_music.m4a'),
        isTrue,
      );

      // Local lightweight boot assets stay bundled in APK
      expect(
        CloudAssetManager.isCloudAsset('assets/images/coffee_labs_logo.png'),
        isFalse,
      );
      expect(
        CloudAssetManager.isCloudAsset('assets/images/characters/avatar_1.png'),
        isFalse,
      );
      expect(
        CloudAssetManager.isCloudAsset('assets/audio/click.wav'),
        isFalse,
      );
    });

    test('resolves primary CDN and fallback mirror URLs cleanly', () {
      final urls = CloudAssetManager.resolveCandidateUrls(
        'assets/images/beans/mknd_aceh_gayo.jpg',
      );
      expect(urls.length, greaterThanOrEqualTo(2));
      expect(
        urls.first,
        endsWith('/images/beans/mknd_aceh_gayo.jpg'),
      );
      expect(urls.first, startsWith('https://'));
      expect(urls[1], contains('raw.githubusercontent.com'));
    });

    test('RuntimeEndpointManifest parses asset_cdn_base_url', () {
      final manifest = RuntimeEndpointManifest.fromJson({
        'schema_version': 2,
        'manifest_revision': 2,
        'primary_api_url': 'https://api.coffelabs.id',
        'asset_cdn_base_url': 'https://assets.coffelabs.id/r2',
        'asset_cdn_fallback_urls': ['https://cdn.jsdelivr.net/gh/rusdifn08/coffe-labs-mobile@main/cloud_assets'],
      });
      expect(manifest.assetCdnBaseUrl, 'https://assets.coffelabs.id/r2');
      expect(manifest.assetCdnFallbackUrls.length, 1);
    });
  });

  group('CloudDatasetService', () {
    test('decompresses all 8 gzipped datasets cleanly from cloud_assets/data', () {
      const keys = [
        'coffee',
        'coffee_dictionary_seed',
        'coffee_knowledge_graph',
        'ebooks_catalog_seed',
        'indonesia_radar_top_places',
        'initial_classes',
        'lms_manual_brew_seed',
        'world_indonesia_beans_catalog',
      ];
      for (final key in keys) {
        final raw = CloudDatasetService.loadDatasetSyncForTest(key);
        expect(raw, isNotNull, reason: 'Dataset $key must decompress cleanly');
        expect(raw!.isNotEmpty, isTrue);
        final decoded = jsonDecode(raw);
        expect(decoded, isNotNull);
      }
    });
  });
}
