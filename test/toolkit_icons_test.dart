import 'package:coffee_hub_mobile/widgets/toolkit_card.dart';
import 'package:coffee_hub_mobile/widgets/toolkit_section_svg_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ToolkitSectionSvgIcons & ToolkitCard Tests', () {
    testWidgets('EcosystemSectionIcon renders properly with CustomPaint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EcosystemSectionIcon(size: 24),
          ),
        ),
      );
      expect(find.byType(EcosystemSectionIcon), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('LabSectionIcon renders properly with CustomPaint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LabSectionIcon(size: 24),
          ),
        ),
      );
      expect(find.byType(LabSectionIcon), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('ScienceSectionIcon renders properly with CustomPaint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScienceSectionIcon(size: 24),
          ),
        ),
      );
      expect(find.byType(ScienceSectionIcon), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('ToolkitSectionHeader renders SVG icon, title and subtitle without emoji', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ToolkitSectionHeader(
              icon: EcosystemSectionIcon(size: 20),
              title: 'Ekosistem & Komunitas',
              subtitle: 'Marketplace, roastery, radar & komunitas',
              badgeBg: Color(0xFFEFEBE9),
              borderColor: Color(0xFFD7CCC8),
            ),
          ),
        ),
      );
      expect(find.text('Ekosistem & Komunitas'), findsOneWidget);
      expect(find.text('Marketplace, roastery, radar & komunitas'), findsOneWidget);
      expect(find.byType(EcosystemSectionIcon), findsOneWidget);
    });

    testWidgets('ToolkitCard renders PRO badge when item is locked', (tester) async {
      final lockedTool = ToolkitItem(
        title: 'Smart Brew AI',
        subtitle: 'Kalkulator Smart Brew',
        iconType: 'cupping',
        fallbackIcon: Icons.star,
        primaryColor: Colors.brown,
        secondaryColor: Colors.amber,
        gradientColors: const [Colors.white, Colors.grey],
        destination: const SizedBox(),
        isLocked: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolkitCard(tool: lockedTool),
          ),
        ),
      );

      expect(find.text('Smart Brew AI'), findsOneWidget);
      expect(find.text('PRO'), findsOneWidget);
    });

    testWidgets('ToolkitCard does NOT render PRO badge when item is unlocked', (tester) async {
      final unlockedTool = ToolkitItem(
        title: 'Marketplace Kopi',
        subtitle: 'Katalog biji kopi',
        iconType: 'marketplace',
        fallbackIcon: Icons.store,
        primaryColor: Colors.brown,
        secondaryColor: Colors.amber,
        gradientColors: const [Colors.white, Colors.grey],
        destination: const SizedBox(),
        isLocked: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToolkitCard(tool: unlockedTool),
          ),
        ),
      );

      expect(find.text('Marketplace Kopi'), findsOneWidget);
      expect(find.text('PRO'), findsNothing);
    });
  });
}
