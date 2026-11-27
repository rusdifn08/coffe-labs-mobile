import 'package:coffee_hub_mobile/core/moderation/content_moderation_guard.dart';
import 'package:coffee_hub_mobile/features/social/widgets/social_create_post_sheet.dart';
import 'package:coffee_hub_mobile/features/social/widgets/social_embedded_recipe_card.dart';
import 'package:coffee_hub_mobile/features/social/widgets/social_post_card.dart';
import 'package:coffee_hub_mobile/models/social_coffee.dart';
import 'package:coffee_hub_mobile/screens/social_coffee_screen.dart';
import 'package:coffee_hub_mobile/services/social_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

SocialPost _makeSamplePost({
  String id = 'local_post_1',
  String authorName = 'coffeelabs.app',
  String content = 'Seduh V60 pagi ini terasa sangat manis dan clean!',
  bool withRecipe = true,
  bool isRepostedByMe = false,
  bool isSavedByMe = false,
  bool isEdited = false,
  int repostsCount = 0,
}) {
  return SocialPost(
    id: id,
    authorName: authorName,
    authorAvatar: 'assets/images/coffee_labs_emblem.png',
    authorRole: 'Barista',
    content: content,
    recipeSnapshot: withRecipe
        ? {
            'id': 1,
            'title': 'Metode Multi-Pour Neo Brew (2026)',
            'method': 'Hario V60 / Neo',
            'coffeeWeightGrams': 15,
            'totalWaterWeightGrams': 250,
            'waterTempCelsius': 92,
            'tastingNotes': 'Jasmine, White Peach, Honey',
            'isCustom': false,
          }
        : null,
    likesCount: 3,
    commentsCount: 1,
    copiesCount: 0,
    repostsCount: repostsCount,
    tags: ['V60', 'ManualBrew'],
    isLikedByMe: false,
    isRepostedByMe: isRepostedByMe,
    isSavedByMe: isSavedByMe,
    isEdited: isEdited,
    createdAt: DateTime.now().subtract(const Duration(minutes: 4)),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ModerationStrikeTracker.resetAll();
  });

  testWidgets(
    'Embedded recipe card removes Salin button and exposes direct Seduh CTA',
    (tester) async {
      var brewTapped = false;
      final post = _makeSamplePost(withRecipe: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialEmbeddedRecipeCard(
              post: post,
              onBrewRecipe: () => brewTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Salin'), findsNothing);
      expect(find.text('Seduh'), findsOneWidget);
      expect(find.text('Metode Multi-Pour Neo Brew (2026)'), findsOneWidget);

      await tester.tap(find.text('Seduh'));
      await tester.pump();
      expect(brewTapped, isTrue);
    },
  );

  testWidgets(
    'SocialCoffeeScreen supports Repost, Save to Tersimpan tab, and Own Post Edit/Delete menu',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'coffeehub_user_name': 'berton01',
      });
      final ownPost = _makeSamplePost(
        id: 'local_own_1',
        authorName: 'berton01',
        content: 'Resep V60 pagi ini enak banget!',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SocialCoffeeScreen(initialPosts: [ownPost]),
        ),
      );
      await tester.pumpAndSettle();

      // Pastikan tombol Salin tidak ada dan tab Tersimpan ada
      expect(find.text('Salin'), findsNothing);
      expect(find.text('Tersimpan'), findsOneWidget);

      // Tap tombol Repost di bawah postingan
      await tester.tap(find.byIcon(CupertinoIcons.arrow_2_squarepath).first);
      await tester.pumpAndSettle();
      expect(ownPost.isRepostedByMe, isTrue);
      expect(ownPost.repostsCount, 1);
      expect(find.text('Anda memposting ulang'), findsOneWidget);

      // Tap tombol Save / Bookmark di bawah postingan
      await tester.tap(find.byIcon(CupertinoIcons.bookmark).first);
      await tester.pumpAndSettle();
      expect(ownPost.isSavedByMe, isTrue);
      expect(find.text('Tersimpan (1)'), findsOneWidget);

      // Pindah ke tab Tersimpan -> postingan tersimpan langsung muncul!
      await tester.tap(find.text('Tersimpan (1)'));
      await tester.pumpAndSettle();
      expect(find.text('Resep V60 pagi ini enak banget!'), findsOneWidget);

      // Buka menu ••• pada postingan milik sendiri -> ada Edit & Hapus Postingan
      await tester.tap(find.byIcon(CupertinoIcons.ellipsis).first);
      await tester.pumpAndSettle();
      expect(find.text('Edit Postingan'), findsOneWidget);
      expect(find.text('Hapus Postingan'), findsOneWidget);

      // Hapus postingan -> konfirmasi dialog -> postingan hilang
      await tester.tap(find.text('Hapus Postingan'));
      await tester.pumpAndSettle();
      expect(find.text('Hapus Postingan?'), findsOneWidget);
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(find.text('Resep V60 pagi ini enak banget!'), findsNothing);
      expect(find.text('Belum Ada Postingan Tersimpan'), findsOneWidget);
    },
  );

  testWidgets(
    'Forbidden words block posting, show Pelanggaran Bahasa pop-up, and trigger auto-ban on 3rd strike',
    (tester) async {
      var createdCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialCreatePostSheet(
              onPostCreated: () => createdCount++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Strike 1: kata kasar terlarang (leetspeak)
      await tester.enterText(find.byType(TextField), 'kopi ini b4ngs4t banget');
      await tester.tap(find.text('Publikasikan ke Social Coffee'));
      await tester.pumpAndSettle();

      expect(createdCount, 0);
      expect(find.text('Pelanggaran Bahasa Terdeteksi'), findsOneWidget);
      expect(find.text('Catatan Pelanggaran: 1 / 3'), findsOneWidget);
      await tester.tap(find.text('Perbaiki Teks'));
      await tester.pumpAndSettle();

      // Strike 2: spam judi online
      await tester.enterText(find.byType(TextField), 'ayo main slot gacor maxwin88');
      await tester.tap(find.text('Publikasikan ke Social Coffee'));
      await tester.pumpAndSettle();

      expect(createdCount, 0);
      expect(find.text('Pelanggaran Bahasa Terdeteksi'), findsOneWidget);
      expect(find.text('Catatan Pelanggaran: 2 / 3'), findsOneWidget);
      await tester.tap(find.text('Perbaiki Teks'));
      await tester.pumpAndSettle();

      // Strike 3: auto-ban sementara aktif!
      await tester.enterText(find.byType(TextField), 'dasar goblok semua');
      await tester.tap(find.text('Publikasikan ke Social Coffee'));
      await tester.pumpAndSettle();

      expect(createdCount, 0);
      expect(find.text('Akun Dibatasi Sementara'), findsOneWidget);
      await tester.tap(find.text('Mengerti'));
      await tester.pumpAndSettle();

      // Bahkan teks sopan pun ditolak saat status auto-ban aktif
      await tester.enterText(find.byType(TextField), 'Halo barista, selamat pagi!');
      await tester.tap(find.text('Publikasikan ke Social Coffee'));
      await tester.pumpAndSettle();

      expect(createdCount, 0);
      expect(find.text('Akun Dibatasi Sementara'), findsOneWidget);
    },
  );

  test(
    'SocialService updatePost updates content, marks isEdited, and persists locally',
    () async {
      final post = _makeSamplePost(
        id: 'local_edit_1',
        content: 'Teks lama sebelum diedit',
      );
      await SocialService.toggleSave(post);

      final updated = await SocialService.updatePost(
        post: post,
        content: 'Teks baru sesudah diedit dengan rasio 1:16',
        tags: ['V60', 'Sweetness'],
        recipeSnapshot: post.recipeSnapshot,
      );

      expect(updated, isNotNull);
      expect(updated!.content, 'Teks baru sesudah diedit dengan rasio 1:16');
      expect(updated.isEdited, isTrue);

      final saved = await SocialService.getSavedPosts();
      expect(saved.length, 1);
      expect(saved.first.content, 'Teks baru sesudah diedit dengan rasio 1:16');
      expect(saved.first.isEdited, isTrue);
    },
  );

  testWidgets('SocialPostCard displays Diedit indicator when post is edited', (
    tester,
  ) async {
    final post = _makeSamplePost(isEdited: true);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SocialPostCard(
            post: post,
            isOwnPost: true,
            onLike: () {},
            onComment: () {},
          ),
        ),
      ),
    );

    expect(find.text('• Diedit'), findsOneWidget);
  });
}
