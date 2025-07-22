import 'package:flutter/material.dart';
import '../models/language_option.dart';

/// TTS状态显示组件
class TTSStatusIndicator extends StatelessWidget {
  final bool isPlaying;
  final LanguageOption selectedLanguage;

  const TTSStatusIndicator({
    super.key,
    required this.isPlaying,
    required this.selectedLanguage,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPlaying) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '正在朗读 ${selectedLanguage.flag} ${selectedLanguage.name}',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
