import 'package:coffee_hub_mobile/core/storage/user_scoped_storage.dart';
import 'package:coffee_hub_mobile/features/brew/controllers/brew_journal_controller.dart';
import 'package:coffee_hub_mobile/features/brew/journal/models/brew_journal_entry.dart';
import 'package:coffee_hub_mobile/features/brew/journal/widgets/brew_journal_sensory_chart.dart';
import 'package:coffee_hub_mobile/screens/brew_journal_screen.dart';
import 'package:coffee_hub_mobile/services/api_service.dart';
import 'package:coffee_hub_mobile/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    UserScopedStorage.resetForTesting();
    ApiService.clearMemoryCache();
  });

  group('BrewJournalEntry Model & Legacy Sensory Auto-Parser', () {
    test('Parses legacy sensory evaluation string into structured Radar/Bar metrics and resolves recipeTitle', () {
      final legacy = {
        'id': 1001,
        'recipeTitle': 'V60 Kintamani Anaerobic',
        'grindNote': '22 Klik • Sweet Spot',
        'rating': 3.8,
        'notes':
            'Sweet Spot! Ekstraksi Seimbang 🎯 | Asam: 3.5, Manis: 3.8, Pahit: 2.0, Body: 3.2, Clarity: 4.0. ✨ Keseimbangan rasa manis dan keasaman sangat ideal!',
        'createdAt': '2026-11-22T06:50:00.000Z',
      };

      final entry = BrewJournalEntry.fromMap(legacy);
      expect(entry.title, 'V60 Kintamani Anaerobic');
      expect(entry.grindSize, '22 Klik • Sweet Spot');
      expect(entry.hasSensoryChart, isTrue);
      expect(entry.sensoryMaxScale, 5.0);
      expect(entry.sensoryMetrics['Asam'], 3.5);
      expect(entry.sensoryMetrics['Manis'], 3.8);
      expect(entry.sensoryMetrics['Pahit'], 2.0);
      expect(entry.sensoryMetrics['Body'], 3.2);
      expect(entry.sensoryMetrics['Clarity'], 4.0);
    });
  });

  group('BrewJournalController Flexible CRUD & Follow-Up Notes', () {
    test('Supports add, edit, follow-up add/edit/delete, and delete entry cleanly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final sub = container.listen(brewJournalControllerProvider, (_, _) {});
      addTearDown(sub.close);

      final ctrl = container.read(brewJournalControllerProvider.notifier);
      final initial = BrewJournalEntry(
        id: 202601,
        title: 'V60 Gayo Honey',
        method: 'Hario V60',
        grindSize: '24 Klik',
        rating: 4.0,
        notes: 'Aroma floral kuat',
        sensoryMetrics: const {
          'Asam': 3.5,
          'Manis': 4.0,
          'Pahit': 2.0,
          'Body': 3.5,
          'Clarity': 4.2,
        },
        createdAt: DateTime(2026, 11, 22, 7, 30),
      );

      await ctrl.addEntry(initial.toMap());
      var list = await container.read(brewJournalControllerProvider.future);
      expect(list.length, 1);

      // Edit utama
      final edited = initial.copyWith(
        title: 'V60 Gayo Honey (Revisi)',
        rating: 5.0,
        notes: 'Manis madu & clean finish setelah turun suhu 90C',
      );
      await ctrl.updateEntry(edited);
      list = await container.read(brewJournalControllerProvider.future);
      expect(list.length, 1);
      final afterEdit = BrewJournalEntry.fromMap(list.first);
      expect(afterEdit.title, 'V60 Gayo Honey (Revisi)');
      expect(afterEdit.rating, 5.0);
      expect(afterEdit.updatedAt, isNotNull);

      // Tambah catatan tambahan (follow-up note)
      final withNote = await ctrl.addFollowUpNote(
        afterEdit,
        'Setelah dingin 5 menit, sweetness berry makin naik!',
      );
      expect(withNote.additionalNotes.length, 1);
      final noteId = withNote.additionalNotes.first.id;

      // Edit catatan tambahan
      final withEditedNote = await ctrl.editFollowUpNote(
        withNote,
        noteId,
        'Sweetness berry & citrus makin seimbang saat dingin.',
      );
      expect(
        withEditedNote.additionalNotes.first.text,
        'Sweetness berry & citrus makin seimbang saat dingin.',
      );
      expect(withEditedNote.additionalNotes.first.updatedAt, isNotNull);

      // Hapus catatan tambahan
      final withoutNote = await ctrl.deleteFollowUpNote(withEditedNote, noteId);
      expect(withoutNote.additionalNotes, isEmpty);

      // Hapus jurnal
      await ctrl.deleteEntry(initial.id);
      list = await container.read(brewJournalControllerProvider.future);
      expect(list, isEmpty);
    });
  });

  group('BrewJournalScreen Widget Integration', () {
    testWidgets('Opens Detail Sheet with Radar/Bar chart toggle and adds follow-up note', (tester) async {
      await ApiService.addJournalEntry({
        'id': 9001,
        'recipeTitle': 'Origami Ethiopian Guji',
        'grindNote': 'Medium-Fine • Sweet Spot',
        'rating': 4.5,
        'notes':
            'Sweet Spot! Ekstraksi Seimbang | Asam: 4.0, Manis: 4.2, Pahit: 1.8, Body: 3.4, Clarity: 4.5.',
        'createdAt': '2026-11-22T07:00:00.000Z',
      });

      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const BrewJournalScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Kartu tampil dengan judul asli (bukan 'Recipe') & chip grafik
      expect(find.text('Origami Ethiopian Guji'), findsOneWidget);
      expect(find.text('Detail'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);

      // Ketuk Detail untuk membuka Detail Sheet + Grafik Radar
      await tester.tap(find.text('Detail'));
      await tester.pumpAndSettle();

      expect(find.byType(BrewJournalSensoryRadarChart), findsOneWidget);

      // Beralih ke tampilan Grafik Batang
      await tester.tap(find.text('Batang'));
      await tester.pumpAndSettle();
      expect(find.byType(BrewJournalSensoryBarChart), findsOneWidget);

      // Tambahkan catatan tambahan dari Detail Sheet
      final followUpField = find.byType(TextField).last;
      await tester.ensureVisible(followUpField);
      await tester.pumpAndSettle();
      await tester.enterText(
        followUpField,
        'Besok coba giling 1 klik lebih halus',
      );
      final addBtn = find.text('Tambah');
      await tester.ensureVisible(addBtn);
      await tester.pumpAndSettle();
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(find.text('Besok coba giling 1 klik lebih halus'), findsOneWidget);
      expect(find.text('Catatan Tambahan (1)'), findsOneWidget);
    });
  });
}
