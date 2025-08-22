import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:alouette_lib_tts/alouette_tts.dart';

/// Modern TTS Home Page with a dark, glassmorphism design.
class TTSHomePage extends StatefulWidget {
  const TTSHomePage({super.key});

  @override
  State<TTSHomePage> createState() => _TTSHomePageState();
}

class _TTSHomePageState extends State<TTSHomePage> {
  late AlouetteTTSService _ttsService;

  final List<String> _sampleTexts = [
    '你好，我可以为你朗读。',
    'Hello, I can read for you.',
    'Hallo, ich kann es für dich vorlesen.',
    'Bonjour, je peux vous lire ce texte.',
    'Hola, puedo leer esto para ti.',
    'Ciao, posso leggerlo per te.',
    'Здравствуйте, я могу прочитать это для вас.',
    'Γεια σας, μπορώ να το διαβάσω για εσάς.',
    'مرحبًا، أستطيع قراءة هذا لك.',
    'नमस्ते, मैं आपके लिए इसे पढ़ कर सुना सकता हूँ.',
    'こんにちは、これを読み上げることができます。',
    '안녕하세요, 제가 읽어 드릴 수 있습니다.',
  ];

  late final List<TextEditingController> _controllers;
  final List<bool> _rowIsPlaying = List.filled(12, false);

  bool _isInitialized = false;
  double _speechRate = 1.0;
  double _volume = 1.0;
  double _pitch = 1.0;

  final List<Map<String, String>> _languages = [
    {'code': 'zh-cn', 'name': '中文'},
    {'code': 'en-us', 'name': 'English'},
    {'code': 'de-de', 'name': 'Deutsch'},
    {'code': 'fr-fr', 'name': 'Français'},
    {'code': 'es-es', 'name': 'Español'},
    {'code': 'it-it', 'name': 'Italiano'},
    {'code': 'ru-ru', 'name': 'Русский'},
    {'code': 'el-gr', 'name': 'Ελληνικά'},
    {'code': 'ar-sa', 'name': 'العربية'},
    {'code': 'hi-in', 'name': 'हिन्दी'},
    {'code': 'ja-jp', 'name': '日本語'},
    {'code': 'ko-kr', 'name': '한국어'},
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(12, (i) => TextEditingController(text: _sampleTexts[i]));
    _initTTS();
  }

  Future<void> _initTTS() async {
    try {
      _ttsService = AlouetteTTSService();
      
      await _ttsService.initialize(
        onStart: () {},
        onComplete: () {},
        onError: (error) {
          if (mounted) {
            _showError('TTS Error: $error');
          }
        },
        config: AlouetteTTSConfig(
          languageCode: _languages.first['code']!,
          speechRate: _speechRate,
          volume: _volume,
          pitch: _pitch,
        ),
      );
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to initialize TTS: $e');
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _ttsService.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _playRowTTS(int rowIndex, String text, String languageCode) async {
    if (!_isInitialized) {
      _showError('TTS engine is not initialized.');
      return;
    }

    if (text.trim().isEmpty) {
      _showError('Please enter text to speak.');
      return;
    }

    if (_rowIsPlaying[rowIndex]) {
      await _ttsService.stop();
      if (mounted) {
        setState(() => _rowIsPlaying[rowIndex] = false);
      }
      return;
    }

    bool needsUpdate = false;
    for (int i = 0; i < _rowIsPlaying.length; i++) {
      if (_rowIsPlaying[i]) {
        _rowIsPlaying[i] = false;
        needsUpdate = true;
      }
    }
    
    _rowIsPlaying[rowIndex] = true;
    needsUpdate = true;

    if (needsUpdate && mounted) {
      setState(() {});
    }

    try {
      String? voiceName;
      switch (languageCode.toLowerCase()) {
        case 'zh-cn': voiceName = 'zh-CN-XiaoxiaoNeural'; break;
        case 'en-us': voiceName = 'en-US-AriaNeural'; break;
        case 'de-de': voiceName = 'de-DE-KatjaNeural'; break;
        case 'fr-fr': voiceName = 'fr-FR-DeniseNeural'; break;
        case 'es-es': voiceName = 'es-ES-ElviraNeural'; break;
        case 'it-it': voiceName = 'it-IT-ElsaNeural'; break;
        case 'ru-ru': voiceName = 'ru-RU-SvetlanaNeural'; break;
        case 'el-gr': voiceName = 'el-GR-AthinaNeural'; break;
        case 'ar-sa': voiceName = 'ar-SA-ZariyahNeural'; break;
        case 'hi-in': voiceName = 'hi-IN-SwaraNeural'; break;
        case 'ja-jp': voiceName = 'ja-JP-NanamiNeural'; break;
        case 'ko-kr': voiceName = 'ko-KR-SunHiNeural'; break;
        default: voiceName = 'en-US-AriaNeural';
      }

      final config = AlouetteTTSConfig(
        languageCode: languageCode,
        voiceName: voiceName,
        speechRate: _speechRate,
        volume: _volume,
        pitch: _pitch,
      );

      await _ttsService.speak(text.trim(), config: config);
    } catch (e) {
      if (mounted) {
        _showError('TTS playback failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _rowIsPlaying[rowIndex] = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.8, -0.6),
            radius: 1.5,
            colors: [
              Color(0xFF1e3a8a), // Dark Blue
              Color(0xFF1a1a2e), // Dark Purple/Blue
            ],
            stops: [0, 0.9],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                Expanded(
                  child: _isInitialized ? _buildMainContent() : _buildLoadingCard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Alouette TTS',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 10.0, color: Color(0xFF00c6ff)),
              Shadow(blurRadius: 20.0, color: Color(0xFF0072ff)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: const Text(
            'Edge TTS',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        Expanded(
          child: _buildRowsList(),
        ),
        const SizedBox(height: 16),
        _buildCompactControls(),
      ],
    );
  }

  Widget _buildRowsList() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 5.0, // Adjusted aspect ratio for shorter cards
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _controllers.length,
      itemBuilder: (context, index) {
        final lang = _languages[index];
        return _buildLanguageTile(index, lang);
      },
    );
  }

  Widget _buildLanguageTile(int index, Map<String, String> lang) {
    final isPlaying = _rowIsPlaying[index];
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: isPlaying
                ? [
                    BoxShadow(
                      color: const Color(0xFF00c6ff).withOpacity(0.5),
                      blurRadius: 12.0,
                      spreadRadius: 2.0,
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start, // Aligned to top
                  children: [
                    Text(
                      lang['name']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16, // Increased font size
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _controllers[index],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        isDense: true,
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 13), // Increased font size
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _playRowTTS(index, _controllers[index].text, lang['code']!),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(8),
                  backgroundColor: isPlaying ? const Color(0xFF00c6ff) : Colors.white.withOpacity(0.2),
                  foregroundColor: isPlaying ? Colors.white : const Color(0xFF00c6ff),
                ),
                child: Icon(isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactControls() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: _buildSliderColumn('语速', _speechRate, 0.3, 2.0, Icons.speed_rounded, (v) => setState(() => _speechRate = v))),
              const VerticalDivider(color: Colors.white24, indent: 8, endIndent: 8),
              Expanded(child: _buildSliderColumn('音量', _volume, 0.0, 1.0, Icons.volume_up_rounded, (v) => setState(() => _volume = v))),
              const VerticalDivider(color: Colors.white24, indent: 8, endIndent: 8),
              Expanded(child: _buildSliderColumn('音调', _pitch, 0.5, 2.0, Icons.tune_rounded, (v) => setState(() => _pitch = v))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderColumn(String label, double value, double min, double max, IconData icon, Function(double) onChanged) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
        SizedBox(
          height: 20,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2.0,
              activeTrackColor: const Color(0xFF00c6ff),
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: Colors.white,
              overlayColor: const Color(0xFF00c6ff).withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
        Text(
          value.toStringAsFixed(1),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00c6ff)),
                ),
                SizedBox(height: 24),
                Text(
                  'Initializing TTS Engine...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please wait a moment',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}