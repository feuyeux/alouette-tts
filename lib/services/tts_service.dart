import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

/// TTS服务类
class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  static const platform = MethodChannel('com.example.alouette_tts/audio');

  /// 初始化TTS
  Future<void> initialize({
    required VoidCallback onStart,
    required VoidCallback onComplete,
    required void Function(dynamic message) onError,
  }) async {
    _flutterTts.setStartHandler(onStart);
    _flutterTts.setCompletionHandler(onComplete);
    _flutterTts.setErrorHandler(onError);

    // Android 特定配置
    if (!kIsWeb && Platform.isAndroid) {
      await _configureAndroidAudio();
    }
  }

  /// 配置 Android 音频
  Future<void> _configureAndroidAudio() async {
    try {
      // 设置音频流类型为媒体音频流
      await platform.invokeMethod('setAudioStreamType');

      // 设置 TTS 引擎参数
      await _flutterTts.awaitSpeakCompletion(true);

      // 尝试设置 Android TTS 引擎选项
      await _flutterTts.setSharedInstance(true);

      // 获取并记录音量信息用于调试
      try {
        final maxVolume = await platform.invokeMethod('getMaxVolume');
        final currentVolume = await platform.invokeMethod('getCurrentVolume');
        if (kDebugMode) {
          debugPrint(
            'TTS Audio - Max Volume: $maxVolume, Current Volume: $currentVolume',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to get volume info: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to configure Android audio: $e');
      }
    }
  }

  /// 开始朗读
  Future<void> speak({
    required String text,
    required String languageCode,
    required double speechRate,
    required double volume,
    required double pitch,
  }) async {
    if (text.isEmpty) return;

    // 设置 TTS 参数
    await _flutterTts.setSpeechRate(speechRate);
    await _flutterTts.setVolume(volume);
    await _flutterTts.setPitch(pitch);
    await _flutterTts.setLanguage(languageCode);

    await _flutterTts.speak(text);
  }

  /// 停止朗读
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// 释放资源
  void dispose() {
    _flutterTts.stop();
  }
}
