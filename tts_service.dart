// services/tts_service.dart

import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final FlutterTts _tts = FlutterTts();

  // FIX: Proper BCP-47 locale codes for each supported language.
  // Previously _currentLang was set by slicing the display name (e.g. '中文'.substring(0,2)
  // produces '中文', not a valid locale). Use an explicit map instead.
  static const Map<String, String> _localeMap = {
    'en': 'en-AU',
    'es': 'es-ES',
    'fr': 'fr-FR',
    'de': 'de-DE',
    'zh': 'zh-CN',
  };

  static Future<void> init() async {
    await _tts.setLanguage('en-AU');
    await _tts.setSpeechRate(0.9);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  /// Speak [text] in the given short language code (e.g. 'en', 'fr').
  /// Falls back to 'en-AU' if the code is not recognised.
  static Future<void> speak(String text, {String lang = 'en'}) async {
    final locale = _localeMap[lang] ?? 'en-AU';
    await _tts.setLanguage(locale);
    await _tts.speak(text);
  }

  static Future<void> stop() async {
    await _tts.stop();
  }
}
