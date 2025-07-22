import 'package:flutter/material.dart';

/// TTS控制按钮组件
class TTSControlButtons extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onSpeak;
  final VoidCallback onStop;

  const TTSControlButtons({
    super.key,
    required this.isPlaying,
    required this.onSpeak,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isPlaying ? null : onSpeak,
            icon: const Icon(Icons.play_arrow, size: 24),
            label: const Text('开始朗读', style: TextStyle(fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              disabledBackgroundColor: Colors.grey,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isPlaying ? onStop : null,
            icon: const Icon(Icons.stop, size: 24),
            label: const Text('停止朗读', style: TextStyle(fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              disabledBackgroundColor: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
