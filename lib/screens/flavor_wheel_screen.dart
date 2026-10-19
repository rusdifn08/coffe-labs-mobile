import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FlavorWheelScreen extends StatefulWidget {
  const FlavorWheelScreen({super.key});

  @override
  State<FlavorWheelScreen> createState() => _FlavorWheelScreenState();
}

class _FlavorWheelScreenState extends State<FlavorWheelScreen> {
  final Map<String, bool> _selectedFlavors = {
    'Fruity': false, 'Floral': false, 'Nutty': false, 
    'Cocoa': false, 'Spices': false, 'Sweet': false,
    'Roasted': false, 'Sour': false, 'Vegetal': false,
  };

  double _acidity = 5;
  double _sweetness = 5;
  double _body = 5;
  double _aftertaste = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Cupping'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tasting Notes', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Select the flavor profiles you detect in this brew', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            
            // Flavor Grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _selectedFlavors.keys.map((flavor) {
                bool isSelected = _selectedFlavors[flavor]!;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFlavors[flavor] = !isSelected;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryBrown : AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryBrown : AppTheme.textMuted.withValues(alpha: 0.2),
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(color: AppTheme.primaryBrown.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))
                      ] : [],
                    ),
                    child: Text(
                      flavor,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppTheme.textMuted,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 40),
            Text('Profile Scores', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            
            // Sliders
            _buildSlider('Acidity (Bright/Sour)', _acidity, (val) => setState(() => _acidity = val)),
            _buildSlider('Sweetness', _sweetness, (val) => setState(() => _sweetness = val)),
            _buildSlider('Body (Mouthfeel)', _body, (val) => setState(() => _body = val)),
            _buildSlider('Aftertaste', _aftertaste, (val) => setState(() => _aftertaste = val)),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Save Cupping Session'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.bgCream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.2)),
              ),
              child: Text(value.toInt().toString(), style: const TextStyle(color: AppTheme.accentAmber, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: AppTheme.primaryBrown,
          inactiveColor: AppTheme.primaryBrown.withValues(alpha: 0.1),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
