import '../../../../services/language_service.dart';

class NoteCategoryItem {
  final String id;
  final String label;
  final String labelEn;
  final String emoji;
  final List<String> groups;
  final List<String> keywords;

  const NoteCategoryItem({
    required this.id,
    required this.label,
    required this.labelEn,
    required this.emoji,
    required this.groups,
    required this.keywords,
  });

  String get localizedLabel => LanguageService.isEnglish ? labelEn : label;
}

const List<NoteCategoryItem> noteCategories = [
  NoteCategoryItem(
    id: 'floral',
    label: 'Floral',
    labelEn: 'Floral',
    emoji: '🌸',
    groups: ['Floral'],
    keywords: ['floral', 'flower', 'jasmine', 'rose', 'hibiscus', 'blossom', 'lavender', 'chamomile', 'bunga', 'elderflower'],
  ),
  NoteCategoryItem(
    id: 'fruity',
    label: 'Fruity & Tropical',
    labelEn: 'Fruity & Tropical',
    emoji: '🍑',
    groups: ['Stone Fruit', 'Tropical', 'Orchard Fruit'],
    keywords: ['fruit', 'fruity', 'peach', 'apricot', 'plum', 'mango', 'passion', 'pineapple', 'lychee', 'guava', 'papaya', 'melon', 'apple', 'pear', 'grape', 'buah'],
  ),
  NoteCategoryItem(
    id: 'citrus',
    label: 'Citrus',
    labelEn: 'Citrus',
    emoji: '🍋',
    groups: ['Citrus'],
    keywords: ['citrus', 'lemon', 'bergamot', 'orange', 'grapefruit', 'lime', 'mandarin', 'yuzu', 'tangerine', 'jeruk'],
  ),
  NoteCategoryItem(
    id: 'berry',
    label: 'Berry',
    labelEn: 'Berry',
    emoji: '🍓',
    groups: ['Berry'],
    keywords: ['berry', 'strawberry', 'blueberry', 'currant', 'raspberry', 'cherry', 'blackberry', 'cranberry'],
  ),
  NoteCategoryItem(
    id: 'sweet_cocoa',
    label: 'Cokelat & Manis',
    labelEn: 'Chocolate & Sweet',
    emoji: '🍫',
    groups: ['Sweet', 'Cocoa'],
    keywords: ['choco', 'chocolate', 'cocoa', 'cacao', 'honey', 'caramel', 'toffee', 'maple', 'sugar', 'sweet', 'vanilla', 'creamy', 'madu', 'cokelat', 'karamel'],
  ),
  NoteCategoryItem(
    id: 'nutty_spices',
    label: 'Nutty & Rempah',
    labelEn: 'Nutty & Spices',
    emoji: '🥜',
    groups: ['Nutty', 'Herbal'],
    keywords: ['nut', 'nutty', 'almond', 'hazelnut', 'walnut', 'pecan', 'spice', 'spices', 'cinnamon', 'herbal', 'lemongrass', 'rempah', 'kacang'],
  ),
  NoteCategoryItem(
    id: 'tea_winey',
    label: 'Teh & Fermentasi',
    labelEn: 'Tea & Fermentation',
    emoji: '🍵',
    groups: ['Tea-like', 'Winey'],
    keywords: ['tea', 'earl grey', 'oolong', 'black tea', 'green tea', 'wine', 'winey', 'rum', 'whiskey', 'ferment', 'teh'],
  ),
  NoteCategoryItem(
    id: 'mouthfeel',
    label: 'Mouthfeel & Body',
    labelEn: 'Mouthfeel & Body',
    emoji: '✨',
    groups: ['Mouthfeel'],
    keywords: ['clean', 'juicy', 'silky', 'body', 'creamy', 'round', 'smooth', 'mouthfeel', 'finish'],
  ),
];
