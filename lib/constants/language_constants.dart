import '../models/language_option.dart';

/// 语言配置常量
class LanguageConstants {
  // 支持的语言列表
  static const List<LanguageOption> languages = [
    LanguageOption(code: 'zh-CN', name: '简体中文', flag: '🇨🇳'),
    LanguageOption(code: 'en-US', name: '美式英语', flag: '🇺🇸'),
    LanguageOption(code: 'fr-FR', name: '法语', flag: '🇫🇷'),
    LanguageOption(code: 'es-ES', name: '西班牙语', flag: '🇪🇸'),
    LanguageOption(code: 'ru-RU', name: '俄语', flag: '🇷🇺'),
    LanguageOption(code: 'el-GR', name: '希腊语', flag: '🇬🇷'),
    LanguageOption(code: 'ar-SA', name: '阿拉伯语', flag: '🇸🇦'),
    LanguageOption(code: 'hi-IN', name: '印地语', flag: '🇮🇳'),
    LanguageOption(code: 'ja-JP', name: '日语', flag: '🇯🇵'),
    LanguageOption(code: 'ko-KR', name: '韩语', flag: '🇰🇷'),
  ];

  // 默认语言
  static const LanguageOption defaultLanguage = LanguageOption(
    code: 'zh-CN',
    name: '简体中文',
    flag: '🇨🇳',
  );
}
