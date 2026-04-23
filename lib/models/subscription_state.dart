import 'package:shared_preferences/shared_preferences.dart';

/// Manages subscription state locally via SharedPreferences
/// In production, this would verify with a backend
class SubscriptionState {
  static const String _isPremiumKey = 'is_premium';
  static const String _subscriptionExpiryKey = 'subscription_expiry';

  final SharedPreferences _prefs;

  SubscriptionState(this._prefs);

  /// Check if user has premium subscription
  bool get isPremium => _prefs.getBool(_isPremiumKey) ?? false;

  /// Get subscription expiry date (null if not subscribed)
  DateTime? get subscriptionExpiry {
    final expiryStr = _prefs.getString(_subscriptionExpiryKey);
    if (expiryStr == null) return null;
    return DateTime.tryParse(expiryStr);
  }

  /// Check if subscription is active (not expired)
  bool get isSubscriptionActive {
    if (!isPremium) return false;
    final expiry = subscriptionExpiry;
    if (expiry == null) return true; // Lifetime subscription
    return expiry.isAfter(DateTime.now());
  }

  /// Grant premium subscription (mock - in production verifies with backend)
  Future<bool> grantPremium({DateTime? expiry}) async {
    final success = await _prefs.setBool(_isPremiumKey, true);
    if (expiry != null) {
      await _prefs.setString(_subscriptionExpiryKey, expiry.toIso8601String());
    }
    return success;
  }

  /// Revoke premium (for testing/refunds)
  Future<bool> revokePremium() async {
    await _prefs.remove(_subscriptionExpiryKey);
    return await _prefs.setBool(_isPremiumKey, false);
  }

  /// Factory constructor for easy creation
  static Future<SubscriptionState> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SubscriptionState(prefs);
  }
}