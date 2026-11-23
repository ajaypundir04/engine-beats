import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../auth/auth_controller.dart';

class TripRecordingState {
  final bool isRecording;
  final String? activeTripId;
  final DateTime? startedAt;
  final double distanceKm;
  final double maxSpeedKmh;
  final double avgSpeedKmh;
  final double fuelConsumedLiters;

  const TripRecordingState({
    this.isRecording = false,
    this.activeTripId,
    this.startedAt,
    this.distanceKm = 0.0,
    this.maxSpeedKmh = 0.0,
    this.avgSpeedKmh = 0.0,
    this.fuelConsumedLiters = 0.0,
  });

  TripRecordingState copyWith({
    bool? isRecording,
    String? activeTripId,
    DateTime? startedAt,
    double? distanceKm,
    double? maxSpeedKmh,
    double? avgSpeedKmh,
    double? fuelConsumedLiters,
  }) {
    return TripRecordingState(
      isRecording: isRecording ?? this.isRecording,
      activeTripId: activeTripId ?? this.activeTripId,
      startedAt: startedAt ?? this.startedAt,
      distanceKm: distanceKm ?? this.distanceKm,
      maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
      avgSpeedKmh: avgSpeedKmh ?? this.avgSpeedKmh,
      fuelConsumedLiters: fuelConsumedLiters ?? this.fuelConsumedLiters,
    );
  }
}

final tripRecordingProvider =
    StateNotifierProvider<TripRecordingController, TripRecordingState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TripRecordingController(apiClient);
});

class TripRecordingController extends StateNotifier<TripRecordingState> {
  final ApiClient _apiClient;

  TripRecordingController(this._apiClient) : super(const TripRecordingState());

  Future<void> startTrip(String vehicleId, {String? title}) async {
    try {
      final res = await _apiClient.dio.post(ApiEndpoints.startTrip, data: {
        'vehicleId': vehicleId,
        'title': title ?? 'Trip at ${DateTime.now().hour}:${DateTime.now().minute}',
      });

      final tripId = res.data['id'] as String?;
      state = state.copyWith(
        isRecording: true,
        activeTripId: tripId,
        startedAt: DateTime.now(),
        distanceKm: 0.0,
        maxSpeedKmh: 0.0,
        avgSpeedKmh: 0.0,
        fuelConsumedLiters: 0.0,
      );
    } catch (_) {
      // Offline fallback: start trip locally
      state = state.copyWith(
        isRecording: true,
        activeTripId: 'offline_${DateTime.now().millisecondsSinceEpoch}',
        startedAt: DateTime.now(),
        distanceKm: 0.0,
        maxSpeedKmh: 0.0,
        avgSpeedKmh: 0.0,
      );
    }
  }

  void updateMetrics(double currentSpeedKmh, double dtSeconds) {
    if (!state.isRecording) return;

    final newDistance = state.distanceKm + (currentSpeedKmh * (dtSeconds / 3600.0));
    final newMaxSpeed = currentSpeedKmh > state.maxSpeedKmh ? currentSpeedKmh : state.maxSpeedKmh;

    state = state.copyWith(
      distanceKm: newDistance,
      maxSpeedKmh: newMaxSpeed,
    );
  }

  Future<void> endTrip() async {
    if (!state.isRecording) return;

    final tripId = state.activeTripId;
    if (tripId != null && !tripId.startsWith('offline_')) {
      try {
        await _apiClient.dio.post(ApiEndpoints.endTrip(tripId), data: {
          'distanceKm': state.distanceKm,
          'maxSpeedKmh': state.maxSpeedKmh,
          'avgSpeedKmh': state.avgSpeedKmh,
          'fuelConsumedLiters': state.fuelConsumedLiters,
        });
      } catch (_) {}
    }

    state = const TripRecordingState();
  }
}
