import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages PIN security for Carer Mode with hashed storage
class PinService {
  static const String _pinHashKey = 'carer_pin_hash';
  static const String _pinSaltKey = 'carer_pin_salt';

  final SharedPreferences _prefs;

  PinService(this._prefs);

  /// Check if PIN is set
  bool get isPinSet => _prefs.containsKey(_pinHashKey);

  /// Hash PIN with salt for secure storage
  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode(pin + salt);
    return sha256.convert(bytes).toString();
  }

  /// Set new PIN
  Future<bool> setPin(String pin) async {
    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw ArgumentError('PIN must be exactly 4 digits');
    }
    
    // Generate random salt
    final salt = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Hash and store
    final hash = _hashPin(pin, salt);
    
    await _prefs.setString(_pinSaltKey, salt);
    return await _prefs.setString(_pinHashKey, hash);
  }

  /// Verify PIN
  bool verifyPin(String pin) {
    if (!isPinSet) return false;
    
    final salt = _prefs.getString(_pinSaltKey);
    final storedHash = _prefs.getString(_pinHashKey);
    
    if (salt == null || storedHash == null) return false;
    
    final inputHash = _hashPin(pin, salt);
    return inputHash == storedHash;
  }

  /// Remove PIN
  Future<bool> removePin() async {
    await _prefs.remove(_pinSaltKey);
    return await _prefs.remove(_pinHashKey);
  }

  /// Change PIN (verifies old PIN first)
  Future<bool> changePin(String oldPin, String newPin) async {
    if (!verifyPin(oldPin)) return false;
    return setPin(newPin);
  }

  /// Factory constructor
  static Future<PinService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PinService(prefs);
  }
}