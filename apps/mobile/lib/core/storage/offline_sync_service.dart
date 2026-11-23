import 'dart:async';
import 'package:dio/dio.dart';
import 'package:obd_core/obd_core.dart';
import 'package:uuid/uuid.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

class OfflineSyncService {
  final ApiClient _apiClient;
  final List<TelemetryReading> _buffer = [];
  final _uuid = const Uuid();
  Timer? _syncTimer;
  String? currentVehicleId;
  String? currentTripId;

  OfflineSyncService(this._apiClient);

  void startPeriodicSync({Duration interval = const Duration(seconds: 15)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (_) => flushBuffer());
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  void addReading(TelemetryReading reading) {
    _buffer.add(reading);
  }

  Future<bool> flushBuffer() async {
    if (_buffer.isEmpty || currentVehicleId == null) {
      return false;
    }

    final batchToUpload = List<TelemetryReading>.from(_buffer);
    final batchId = _uuid.v4();

    final payload = {
      'batchId': batchId,
      'vehicleId': currentVehicleId,
      if (currentTripId != null) 'tripId': currentTripId,
      'readings': batchToUpload.map((r) => r.toJson()).toList(),
    };

    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.telemetryBatches,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Remove uploaded items from buffer
        _buffer.removeRange(0, batchToUpload.length);
        return true;
      }
    } on DioException {
      // Keep in local buffer for next retry when connectivity returns
    }

    return false;
  }

  int get pendingCount => _buffer.length;

  void dispose() {
    _syncTimer?.cancel();
  }
}
