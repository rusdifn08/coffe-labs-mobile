import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import 'editor_param_stepper.dart';

class EditorTechParamsSection extends StatelessWidget {
  final TextEditingController coffeeController;
  final TextEditingController tempController;
  final TextEditingController waterController;
  final TextEditingController iceController;
  final bool isIcedMethod;
  final VoidCallback onParamChanged;

  const EditorTechParamsSection({
    super.key,
    required this.coffeeController,
    required this.tempController,
    required this.waterController,
    required this.iceController,
    required this.isIcedMethod,
    required this.onParamChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            '4. Parameter Teknis Seduh (+ / -)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: EditorParamStepper(
                      title: 'Kopi',
                      unit: 'g',
                      icon: CupertinoIcons.cube_box,
                      value: double.tryParse(coffeeController.text.trim()) ?? 15.0,
                      min: 5.0,
                      max: 60.0,
                      step: 0.5,
                      onChanged: (val) {
                        coffeeController.text = val % 1 == 0 ? val.toInt().toString() : val.toString();
                        onParamChanged();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: EditorParamStepper(
                      title: 'Suhu Air',
                      unit: '°C',
                      icon: CupertinoIcons.thermometer,
                      value: double.tryParse(tempController.text.trim()) ?? 92.0,
                      min: 50.0,
                      max: 100.0,
                      step: 1.0,
                      onChanged: (val) {
                        tempController.text = val.toInt().toString();
                        onParamChanged();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: EditorParamStepper(
                      title: 'Air Panas',
                      unit: 'g',
                      icon: CupertinoIcons.drop,
                      value: double.tryParse(waterController.text.trim()) ?? 225.0,
                      min: 50.0,
                      max: 1000.0,
                      step: 5.0,
                      onChanged: (val) {
                        waterController.text = val.toInt().toString();
                        onParamChanged();
                      },
                    ),
                  ),
                  if (isIcedMethod) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: EditorParamStepper(
                        title: 'Es Batu',
                        unit: 'g',
                        subtitle: 'di Server',
                        icon: CupertinoIcons.snow,
                        value: double.tryParse(iceController.text.trim()) ?? 90.0,
                        min: 10.0,
                        max: 500.0,
                        step: 5.0,
                        onChanged: (val) {
                          iceController.text = val.toInt().toString();
                          onParamChanged();
                        },
                      ),
                    ),
                  ],
                ],
              ),
              if (isIcedMethod)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '❄️ Flash Brew Aktif: Es batu langsung di dalam server untuk mendinginkan ekstraksi.',
                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.blue.shade700),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
