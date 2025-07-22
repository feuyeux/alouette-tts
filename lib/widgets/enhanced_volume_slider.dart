import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

/// 增强的音量滑块组件，在 Android 上同时控制系统音量
class EnhancedVolumeSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const EnhancedVolumeSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<EnhancedVolumeSlider> createState() => _EnhancedVolumeSliderState();
}

class _EnhancedVolumeSliderState extends State<EnhancedVolumeSlider> {
  static const platform = MethodChannel('com.example.alouette_tts/audio');
  int _maxSystemVolume = 15;
  int _currentSystemVolume = 0;
  bool _systemVolumeLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && Platform.isAndroid) {
      _loadSystemVolumeInfo();
    }
  }

  Future<void> _loadSystemVolumeInfo() async {
    try {
      final maxVolume = await platform.invokeMethod('getMaxVolume');
      final currentVolume = await platform.invokeMethod('getCurrentVolume');

      if (mounted) {
        setState(() {
          _maxSystemVolume = maxVolume ?? 15;
          _currentSystemVolume = currentVolume ?? 0;
          _systemVolumeLoaded = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load system volume info: $e');
      }
      if (mounted) {
        setState(() {
          _systemVolumeLoaded = true;
        });
      }
    }
  }

  Future<void> _updateSystemVolume(double appVolume) async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      // 将应用音量 (0.0-1.0) 映射到系统音量范围
      final targetSystemVolume = (appVolume * _maxSystemVolume).round();
      await platform.invokeMethod('setVolume', {'volume': targetSystemVolume});

      if (mounted) {
        setState(() {
          _currentSystemVolume = targetSystemVolume;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to update system volume: $e');
      }
    }
  }

  void _handleVolumeChange(double newValue) {
    widget.onChanged(newValue);

    // 在 Android 上同时更新系统音量
    if (!kIsWeb && Platform.isAndroid && _systemVolumeLoaded) {
      _updateSystemVolume(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.volume_up,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(widget.value * 100).round()}%',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            // Android 系统音量指示器
            if (!kIsWeb && Platform.isAndroid && _systemVolumeLoaded) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '$_currentSystemVolume/$_maxSystemVolume',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: Theme.of(context).primaryColor,
            inactiveTrackColor: Theme.of(
              context,
            ).primaryColor.withValues(alpha: 0.3),
            thumbColor: Theme.of(context).primaryColor,
            overlayColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: widget.value,
            min: 0.0,
            max: 1.0,
            onChanged: _handleVolumeChange,
          ),
        ),
        // Android 提示文本
        if (!kIsWeb && Platform.isAndroid) ...[
          const SizedBox(height: 2),
          Text(
            '同步系统音量',
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
