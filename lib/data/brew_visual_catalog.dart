import '../models/brew_visual_models.dart';
import 'visual/beans_part_1.dart';
import 'visual/beans_part_2.dart';
import 'visual/drippers_visual_data.dart';
import 'visual/flavor_notes_visual_data.dart';
import 'visual/grinders_part_1.dart';
import 'visual/grinders_part_2.dart';

export '../models/brew_visual_models.dart';
export 'visual/dripper_visual_widgets.dart';

class BrewVisualCatalog {
  static const List<DripperVisualItem> drippers = defaultDrippers;
  static const List<String> varieties = defaultVarieties;
  static const List<String> roastLevels = defaultRoastLevels;
  static const List<String> processes = defaultProcesses;
  static const List<BeanVisualItem> beans = [
    ...defaultBeansPart1,
    ...defaultBeansPart2,
  ];
  static const List<FlavorNoteVisualItem> flavorNotes = defaultFlavorNotes;
  static const List<GrinderModel> grinderModels = [
    ...defaultGrindersPart1,
    ...defaultGrindersPart2,
  ];

  static FlavorNoteVisualItem matchNote(String rawNote) {
    final lower = rawNote.toLowerCase();
    for (final item in flavorNotes) {
      if (lower.contains(item.label.toLowerCase())) return item;
    }
    // Pencarian kata parsial / kata kunci utama
    for (final item in flavorNotes) {
      final cleanLabel = item.label.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase();
      final words = cleanLabel.split(' ');
      for (final w in words) {
        if (w.length >= 4 && lower.contains(w)) return item;
      }
    }
    // Fallback berdasarkan grup rasa utama
    if (lower.contains('floral') || lower.contains('flower') || lower.contains('bunga')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Floral', orElse: () => flavorNotes.first);
    }
    if (lower.contains('citrus') || lower.contains('jeruk') || lower.contains('lemon')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Citrus', orElse: () => flavorNotes.first);
    }
    if (lower.contains('berry') || lower.contains('beri')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Berry', orElse: () => flavorNotes.first);
    }
    if (lower.contains('tropical') || lower.contains('tropis') || lower.contains('mango') || lower.contains('nanas')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Tropical', orElse: () => flavorNotes.first);
    }
    if (lower.contains('stone') || lower.contains('peach') || lower.contains('apricot') || lower.contains('cherry')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Stone Fruit', orElse: () => flavorNotes.first);
    }
    if (lower.contains('apple') || lower.contains('pear') || lower.contains('grape')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Orchard Fruit', orElse: () => flavorNotes.first);
    }
    if (lower.contains('choco') || lower.contains('cocoa') || lower.contains('cokelat')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Cocoa', orElse: () => flavorNotes.first);
    }
    if (lower.contains('sweet') || lower.contains('honey') || lower.contains('caramel') || lower.contains('madu')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Sweet', orElse: () => flavorNotes.first);
    }
    if (lower.contains('nut') || lower.contains('almond') || lower.contains('kacang')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Nutty', orElse: () => flavorNotes.first);
    }
    if (lower.contains('wine') || lower.contains('rum') || lower.contains('whiskey') || lower.contains('ferment')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Winey', orElse: () => flavorNotes.first);
    }
    if (lower.contains('tea') || lower.contains('teh') || lower.contains('earl grey')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Tea-like', orElse: () => flavorNotes.first);
    }
    if (lower.contains('spice') || lower.contains('herb') || lower.contains('rempah') || lower.contains('kayu manis')) {
      return flavorNotes.firstWhere((fn) => fn.group == 'Herbal', orElse: () => flavorNotes.first);
    }

    return flavorNotes.firstWhere(
      (fn) => fn.label == 'Clean & Juicy Finish',
      orElse: () => flavorNotes.first,
    );
  }

  /// Mencocokkan nama metode/dripper dengan visual dripper item.
  static DripperVisualItem matchDripper(String? rawMethod, {String? category}) {
    final m = '${rawMethod ?? ''} ${category ?? ''}'.toLowerCase();
    if (m.contains('switch')) return drippers[2];
    if (m.contains('origami')) return drippers[3];
    if (m.contains('kalita')) return drippers[4];
    if (m.contains('orea') || m.contains('april') || m.contains('flat')) return drippers[5];
    if (m.contains('aeropress')) return drippers[6];
    if (m.contains('french press')) return drippers[7];
    if (m.contains('clever')) return drippers[8];
    if (m.contains('chemex') || m.contains('kono')) return drippers[9];
    if (m.contains('pulsar') || m.contains('gina')) return drippers[10];
    if (m.contains('vietnam') || m.contains('phin')) return drippers[11];
    if (m.contains('es') || m.contains('ice')) return drippers[1];
    return drippers[0];
  }

  /// Menghitung jumlah tahapan tuangan air (pour count) dari sebuah resep.
  static int countPours(Map<String, dynamic> recipe) {
    final steps = recipe['steps'] as List<dynamic>? ?? [];
    int count = 0;
    for (final s in steps) {
      if (s is Map) {
        final w = (s['waterAddedGrams'] ?? s['waterGrams'] ?? 0) as num;
        if (w > 0) count++;
      }
    }
    return count > 0 ? count : 1;
  }
}
