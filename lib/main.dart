import 'package:flutter/material.dart';
import 'pages/tts_home_page.dart';

void main() {
  runApp(const AlouetteTTSApp());
}

/// Alouette TTS 应用程序
class AlouetteTTSApp extends StatelessWidget {
  const AlouetteTTSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alouette TTS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TTSHomePage(),
    );
  }
}
