import 'package:coffee_hub_mobile/screens/bean_recipe_recommender_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Compact Minimalist Smart Brew Dial-In UI Tests', () {
    testWidgets('hides verbose descriptions behind (i) info buttons and stays compact', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: BeanRecipeRecommenderScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Header ringkas & tombol mulai seduh langsung terlihat
      expect(find.text('Smart Brew Dial-In'), findsOneWidget);
      expect(find.text('Mulai Seduh'), findsOneWidget);

      // Deskripsi panjang & heading bertingkat lama tidak membanjiri layar utama
      expect(find.text('Foto kemasan & logo resmi dari 50 micro-roastery'), findsNothing);
      expect(find.text('Saran racikan terbaik untuk memaksimalkan potensi biji ini'), findsNothing);
      expect(find.text('1. Pilih Biji Kopi Komersil'), findsNothing);

      // Ketuk tombol (i) pada section Biji Kopi untuk menampilkan Opini Barista & Evolusi Suhu
      final beanInfoBtn = find.byTooltip('Info karakter rasa & opini barista');
      expect(beanInfoBtn, findsOneWidget);
      await tester.tap(beanInfoBtn);
      await tester.pumpAndSettle();
      expect(find.textContaining('Opini Barista'), findsOneWidget);
      expect(find.textContaining('Suhu Panas (>65°C)'), findsOneWidget);

      // Tutup bottom sheet info
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Scroll ListView utama agar Tuning Lanjutan tidak tertutup bottomNavigationBar
      final mainList = find.byType(ListView).first;
      await tester.drag(mainList, const Offset(0, -240));
      await tester.pumpAndSettle();

      // Buka Tuning Lanjutan & ganti tab hasil Sains EY/TDS
      await tester.tap(find.textContaining('Tuning Lanjutan'));
      await tester.pumpAndSettle();
      expect(find.text('Umur Sangrai'), findsOneWidget);

      await tester.drag(mainList, const Offset(0, -360));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sains EY/TDS'));
      await tester.pumpAndSettle();
      expect(find.text('TDS'), findsOneWidget);
      expect(find.text('EY'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });
}
