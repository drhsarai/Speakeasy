import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TTS configuration with persistence
class TtsConfig {
  final String voiceId;
  final double speed;
  final double pitch;
  final double volume;

  const TtsConfig({
    this.voiceId = 'default',
    this.speed = 1.0,
    this.pitch = 1.0,
    this.volume = 1.0,
  });

  TtsConfig copyWith({
    String? voiceId,
    double? speed,
    double? pitch,
    double? volume,
  }) {
    return TtsConfig(
      voiceId: voiceId ?? this.voiceId,
      speed: speed ?? this.speed,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
    );
  }

  Map<String, dynamic> toJson() => {
        'voiceId': voiceId,
        'speed': speed,
        'pitch': pitch,
        'volume': volume,
      };

  factory TtsConfig.fromJson(Map<String, dynamic> json) => TtsConfig(
        voiceId: json['voiceId'] as String? ?? 'default',
        speed: (json['speed'] as num?)?.toDouble() ?? 1.0,
        pitch: (json['pitch'] as num?)?.toDouble() ?? 1.0,
        volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      );
}

/// Manages TTS configuration persistence
class TtsConfigService {
  static const String _ttsConfigKey = 'tts_config';

  final SharedPreferences _prefs;

  TtsConfigService(this._prefs);

  /// Get current TTS config
  TtsConfig get config {
    final jsonStr = _prefs.getString(_ttsConfigKey);
    if (jsonStr == null) return const TtsConfig();
    try {
      return TtsConfig.fromJson(jsonDecode(jsonStr));
    } catch (e) {
      return const TtsConfig();
    }
  }

  /// Save TTS config
  Future<bool> saveConfig(TtsConfig config) async {
    return await _prefs.setString(_ttsConfigKey, jsonEncode(config.toJson()));
  }

  /// Update speed
  Future<bool> setSpeed(double speed) async {
    return saveConfig(config.copyWith(speed: speed.clamp(0.5, 2.0)));
  }

  /// Update voice
  Future<bool> setVoice(String voiceId) async {
    return saveConfig(config.copyWith(voiceId: voiceId));
  }

  /// Update volume
  Future<bool> setVolume(double volume) async {
    return saveConfig(config.copyWith(volume: volume.clamp(0.0, 1.0)));
  }

  /// Reset to defaults
  Future<bool> reset() async {
    return saveConfig(const TtsConfig());
  }

  /// Factory constructor
  static Future<TtsConfigService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return TtsConfigService(prefs);
  }
}