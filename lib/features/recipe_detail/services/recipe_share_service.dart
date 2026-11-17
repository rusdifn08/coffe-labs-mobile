import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/coffee_translator.dart';
import '../../../utils/barista_utils.dart';
import '../utils/recipe_attribute_deducer.dart';

class SharedRecipeSummaryData {
  final String recipeId;
  final String title;
  final String rawAuthor;
  final String authorName;
  final String countryCode;
  final String method;
  final String category;
  final String beanName;
  final String variety;
  final String process;
  final num coffeeWeight;
  final num totalWater;
  final int iceWeight;
  final String ratio;
  final int waterTemp;
  final int totalTimeSeconds;
  final String timeFormatted;
  final String shortGrind;
  final List<String> tastingNotes;
  final List<Map<String, dynamic>> steps;
  final Uri shareUri;

  const SharedRecipeSummaryData({
    required this.recipeId,
    required this.title,
    required this.rawAuthor,
    required this.authorName,
    required this.countryCode,
    required this.method,
    required this.category,
    required this.beanName,
    required this.variety,
    required this.process,
    required this.coffeeWeight,
    required this.totalWater,
    required this.iceWeight,
    required this.ratio,
    required this.waterTemp,
    required this.totalTimeSeconds,
    required this.timeFormatted,
    required this.shortGrind,
    required this.tastingNotes,
    required this.steps,
    required this.shareUri,
  });

  String get shareUrl => shareUri.toString();
}

/// Service arsitektur share resep Coffee Labs ke WhatsApp, Instagram, Threads,
/// dan media sosial lain lengkap dengan poster grafis & deep link landing page.
class RecipeShareService {
  RecipeShareService._();

  static const String landingHost = 'brewingcoffee.vercel.app';
  static const String landingBaseUrl = 'https://brewingcoffee.vercel.app';

  static String formatSeconds(int sec) {
    final safe = sec < 0 ? 0 : sec;
    final m = safe ~/ 60;
    final s = safe % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static Uri buildShareUri(Map<String, dynamic> recipe) {
    final id = recipe['id']?.toString().trim() ?? '1';
    final rawTitle = CoffeeTranslator.translateTitle(
      recipe['title']?.toString() ?? 'Specialty Coffee Brew',
    ).trim();
    final title = rawTitle.length > 70 ? rawTitle.substring(0, 70) : rawTitle;
    final rawAuthor = recipe['author']?.toString() ?? 'Coffee Labs Barista';
    final author = BaristaUtils.cleanName(rawAuthor);
    final method = recipe['method']?.toString().trim().isNotEmpty == true
        ? recipe['method'].toString().trim()
        : (recipe['category']?.toString().trim() ?? 'Hario V60');
    final coffee = (recipe['coffeeWeightGrams'] as num?) ?? 15;
    final water = (recipe['totalWaterWeightGrams'] as num?) ?? 225;
    final temp = (recipe['waterTempCelsius'] as num?)?.round() ?? 92;
    final timeSec = (recipe['totalTimeSeconds'] as num?)?.round() ?? 150;
    final ratioVal = (water / (coffee > 0 ? coffee : 1)).toStringAsFixed(1);
    final bean = RecipeAttributeDeducer.parseBeanInfo(recipe)['name'] ?? '';
    final notes = _extractTastingNotes(recipe).take(3).join(', ');

    final params = <String, String>{
      'recipe': id,
      'title': title,
      'author': author,
      'method': method,
      'dose': '${coffee}g',
      'water': '${water}g',
      'ratio': '1:$ratioVal',
      'temp': '${temp}C',
      'time': formatSeconds(timeSec),
      if (bean.isNotEmpty) 'bean': bean,
      if (notes.isNotEmpty) 'notes': notes,
    };

    return Uri.https(landingHost, '/', params);
  }

  static SharedRecipeSummaryData summarize(Map<String, dynamic> recipe) {
    final rawAuthor = recipe['author']?.toString() ?? 'Coffee Labs Barista';
    final authorName = BaristaUtils.cleanName(rawAuthor);
    final countryCode = BaristaUtils.countryCode(rawAuthor);
    final title = CoffeeTranslator.translateTitle(
      recipe['title']?.toString() ?? 'Specialty Coffee Brew',
    );
    final method = recipe['method']?.toString().trim().isNotEmpty == true
        ? recipe['method'].toString().trim()
        : (recipe['category']?.toString().trim() ?? 'Hario V60');
    final category = recipe['category']?.toString().trim() ?? method;
    final beanInfo = RecipeAttributeDeducer.parseBeanInfo(recipe);
    final coffee = (recipe['coffeeWeightGrams'] as num?) ?? 15;
    final water = (recipe['totalWaterWeightGrams'] as num?) ?? 225;
    final ice = (recipe['iceWeightGrams'] as num?)?.toInt() ?? 0;
    final ratio =
        '1:${(water / (coffee > 0 ? coffee : 1)).toStringAsFixed(1)}';
    final temp = (recipe['waterTempCelsius'] as num?)?.toInt() ?? 92;
    final timeSec = (recipe['totalTimeSeconds'] as num?)?.toInt() ?? 150;
    final grindRaw = recipe['grindSize']?.toString() ?? 'Medium-Fine';
    final shortGrind = BaristaUtils.shortGrindLabel(grindRaw);
    final steps = _extractSteps(recipe);
    final notes = _extractTastingNotes(recipe);

    return SharedRecipeSummaryData(
      recipeId: recipe['id']?.toString() ?? '1',
      title: title,
      rawAuthor: rawAuthor,
      authorName: authorName,
      countryCode: countryCode,
      method: method,
      category: category,
      beanName: beanInfo['name'] ?? 'Single Origin Specialty',
      variety: beanInfo['variety'] ?? 'Arabica',
      process: beanInfo['process'] ?? 'Washed',
      coffeeWeight: coffee,
      totalWater: water,
      iceWeight: ice,
      ratio: ratio,
      waterTemp: temp,
      totalTimeSeconds: timeSec,
      timeFormatted: formatSeconds(timeSec),
      shortGrind: shortGrind,
      tastingNotes: notes,
      steps: steps,
      shareUri: buildShareUri(recipe),
    );
  }

  static List<String> _extractTastingNotes(Map<String, dynamic> recipe) {
    final raw = recipe['tastingNotes'];
    final List<String> items = [];
    if (raw is List) {
      for (final e in raw) {
        final s = e.toString().trim();
        if (s.isNotEmpty) items.add(s);
      }
    } else if (raw is String && raw.trim().isNotEmpty) {
      for (final part in raw.split(RegExp(r'[,|•]'))) {
        final s = part.trim();
        if (s.isNotEmpty) items.add(s);
      }
    }
    if (items.isEmpty) {
      return const ['Clean Sweetness', 'Balanced Acidity'];
    }
    return items.take(4).toList();
  }

  static List<Map<String, dynamic>> _extractSteps(Map<String, dynamic> recipe) {
    final rawSteps = recipe['steps'];
    List<dynamic> list = const [];
    if (rawSteps is List) {
      list = rawSteps;
    } else if (rawSteps is String && rawSteps.trim().startsWith('[')) {
      try {
        list = json.decode(rawSteps) as List<dynamic>;
      } catch (_) {}
    }

    final result = <Map<String, dynamic>>[];
    for (int i = 0; i < list.length; i++) {
      final item = list[i];
      if (item is Map) {
        final title = (item['title'] ?? item['name'] ?? 'Tuangan ${i + 1}')
            .toString()
            .trim();
        final dur =
            (item['durationSeconds'] ?? item['duration'] ?? 30) as num;
        final water = (item['waterAddedGrams'] ??
                item['waterGrams'] ??
                item['water'] ??
                0)
            as num;
        result.add({
          'title': title.isEmpty ? 'Tuangan ${i + 1}' : title,
          'durationSeconds': dur.toInt(),
          'water': water.toInt(),
        });
      }
    }
    return result;
  }

  /// Format WhatsApp: kaya bold, rapi berstruktur, dengan step seduh & link landing page.
  static String formatWhatsAppMessage(Map<String, dynamic> recipe) {
    final d = summarize(recipe);
    final b = StringBuffer()
      ..writeln('☕ *${d.title}*')
      ..writeln('👨🏻‍🍳 Barista: _${d.authorName}_')
      ..writeln('⚗️ Alat: *${d.method}*')
      ..writeln('🫘 Biji: ${d.beanName} (${d.process})')
      ..writeln('')
      ..writeln('📋 *Resep Presisi Coffee Labs*')
      ..writeln('• Dose Kopi : *${d.coffeeWeight}g*')
      ..writeln(
        d.iceWeight > 0
            ? '• Air + Es  : *${d.totalWater}g + ${d.iceWeight}g es*'
            : '• Total Air : *${d.totalWater}g* (${d.ratio})',
      )
      ..writeln('• Suhu Air  : *${d.waterTemp}°C*')
      ..writeln('• Gilingan  : ${d.shortGrind}')
      ..writeln('• Waktu     : *${d.timeFormatted}*');

    if (d.tastingNotes.isNotEmpty) {
      b.writeln('🌸 Notes     : ${d.tastingNotes.join(' • ')}');
    }

    if (d.steps.isNotEmpty) {
      b.writeln('');
      b.writeln('⏱️ *Langkah Tuangan:*');
      for (int i = 0; i < d.steps.take(4).length; i++) {
        final s = d.steps[i];
        final water = (s['water'] as int) > 0 ? '+${s['water']}g • ' : '';
        b.writeln('${i + 1}. ${s['title']} ($water${s['durationSeconds']}s)');
      }
    }

    b
      ..writeln('')
      ..writeln('🔥 Cobain resep ini dengan Guided Timer presisi di *Coffee Labs*:')
      ..write('👉 ${d.shareUrl}');
    return b.toString();
  }

  /// Format Threads: ringkas, estetik, siap posting beserta hashtag & URL.
  static String formatThreadsPost(Map<String, dynamic> recipe) {
    final d = summarize(recipe);
    final waterLine = d.iceWeight > 0
        ? '${d.coffeeWeight}g : ${d.totalWater}g + ${d.iceWeight}g ice'
        : '${d.coffeeWeight}g : ${d.totalWater}g (${d.ratio})';
    final notesLine = d.tastingNotes.take(3).join(' · ');

    return 'Lagi seduh "${d.title}" pakai ${d.method} ☕✨\n'
        'Barista: ${d.authorName}\n'
        'Spec: $waterLine | ${d.waterTemp}°C | ${d.timeFormatted}\n'
        'Grind: ${d.shortGrind}\n'
        'Tasting notes: $notesLine\n\n'
        'Cek timer & resep lengkapnya di Coffee Labs:\n'
        '${d.shareUrl}\n\n'
        '#CoffeeLabs #SpecialtyCoffee #ManualBrew #PourOver';
  }

  /// Format Instagram Story/Feed caption (disalin otomatis ke clipboard saat share PNG).
  static String formatInstagramCaption(Map<String, dynamic> recipe) {
    final d = summarize(recipe);
    return '☕ Brew Card: ${d.title}\n'
        '👨🏻‍🍳 By ${d.authorName} • ${d.method}\n'
        '📐 ${d.coffeeWeight}g coffee → ${d.totalWater}g water (${d.ratio}) at ${d.waterTemp}°C (${d.timeFormatted})\n'
        '✨ Notes: ${d.tastingNotes.join(', ')}\n\n'
        'Seduh presisi bareng Coffee Labs 👉 ${d.shareUrl}\n'
        '#CoffeeLabs #SpecialtyCoffee #ManualBrewIndonesia #V60 #BaristaRecipe';
  }

  /// Menangkap poster `RecipeShareCard` ke file PNG resolusi tinggi.
  static Future<File?> capturePosterPng(GlobalKey boundaryKey, String title) async {
    try {
      final boundary =
          boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final slug = title
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'^_+|_+$'), '');
      final safeSlug = slug.isEmpty ? 'resep' : slug;
      final file = File(
        '${tempDir.path}/CoffeeLabs_${safeSlug}_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      debugPrint('Error capturing recipe share card: $e');
      return null;
    }
  }

  static Future<bool> shareToWhatsApp(
    Map<String, dynamic> recipe, {
    GlobalKey? posterKey,
  }) async {
    final text = formatWhatsAppMessage(recipe);
    final encoded = Uri.encodeComponent(text);

    // 1. Coba WhatsApp app scheme langsung
    final nativeUri = Uri.parse('whatsapp://send?text=$encoded');
    try {
      if (await canLaunchUrl(nativeUri)) {
        final ok = await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
        if (ok) return true;
      }
    } catch (_) {}

    // 2. Fallback universal wa.me intent
    final webUri = Uri.parse('https://wa.me/?text=$encoded');
    try {
      if (await canLaunchUrl(webUri)) {
        final ok = await launchUrl(webUri, mode: LaunchMode.externalApplication);
        if (ok) return true;
      }
    } catch (_) {}

    // 3. Fallback system share + poster jika tersedia
    return sharePosterAndLink(recipe, posterKey: posterKey, customText: text);
  }

  static Future<bool> shareToThreads(
    Map<String, dynamic> recipe, {
    GlobalKey? posterKey,
  }) async {
    final text = formatThreadsPost(recipe);
    await Clipboard.setData(ClipboardData(text: text));
    final intentUri = Uri.parse(
      'https://www.threads.net/intent/post?text=${Uri.encodeComponent(text)}',
    );
    try {
      if (await canLaunchUrl(intentUri)) {
        final ok = await launchUrl(intentUri, mode: LaunchMode.externalApplication);
        if (ok) return true;
      }
    } catch (_) {}

    return sharePosterAndLink(recipe, posterKey: posterKey, customText: text);
  }

  static Future<bool> shareToInstagram(
    Map<String, dynamic> recipe, {
    GlobalKey? posterKey,
  }) async {
    final caption = formatInstagramCaption(recipe);
    await Clipboard.setData(ClipboardData(text: caption));
    return sharePosterAndLink(recipe, posterKey: posterKey, customText: caption);
  }

  static Future<bool> sharePosterAndLink(
    Map<String, dynamic> recipe, {
    GlobalKey? posterKey,
    String? customText,
  }) async {
    final d = summarize(recipe);
    final text = customText ?? formatWhatsAppMessage(recipe);
    File? posterFile;
    if (posterKey != null) {
      posterFile = await capturePosterPng(posterKey, d.title);
    }

    try {
      if (posterFile != null) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(posterFile.path, mimeType: 'image/png')],
            text: text,
            subject: '${d.title} — Coffee Labs',
          ),
        );
      } else {
        await SharePlus.instance.share(
          ShareParams(
            text: text,
            subject: '${d.title} — Coffee Labs',
          ),
        );
      }
      return true;
    } catch (e) {
      debugPrint('Error sharing recipe: $e');
      await Clipboard.setData(ClipboardData(text: text));
      return false;
    }
  }

  static Future<void> copyShareLink(Map<String, dynamic> recipe) async {
    await Clipboard.setData(ClipboardData(text: buildShareUri(recipe).toString()));
  }

  static Future<void> copyFormattedRecipe(Map<String, dynamic> recipe) async {
    await Clipboard.setData(ClipboardData(text: formatWhatsAppMessage(recipe)));
  }
}
