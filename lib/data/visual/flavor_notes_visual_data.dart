import 'package:flutter/material.dart';
import '../../models/brew_visual_models.dart';

const List<FlavorNoteVisualItem> defaultFlavorNotes = [
  // 🌸 FLORAL
    FlavorNoteVisualItem(label: 'Jasmine', group: 'Floral', emoji: '🌸', color: Color(0xFFEC407A)),
    FlavorNoteVisualItem(label: 'Orange Blossom', group: 'Floral', emoji: '🌼', color: Color(0xFFFFB300)),
    FlavorNoteVisualItem(label: 'Rose', group: 'Floral', emoji: '🌹', color: Color(0xFFE91E63)),
    FlavorNoteVisualItem(label: 'Hibiscus', group: 'Floral', emoji: '🌺', color: Color(0xFFD81B60)),
    FlavorNoteVisualItem(label: 'Lavender', group: 'Floral', emoji: '🪻', color: Color(0xFF7E57C2)),
    FlavorNoteVisualItem(label: 'Chamomile', group: 'Floral', emoji: '🌼', color: Color(0xFFFDD835)),
    FlavorNoteVisualItem(label: 'Elderflower', group: 'Floral', emoji: '💮', color: Color(0xFFFFF9C4)),
    FlavorNoteVisualItem(label: 'Magnolia', group: 'Floral', emoji: '🌸', color: Color(0xFFF48FB1)),
    FlavorNoteVisualItem(label: 'Coffee Blossom', group: 'Floral', emoji: '🤍', color: Color(0xFFE0E0E0)),

    // 🍑 STONE FRUIT (FRUITY)
    FlavorNoteVisualItem(label: 'White Peach', group: 'Stone Fruit', emoji: '🍑', color: Color(0xFFFF7043)),
    FlavorNoteVisualItem(label: 'Yellow Peach', group: 'Stone Fruit', emoji: '🍑', color: Color(0xFFFF8A65)),
    FlavorNoteVisualItem(label: 'Apricot', group: 'Stone Fruit', emoji: '🍑', color: Color(0xFFF4511E)),
    FlavorNoteVisualItem(label: 'Dark Plum', group: 'Stone Fruit', emoji: '🫐', color: Color(0xFF6A1B9A)),
    FlavorNoteVisualItem(label: 'Red Cherry', group: 'Stone Fruit', emoji: '🍒', color: Color(0xFFD32F2F)),
    FlavorNoteVisualItem(label: 'Sweet Cherry', group: 'Stone Fruit', emoji: '🍒', color: Color(0xFFC2185B)),
    FlavorNoteVisualItem(label: 'Nectarine', group: 'Stone Fruit', emoji: '🍑', color: Color(0xFFFF5722)),

    // 🥭 TROPICAL FRUIT (FRUITY)
    FlavorNoteVisualItem(label: 'Tropical Mango', group: 'Tropical', emoji: '🥭', color: Color(0xFFFFA000)),
    FlavorNoteVisualItem(label: 'Ripe Mango', group: 'Tropical', emoji: '🥭', color: Color(0xFFFFB300)),
    FlavorNoteVisualItem(label: 'Passion Fruit', group: 'Tropical', emoji: '🍈', color: Color(0xFFFF8F00)),
    FlavorNoteVisualItem(label: 'Pineapple', group: 'Tropical', emoji: '🍍', color: Color(0xFFFFD600)),
    FlavorNoteVisualItem(label: 'Lychee', group: 'Tropical', emoji: '🍈', color: Color(0xFFF06292)),
    FlavorNoteVisualItem(label: 'Pink Guava', group: 'Tropical', emoji: '🍈', color: Color(0xFFE91E63)),
    FlavorNoteVisualItem(label: 'Papaya', group: 'Tropical', emoji: '🍈', color: Color(0xFFFF7043)),
    FlavorNoteVisualItem(label: 'Sweet Melon / Honeydew', group: 'Tropical', emoji: '🍈', color: Color(0xFF81C784)),
    FlavorNoteVisualItem(label: 'Jackfruit (Nangka)', group: 'Tropical', emoji: '🍈', color: Color(0xFFFFB74D)),
    FlavorNoteVisualItem(label: 'Dragonfruit', group: 'Tropical', emoji: '🌺', color: Color(0xFFAD1457)),
    FlavorNoteVisualItem(label: 'Starfruit (Belimbing)', group: 'Tropical', emoji: '⭐', color: Color(0xFFDCE775)),
    FlavorNoteVisualItem(label: 'Banana', group: 'Tropical', emoji: '🍌', color: Color(0xFFFFEE58)),

    // 🍎 ORCHARD FRUIT (FRUITY)
    FlavorNoteVisualItem(label: 'Crisp Green Apple', group: 'Orchard Fruit', emoji: '🍏', color: Color(0xFF43A047)),
    FlavorNoteVisualItem(label: 'Red Fuji Apple', group: 'Orchard Fruit', emoji: '🍎', color: Color(0xFFE53935)),
    FlavorNoteVisualItem(label: 'Juicy Pear', group: 'Orchard Fruit', emoji: '🍐', color: Color(0xFFAED581)),
    FlavorNoteVisualItem(label: 'White Grape', group: 'Orchard Fruit', emoji: '🍇', color: Color(0xFF81C784)),
    FlavorNoteVisualItem(label: 'Red Grape', group: 'Orchard Fruit', emoji: '🍇', color: Color(0xFF8E24AA)),
    FlavorNoteVisualItem(label: 'Pomegranate (Delima)', group: 'Orchard Fruit', emoji: '🍒', color: Color(0xFFB71C1C)),
    FlavorNoteVisualItem(label: 'Fig (Buah Tin)', group: 'Orchard Fruit', emoji: '🫐', color: Color(0xFF4A148C)),

    // 🍋 CITRUS
    FlavorNoteVisualItem(label: 'Lemon', group: 'Citrus', emoji: '🍋', color: Color(0xFFFBC02D)),
    FlavorNoteVisualItem(label: 'Bergamot', group: 'Citrus', emoji: '🍋', color: Color(0xFFC0CA33)),
    FlavorNoteVisualItem(label: 'Sweet Orange', group: 'Citrus', emoji: '🍊', color: Color(0xFFFB8C00)),
    FlavorNoteVisualItem(label: 'Blood Orange', group: 'Citrus', emoji: '🍊', color: Color(0xFFD84315)),
    FlavorNoteVisualItem(label: 'Lime', group: 'Citrus', emoji: '🍈', color: Color(0xFF7CB342)),
    FlavorNoteVisualItem(label: 'Grapefruit', group: 'Citrus', emoji: '🍈', color: Color(0xFFFF7043)),
    FlavorNoteVisualItem(label: 'Tangerine / Mandarin', group: 'Citrus', emoji: '🍊', color: Color(0xFFFF9800)),
    FlavorNoteVisualItem(label: 'Yuzu', group: 'Citrus', emoji: '🍋', color: Color(0xFFFFEA00)),
    FlavorNoteVisualItem(label: 'Kumquat', group: 'Citrus', emoji: '🍊', color: Color(0xFFFFA726)),

    // 🍓 BERRY
    FlavorNoteVisualItem(label: 'Strawberry', group: 'Berry', emoji: '🍓', color: Color(0xFFE53935)),
    FlavorNoteVisualItem(label: 'Wild Blueberry', group: 'Berry', emoji: '🫐', color: Color(0xFF5E35B1)),
    FlavorNoteVisualItem(label: 'Raspberry', group: 'Berry', emoji: '🍓', color: Color(0xFFC2185B)),
    FlavorNoteVisualItem(label: 'Blackcurrant', group: 'Berry', emoji: '🫐', color: Color(0xFF311B92)),
    FlavorNoteVisualItem(label: 'Blackberry', group: 'Berry', emoji: '🫐', color: Color(0xFF4A148C)),
    FlavorNoteVisualItem(label: 'Cranberry', group: 'Berry', emoji: '🍒', color: Color(0xFF880E4F)),
    FlavorNoteVisualItem(label: 'Mulberry', group: 'Berry', emoji: '🫐', color: Color(0xFF3949AB)),

    // 🍯 SWEET & CONFECTION
    FlavorNoteVisualItem(label: 'Wild Honey', group: 'Sweet', emoji: '🍯', color: Color(0xFFF9A825)),
    FlavorNoteVisualItem(label: 'Caramel', group: 'Sweet', emoji: '🍮', color: Color(0xFFD84315)),
    FlavorNoteVisualItem(label: 'Brown Sugar', group: 'Sweet', emoji: '🍮', color: Color(0xFFA1887F)),
    FlavorNoteVisualItem(label: 'Gula Aren / Palm Sugar', group: 'Sweet', emoji: '🥥', color: Color(0xFF795548)),
    FlavorNoteVisualItem(label: 'Toffee & Butterscotch', group: 'Sweet', emoji: '🍬', color: Color(0xFFE65100)),
    FlavorNoteVisualItem(label: 'Maple Syrup', group: 'Sweet', emoji: '🍁', color: Color(0xFF8D6E63)),
    FlavorNoteVisualItem(label: 'Vanilla', group: 'Sweet', emoji: '🍦', color: Color(0xFFAB47BC)),
    FlavorNoteVisualItem(label: 'Molasses', group: 'Sweet', emoji: '🍯', color: Color(0xFF4E342E)),
    FlavorNoteVisualItem(label: 'Marshmallow', group: 'Sweet', emoji: '🍥', color: Color(0xFFE1BEE7)),

    // 🍫 CHOCOLATE & COCOA
    FlavorNoteVisualItem(label: 'Dark Chocolate', group: 'Cocoa', emoji: '🍫', color: Color(0xFF4E342E)),
    FlavorNoteVisualItem(label: 'Milk Chocolate', group: 'Cocoa', emoji: '🍫', color: Color(0xFF795548)),
    FlavorNoteVisualItem(label: 'Cocoa Nibs', group: 'Cocoa', emoji: '🍫', color: Color(0xFF3E2723)),
    FlavorNoteVisualItem(label: 'White Chocolate', group: 'Cocoa', emoji: '🍫', color: Color(0xFFD7CCC8)),

    // 🥜 NUTTY
    FlavorNoteVisualItem(label: 'Roasted Almond', group: 'Nutty', emoji: '🥜', color: Color(0xFF8D6E63)),
    FlavorNoteVisualItem(label: 'Roasted Hazelnut', group: 'Nutty', emoji: '🌰', color: Color(0xFFA1887F)),
    FlavorNoteVisualItem(label: 'Walnut & Pecan', group: 'Nutty', emoji: '🌰', color: Color(0xFF6D4C41)),
    FlavorNoteVisualItem(label: 'Pistachio', group: 'Nutty', emoji: '🥜', color: Color(0xFF81C784)),
    FlavorNoteVisualItem(label: 'Cashew (Kacang Mede)', group: 'Nutty', emoji: '🥜', color: Color(0xFFBCAAA4)),

    // 🪵 SPICES & HERBAL
    FlavorNoteVisualItem(label: 'Cinnamon (Kayu Manis)', group: 'Herbal', emoji: '🪵', color: Color(0xFFBF360C)),
    FlavorNoteVisualItem(label: 'Clove (Cengkeh)', group: 'Herbal', emoji: '🪵', color: Color(0xFF5D4037)),
    FlavorNoteVisualItem(label: 'Cardamom (Kapulaga)', group: 'Herbal', emoji: '🌿', color: Color(0xFF689F38)),
    FlavorNoteVisualItem(label: 'Fresh Ginger (Jahe)', group: 'Herbal', emoji: '🫚', color: Color(0xFFFFB300)),
    FlavorNoteVisualItem(label: 'Lemongrass (Serai)', group: 'Herbal', emoji: '🌿', color: Color(0xFF388E3C)),
    FlavorNoteVisualItem(label: 'Mint Leaf', group: 'Herbal', emoji: '🌱', color: Color(0xFF00BFA5)),
    FlavorNoteVisualItem(label: 'Star Anise (Pekak)', group: 'Herbal', emoji: '⭐', color: Color(0xFF4E342E)),

    // 🍷 WINEY & FERMENT
    FlavorNoteVisualItem(label: 'Red Wine', group: 'Winey', emoji: '🍷', color: Color(0xFF8E24AA)),
    FlavorNoteVisualItem(label: 'White Wine', group: 'Winey', emoji: '🥂', color: Color(0xFFC0CA33)),
    FlavorNoteVisualItem(label: 'Rum Raisin', group: 'Winey', emoji: '🥃', color: Color(0xFF6A1B9A)),
    FlavorNoteVisualItem(label: 'Bourbon Whiskey', group: 'Winey', emoji: '🥃', color: Color(0xFFD84315)),
    FlavorNoteVisualItem(label: 'Apple Cider', group: 'Winey', emoji: '🍾', color: Color(0xFFFF8F00)),
    FlavorNoteVisualItem(label: 'Fermented Kombucha', group: 'Winey', emoji: '🍷', color: Color(0xFF7B1FA2)),

    // 🍵 TEA-LIKE
    FlavorNoteVisualItem(label: 'Black Tea', group: 'Tea-like', emoji: '🍵', color: Color(0xFF00897B)),
    FlavorNoteVisualItem(label: 'Earl Grey', group: 'Tea-like', emoji: '🍵', color: Color(0xFF00695C)),
    FlavorNoteVisualItem(label: 'Jasmine Green Tea', group: 'Tea-like', emoji: '🍵', color: Color(0xFF2E7D32)),
    FlavorNoteVisualItem(label: 'Oolong Tea', group: 'Tea-like', emoji: '🍵', color: Color(0xFF558B2F)),
    FlavorNoteVisualItem(label: 'Cascara Tea', group: 'Tea-like', emoji: '🍒', color: Color(0xFFC2185B)),

    // ✨ MOUTHFEEL & FINISH
    FlavorNoteVisualItem(label: 'Clean & Juicy Finish', group: 'Mouthfeel', emoji: '✨', color: Color(0xFF1E88E5)),
    FlavorNoteVisualItem(label: 'Silky Body', group: 'Mouthfeel', emoji: '🥛', color: Color(0xFF00ACC1)),
    FlavorNoteVisualItem(label: 'Creamy & Round', group: 'Mouthfeel', emoji: '🧈', color: Color(0xFFFFB300)),
    FlavorNoteVisualItem(label: 'Velvety & Dense', group: 'Mouthfeel', emoji: '☕', color: Color(0xFF5D4037)),
  ];
