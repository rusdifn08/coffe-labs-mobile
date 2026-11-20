import 'package:coffee_hub_mobile/data/world_indonesia_beans_service.dart';
import 'package:coffee_hub_mobile/features/annotation_studio/domain/services/coffee_ocr_parser_service.dart';
import 'package:coffee_hub_mobile/features/bean_scanner/services/coffee_knowledge_graph_service.dart';
import 'package:coffee_hub_mobile/features/bean_scanner/services/cognitive_bean_analyzer.dart';
import 'package:coffee_hub_mobile/features/flavor_wheel/data/coffee_varieties_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    CoffeeKnowledgeGraphService.instance.ensureSyncInitialized();
    WorldIndonesiaBeansService.instance.ensureLoadedSyncForTest();
  });

  test('v3.0 Knowledge Graph & World-Indonesia Corpus loads Sabang-Merauke & Global assets cleanly', () {
    final kg = CoffeeKnowledgeGraphService.instance;
    expect(kg.terroirs.length, greaterThanOrEqualTo(80));
    expect(kg.knownRoasteries.length, greaterThanOrEqualTo(500));
    expect(kg.knownVarieties.length, greaterThanOrEqualTo(100));
    expect(kg.catalogEntries.length, greaterThanOrEqualTo(2000));

    final beans = WorldIndonesiaBeansService.instance.allMergedVisualBeans;
    expect(beans.length, greaterThanOrEqualTo(600));
    expect(CoffeeVarietiesCatalog.getMergedVarieties().length, greaterThanOrEqualTo(70));
  });

  test('CognitiveBeanAnalyzer detects Sabang-to-Merauke & World origins without hallucination', () {
    final colol = CognitiveBeanAnalyzer.analyze(
      rawFullText: 'FLORES COLOL MANGGARAI\nHONEY PROCESS\nVARIETY: JURIA',
      blocksDto: const [],
    );
    expect(colol.origin.toLowerCase(), contains('flores'));
    expect(colol.process, 'Honey Process');
    expect(colol.confidenceScore, greaterThanOrEqualTo(70.0));

    final tiom = CognitiveBeanAnalyzer.analyze(
      rawFullText: 'PAPUA TIOM LANNY JAYA\nFULL WASHED\nTYPICA',
      blocksDto: const [],
    );
    expect(tiom.origin.toLowerCase(), contains('papua'));
    expect(tiom.confidenceScore, greaterThanOrEqualTo(70.0));

    final colombia = CognitiveBeanAnalyzer.analyze(
      rawFullText: 'COLOMBIA HUILA EL PARAISO\nPINK BOURBON\nTHERMAL SHOCK\nPeach, Jasmine, Lychee',
      blocksDto: const [],
    );
    expect(colombia.origin.toLowerCase(), contains('colombia'));
    expect(colombia.variety.toLowerCase(), contains('pink bourbon'));
    expect(colombia.notesSource, 'OCR_EXPLICIT');

    // ZERO HALLUCINATION GATE: random non-coffee receipt text MUST NOT invent 94.5% Indonesia Washed!
    final noise = CognitiveBeanAnalyzer.analyze(
      rawFullText: 'STRUK BELANJA 9928172 TOTAL RP 45000 TERIMA KASIH',
      blocksDto: const [],
    );
    expect(noise.confidenceScore, lessThan(40.0));
    expect(noise.notesSource, 'LOW_CONFIDENCE_NO_MATCH');
    expect(noise.origin, 'Belum Terdeteksi');
    expect(noise.tastingNotes, isEmpty);
  });

  test('CoffeePackagingOcrEngine resolves Sabang-Merauke & World coffee entities via v3.0 Knowledge Graph', () {
    final res = CoffeePackagingOcrEngine.parseCoffeeEntities(
      ocrRegions: const [
        OcrTextRegion(text: 'TANAMERA COFFEE', confidence: 0.98, yRel: 0.15, fontHeight: 0.08),
        OcrTextRegion(text: 'FLORES COLOL', confidence: 0.96, yRel: 0.42, fontHeight: 0.12),
        OcrTextRegion(text: 'ANAEROBIC NATURAL', confidence: 0.95, yRel: 0.65, fontHeight: 0.06),
      ],
      existingClasses: const [],
    );
    expect(res.brand, contains('tanamera'));
    expect(res.coffeeName, contains('colol'));
    expect(res.process, 'anaerobicnatural');
  });
}
