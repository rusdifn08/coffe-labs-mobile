import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class EditorParamStepper extends StatelessWidget {
  final String title;
  final String unit;
  final double value;
  final double min;
  final double max;
  final double step;
  final IconData icon;
  final ValueChanged<double> onChanged;
  final String? subtitle;

  const EditorParamStepper({
    super.key,
    required this.title,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.icon,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgCream.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.primaryBrown),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 4),
                Text(
                  '($subtitle)',
                  style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Minus button
              Material(
                color: value > min ? AppTheme.primaryBrown : Colors.grey.shade400,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: value > min
                      ? () {
                          final next = (value - step).clamp(min, max);
                          onChanged(double.parse(next.toStringAsFixed(1)));
                        }
                      : null,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(CupertinoIcons.minus, color: Colors.white, size: 16),
                  ),
                ),
              ),

              // Value display
              Column(
                children: [
                  Text(
                    '$displayValue $unit',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBrown,
                    ),
                  ),
                ],
              ),

              // Plus button
              Material(
                color: value < max ? AppTheme.primaryBrown : Colors.grey.shade400,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: value < max
                      ? () {
                          final next = (value + step).clamp(min, max);
                          onChanged(double.parse(next.toStringAsFixed(1)));
                        }
                      : null,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(CupertinoIcons.plus, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
