import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// 平台工具类
class PlatformUtils {
  /// 获取平台名称
  static String getPlatformName() {
    if (kIsWeb) {
      return 'Web';
    } else if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else {
      return 'Desktop';
    }
  }
}
