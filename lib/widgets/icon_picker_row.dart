import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class IconPickerRow extends StatelessWidget {
  final String selectedIcon;
  final ValueChanged<String> onChanged;

  static const icons = [
    '📝',
    '📚',
    '🎓',
    '🏆',
    '💼',
    '🎯',
    '⭐',
    '🔥',
    '💪',
    '⏰',
    '📅',
    '✅',
  ];

  const IconPickerRow({
    super.key,
    required this.selectedIcon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: icons.map((icon) {
        final isSelected = selectedIcon == icon;
        return GestureDetector(
          onTap: () => onChanged(icon),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTokens.primary.withOpacity(0.1)
                  : AppTokens.background,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(color: AppTokens.primary, width: 2)
                  : Border.all(color: AppTokens.border),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 22)),
            ),
          ),
        );
      }).toList(),
    );
  }
}
