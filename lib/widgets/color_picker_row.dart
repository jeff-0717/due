import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class ColorPickerRow extends StatelessWidget {
  final String selectedColor;
  final ValueChanged<String> onChanged;

  static const colors = [
    '#2563EB',
    '#F97316',
    '#10B981',
    '#EF4444',
    '#8B5CF6',
    '#EC4899',
    '#14B8A6',
    '#F59E0B',
  ];

  const ColorPickerRow({
    super.key,
    required this.selectedColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((colorHex) {
        final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
        final isSelected = selectedColor == colorHex;
        return GestureDetector(
          onTap: () => onChanged(colorHex),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: AppTokens.textPrimary, width: 3)
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
