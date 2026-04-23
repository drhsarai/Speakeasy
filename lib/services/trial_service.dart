import 'package:shared_preferences/shared_preferences.dart';

/// Manages trial usage counter with persistent storage
class TrialService {
  static const String _trialUsesKey = 'trial_uses_remaining';
  static const int _defaultTrialLimit = 10;

  final SharedPreferences _prefs;

  TrialService(this._prefs);

  /// Get remaining trial uses
  int get usesRemaining => _prefs.getInt(_trialUsesKey) ?? _defaultTrialLimit;

  /// Check if trial is still available
  bool get hasTrialRemaining => usesRemaining > 0;

  /// Use one trial and return updated count
  /// Returns -1 if no trials remaining
  Future<int> useTrial() async {
    final remaining = usesRemaining;
    if (remaining <= 0) return -1;
    
    await _prefs.setInt(_trialUsesKey, remaining - 1);
    return remaining - 1;
  }

  /// Reset trial (for testing or after purchase)
  Future<void> resetTrial() async {
    await _prefs.setInt(_trialUsesKey, _defaultTrialLimit);
  }

  /// Get trial limit
  int get trialLimit => _defaultTrialLimit;

  /// Get usage percentage (0.0 to 1.0)
  double get usagePercentage => 
      (_defaultTrialLimit - usesRemaining) / _defaultTrialLimit;

  /// Factory constructor
  static Future<TrialService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return TrialService(prefs);
  }
}