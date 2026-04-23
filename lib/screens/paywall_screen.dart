import 'package:flutter/material.dart';
import '../models/subscription_state.dart';

/// Paywall screen for premium subscription
class PaywallScreen extends StatefulWidget {
  final SubscriptionState subscriptionState;

  const PaywallScreen({
    super.key,
    required this.subscriptionState,
  });

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star,
                size: 80,
                color: Color(0xFFFFD700),
              ),
              const SizedBox(height: 24),
              const Text(
                'SpeakEasy Premium',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Unlock all card packs',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              const _FeatureRow(icon: Icons.library_books, text: 'Access 50+ card packs'),
              const _FeatureRow(icon: Icons.photo_library, text: 'Custom photo cards'),
              const _FeatureRow(icon: Icons.family_restroom, text: 'Family pack included'),
              const _FeatureRow(icon: Icons.restaurant, text: 'Food & drink pack'),
              const SizedBox(height: 48),
              const Text(
                '\$10',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'per year',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _subscribe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Subscribe Now',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Maybe later',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _subscribe() async {
    setState(() => _isLoading = true);
    
    // Mock subscription - in production, integrate with Stripe/IAP
    // For now, just grant premium
    await widget.subscriptionState.grantPremium(
      expiry: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome to Premium!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6366F1), size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Show paywall dialog - returns true if upgraded
Future<bool> showPaywall(BuildContext context) async {
  final subscriptionState = await SubscriptionState.create();
  
  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (context) => PaywallScreen(subscriptionState: subscriptionState),
    ),
  );
  
  return result ?? false;
}