import 'package:flutter/material.dart';
import '../models/language_option.dart';
import '../constants/language_constants.dart';
import '../services/tts_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/language_selector.dart';
import '../widgets/compact_slider.dart';
import '../widgets/tts_control_buttons.dart';
import '../widgets/tts_status_indicator.dart';
import '../widgets/enhanced_volume_slider.dart';

/// TTS主页面
class TTSHomePage extends StatefulWidget {
  const TTSHomePage({super.key});

  @override
  State<TTSHomePage> createState() => _TTSHomePageState();
}

class _TTSHomePageState extends State<TTSHomePage> {
  final TTSService _ttsService = TTSService();
  final TextEditingController _textController = TextEditingController(
    text: '你好，我可以为你朗读。',
  );

  bool _isPlaying = false;
  double _speechRate = 0.5;
  double _volume = 1.0;
  double _pitch = 1.0;
  LanguageOption _selectedLanguage = LanguageConstants.defaultLanguage;

  @override
  void initState() {
    super.initState();
    _initTTS();
  }

  Future<void> _initTTS() async {
    await _ttsService.initialize(
      onStart: () => setState(() => _isPlaying = true),
      onComplete: () => setState(() => _isPlaying = false),
      onError: (message) {
        setState(() => _isPlaying = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('TTS Error: $message'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Future<void> _speak() async {
    await _ttsService.speak(
      text: _textController.text,
      languageCode: _selectedLanguage.code,
      speechRate: _speechRate,
      volume: _volume,
      pitch: _pitch,
    );
  }

  Future<void> _stop() async {
    await _ttsService.stop();
  }

  @override
  void dispose() {
    _ttsService.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 文本输入区域
            Expanded(
              flex: 3,
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: '请输入要朗读的文本',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
            ),

            const SizedBox(height: 16),

            // 语言选择
            LanguageSelector(
              selectedLanguage: _selectedLanguage,
              languages: LanguageConstants.languages,
              onChanged: (LanguageOption? newLanguage) {
                if (newLanguage != null) {
                  setState(() {
                    _selectedLanguage = newLanguage;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // 控制参数
            Row(
              children: [
                // 语速控制
                Expanded(
                  child: CompactSlider(
                    icon: Icons.speed,
                    value: _speechRate,
                    min: 0.1,
                    max: 1.0,
                    valueText: '${(_speechRate * 100).round()}%',
                    onChanged: (value) => setState(() => _speechRate = value),
                  ),
                ),
                const SizedBox(width: 12),
                // 音量控制 (增强版，在 Android 上同步系统音量)
                Expanded(
                  child: EnhancedVolumeSlider(
                    value: _volume,
                    onChanged: (value) => setState(() => _volume = value),
                  ),
                ),
                const SizedBox(width: 12),
                // 音调控制
                Expanded(
                  child: CompactSlider(
                    icon: Icons.graphic_eq,
                    value: _pitch,
                    min: 0.5,
                    max: 2.0,
                    valueText: '${_pitch.toStringAsFixed(1)}x',
                    onChanged: (value) => setState(() => _pitch = value),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 播放控制按钮
            TTSControlButtons(
              isPlaying: _isPlaying,
              onSpeak: _speak,
              onStop: _stop,
            ),

            const SizedBox(height: 12),

            // 状态显示
            TTSStatusIndicator(
              isPlaying: _isPlaying,
              selectedLanguage: _selectedLanguage,
            ),
          ],
        ),
      ),
    );
  }
}
