import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import 'auth_state.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthController(apiClient);
});

class AuthController extends StateNotifier<AuthState> {
  final ApiClient _apiClient;

  AuthController(this._apiClient) : super(const AuthState());

  /// Log in with Keycloak or test demo credentials
  Future<void> loginWithCredentials(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // In production, flutter_appauth initiates PKCE browser flow.
      // For local testing/demo, mock token or direct grant is used.
      await Future.delayed(const Duration(milliseconds: 600));

      final token = 'jwt_token_${DateTime.now().millisecondsSinceEpoch}';
      final userId = email.contains('premium') ? 'usr_premium_001' : 'usr_demo_001';

      _apiClient.setAccessToken(token);

      state = state.copyWith(
        isAuthenticated: true,
        userId: userId,
        email: email,
        accessToken: token,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void logout() {
    _apiClient.setAccessToken(null);
    state = const AuthState();
  }
}
