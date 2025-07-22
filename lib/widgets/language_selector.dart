import 'package:flutter/material.dart';
import '../models/language_option.dart';

/// 语言选择组件
class LanguageSelector extends StatelessWidget {
  final LanguageOption selectedLanguage;
  final List<LanguageOption> languages;
  final ValueChanged<LanguageOption?> onChanged;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.languages,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('🌍', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<LanguageOption>(
            value: selectedLanguage,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              isDense: true,
            ),
            items: languages.map((language) {
              return DropdownMenuItem(
                value: language,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(language.flag, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(language.name, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
