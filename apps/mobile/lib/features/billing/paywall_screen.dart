import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import 'entitlements_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  int _selectedPlanIndex = 1; // 0 = Monthly, 1 = Annual
  bool _isProcessing = false;

  final List<Map<String, String>> _plans = [
    {
      'title': 'Monthly Pro',
      'price': '€4.99 / month',
      'period': 'Billed monthly. Cancel anytime.',
      'priceId': 'price_pro_monthly',
    },
    {
      'title': 'Annual Pro (Save 33%)',
      'price': '€39.99 / year',
      'period': 'Equivalent to €3.33/month.',
      'priceId': 'price_pro_annual',
    },
  ];

  Future<void> _handleUpgrade() async {
    setState(() => _isProcessing = true);
    final apiClient = ref.read(apiClientProvider);

    try {
      final plan = _plans[_selectedPlanIndex];
      final response = await apiClient.dio.post(
        ApiEndpoints.checkoutSession,
        data: {'priceId': plan['priceId']},
      );

      final checkoutUrl = response.data['checkoutUrl'] as String?;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening secure checkout: $checkoutUrl')),
        );
        ref.invalidate(entitlementsProvider);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout initialization: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Pro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.workspace_premium, size: 64, color: AppTheme.accentAmber),
            const SizedBox(height: 12),
            const Text(
              'Unlock Full Telemetry & Insights',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Everything you need for serious driving analysis, vehicle health, and maintenance tracking.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            _FeatureRow(
              icon: Icons.cloud_sync,
              title: 'Unlimited Cloud Trip Sync',
              subtitle: 'Store every trip, route telemetry, and driving score permanently.',
            ),
            _FeatureRow(
              icon: Icons.troubleshoot,
              title: 'Deep SAE J2012 Diagnostic Insights',
              subtitle: 'Common causes, repair guides, and ECU sensor freeze-frame analysis.',
            ),
            _FeatureRow(
              icon: Icons.file_download,
              title: 'Raw Telemetry & CSV Exports',
              subtitle: 'Download complete time-series data for track days or spreadsheet review.',
            ),
            _FeatureRow(
              icon: Icons.directions_car,
              title: 'Multi-Vehicle Fleet Support',
              subtitle: 'Connect and monitor multiple cars from a single account.',
            ),
            const SizedBox(height: 24),
            ...List.generate(_plans.length, (index) {
              final plan = _plans[index];
              final isSelected = _selectedPlanIndex == index;

              return GestureDetector(
                onTap: () => setState(() => _selectedPlanIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppTheme.accentCyan : Colors.white10,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plan['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(plan['period']!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        ],
                      ),
                      Text(
                        plan['price']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppTheme.accentCyan : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isProcessing ? null : _handleUpgrade,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isProcessing
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Upgrade with Stripe / App Store', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Secure payment via Apple In-App Purchase, Google Play, or Stripe Checkout.\nCancel anytime in Account Settings.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureRow({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppTheme.accentCyan),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
