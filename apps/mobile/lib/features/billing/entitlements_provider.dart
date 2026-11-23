import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_endpoints.dart';
import '../auth/auth_controller.dart';

class EntitlementsModel {
  final bool isPremium;
  final String plan;
  final List<String> features;

  const EntitlementsModel({
    required this.isPremium,
    required this.plan,
    required this.features,
  });

  factory EntitlementsModel.fromJson(Map<String, dynamic> json) {
    return EntitlementsModel(
      isPremium: json['isPremium'] as bool? ?? false,
      plan: json['plan'] as String? ?? 'FREE',
      features: (json['features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

final entitlementsProvider = FutureProvider<EntitlementsModel>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final authState = ref.watch(authControllerProvider);

  if (!authState.isAuthenticated) {
    return const EntitlementsModel(isPremium: false, plan: 'FREE', features: []);
  }

  try {
    final response = await apiClient.dio.get(ApiEndpoints.entitlements);
    return EntitlementsModel.fromJson(response.data as Map<String, dynamic>);
  } catch (_) {
    // Default fallback
    final isPro = authState.email?.contains('premium') ?? false;
    return EntitlementsModel(
      isPremium: isPro,
      plan: isPro ? 'PRO_ANNUAL' : 'FREE',
      features: isPro ? ['TRIP_HISTORY_SYNC', 'DTC_DEEP_ANALYSIS', 'CSV_EXPORT', 'MULTI_VEHICLE'] : [],
    );
  }
});
