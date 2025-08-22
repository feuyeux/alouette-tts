import 'package:flutter/material.dart';
import 'package:alouette_lib_tts/alouette_tts.dart';

/// 紧凑版TTS主页面 - 一屏显示所有内容
class TTSHomePage extends StatefulWidget {
  const TTSHomePage({super.key});

  @override
  State<TTSHomePage> createState() => _TTSHomePageState();
}

class _TTSHomePageState extends State<TTSHomePage> {
  late AlouetteTTSService _ttsService;

  // 12 row controllers and per-row playing state
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

  // Per-row languages (one per row)
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
    // initialize controllers from sample texts
    _controllers = List.generate(12, (i) => TextEditingController(text: _sampleTexts[i]));
    _initTTS();
  }

  Future<void> _initTTS() async {
    try {
      // Create TTS service directly without ServiceLocator
      _ttsService = AlouetteTTSService();
      
    await _ttsService.initialize(
        onStart: () {
          // We handle per-row playing state locally when user taps a row's play button.
        },
        onComplete: () {},
        onError: (error) {
          if (mounted) {
            _showError('TTS Error: $error');
          }
        },
        config: AlouetteTTSConfig(
          // default language for engine initialization - use first sample language
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
        _showError('初始化TTS失败: $e');
        setState(() {
          // Leave as not initialized on failure so UI won't allow playback
          _isInitialized = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
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

  Future<void> _playRowTTS(int rowIndex, String text, String languageCode) async {
    if (!_isInitialized) {
      _showError('TTS 引擎未初始化');
      return;
    }

    if (text.trim().isEmpty) {
      _showError('请输入要朗读的文本');
      return;
    }

    // 如果该行正在播放，则停止
    if (_rowIsPlaying[rowIndex]) {
      await _ttsService.stop();
      if (mounted) {
        setState(() => _rowIsPlaying[rowIndex] = false);
      }
      return;
    }

    // 停止其他行的播放，但只更新必要的状态
    bool needsUpdate = false;
    for (int i = 0; i < _rowIsPlaying.length; i++) {
      if (_rowIsPlaying[i] && i != rowIndex) {
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
      // 获取该语言的默认语音名称
      String? voiceName;
      switch (languageCode.toLowerCase()) {
        case 'zh-cn':
          voiceName = 'zh-CN-XiaoxiaoNeural';
          break;
        case 'en-us':
          voiceName = 'en-US-AriaNeural';
          break;
        case 'de-de':
          voiceName = 'de-DE-KatjaNeural';
          break;
        case 'fr-fr':
          voiceName = 'fr-FR-DeniseNeural';
          break;
        case 'es-es':
          voiceName = 'es-ES-ElviraNeural';
          break;
        case 'it-it':
          voiceName = 'it-IT-ElsaNeural';
          break;
        case 'ru-ru':
          voiceName = 'ru-RU-SvetlanaNeural';
          break;
        case 'el-gr':
          voiceName = 'el-GR-AthinaNeural';
          break;
        case 'ar-sa':
          voiceName = 'ar-SA-ZariyahNeural';
          break;
        case 'hi-in':
          voiceName = 'hi-IN-SwaraNeural';
          break;
        case 'ja-jp':
          voiceName = 'ja-JP-NanamiNeural';
          break;
        case 'ko-kr':
          voiceName = 'ko-KR-SunHiNeural';
          break;
        default:
          voiceName = 'en-US-AriaNeural'; // fallback
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
        _showError('TTS 播放失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _rowIsPlaying[rowIndex] = false);
      }
    }
  }

  // 保持旧方法以兼容现有调用
  Future<void> _speakRow(int idx) async {
    final lang = _languages[idx]['code']!;
    final text = _controllers[idx].text;
    await _playRowTTS(idx, text, lang);
  }

  Future<void> _stopAll() async {
    if (!_isInitialized) return;
    try {
      await _ttsService.stop();
    } catch (e) {
      if (mounted) _showError('停止失败: $e');
    } finally {
      if (mounted) setState(() {
        for (var i = 0; i < _rowIsPlaying.length; i++) _rowIsPlaying[i] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000000),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            // reduce bottom padding slightly to avoid leaving a large blank area
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Column(
              children: [
                // 简化标题
                _buildHeader(),
                const SizedBox(height: 8),
                
                // 主内容区域
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
      const Icon(Icons.record_voice_over, color: Color(0xFFFBBF24), size: 24),
          const SizedBox(width: 8),
          const Text(
            'Alouette TTS',
            style: TextStyle(
        fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const Spacer(),
          Text(
            'Edge TTS',
            style: TextStyle(
        fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    // Make the main content scrollable so all components remain accessible
    // on small windows. GridView and controls are kept compact; outer
    // SingleChildScrollView allows vertical scrolling when necessary.
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRowsList(),
          const SizedBox(height: 6),
          _buildCompactControls(),
          // removed extra bottom spacer to avoid leaving blank area at screen bottom
        ],
      ),
    );
  }

  Widget _buildCompactTextInput() {
    // Deprecated - kept for compatibility if needed
    return const SizedBox.shrink();
  }

  Widget _buildRowsList() {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: GridView.count(
          crossAxisCount: 2, // 固定2列
          childAspectRatio: 3.2, // 固定宽高比，避免动态计算
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(_controllers.length, (index) {
            final lang = _languages[index];
            return _buildLanguageTile(index, lang);
          }),
        ),
      ),
    );
  }

  // 简化语言卡片构建方法，使用固定尺寸
  Widget _buildLanguageTile(int index, Map<String, String> lang) {
    const TextStyle labelTextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w700);
    
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 顶部行：标签 + 播放按钮
          Row(
            children: [
              // 固定宽度的语言标签
              Container(
                width: 65, // 固定宽度，避免动态计算
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    lang['name']!,
                    style: labelTextStyle.copyWith(color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const Spacer(),
              // 播放按钮
              SizedBox(
                width: 32,
                height: 22,
                child: ElevatedButton(
                  onPressed: _isInitialized
                      ? () => _playRowTTS(index, _controllers[index].text, lang['code']!)
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: _rowIsPlaying[index] ? Colors.orange : Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Icon(
                    _rowIsPlaying[index] ? Icons.stop : Icons.play_arrow,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // 文本输入框
          Expanded(
            child: TextField(
              controller: _controllers[index],
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 11),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
  }

  Widget _buildCompactControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // language selection removed — per-row languages are fixed
          
          // 语速控制
          _buildSliderRow('语速', _speechRate, 0.3, 2.0, Icons.speed, (value) async {
            setState(() => _speechRate = value);
          }),
          
          // 音量控制
          _buildSliderRow('音量', _volume, 0.0, 1.0, Icons.volume_up, (value) async {
            setState(() => _volume = value);
          }),
          
          // 音调控制
          _buildSliderRow('音调', _pitch, 0.5, 2.0, Icons.tune, (value) async {
            setState(() => _pitch = value);
          }),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderRow(
    String label,
    double value,
    double min,
    double max,
    IconData icon,
    Function(double) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFBBF24), size: 14),
          const SizedBox(width: 6),
          SizedBox(
            width: 30,
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF000000)),
            ),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: 20,
              activeColor: const Color(0xFFFBBF24),
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF000000),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // Removed global play animation and single play button; per-row controls are used.

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          const Text(
            '正在初始化TTS引擎...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请稍候片刻',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}