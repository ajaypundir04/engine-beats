import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:obd_core/obd_core.dart';
import 'obd_connection_service.dart';

class ObdPollingService extends ChangeNotifier {
  final ObdConnectionService _connection;
  Timer? _pollingTimer;
  bool _isPolling = false;

  TelemetryReading? _latestReading;
  final StreamController<TelemetryReading> _readingStreamController =
      StreamController<TelemetryReading>.broadcast();

  TelemetryReading? get latestReading => _latestReading;
  Stream<TelemetryReading> get readingStream => _readingStreamController.stream;
  bool get isPolling => _isPolling;

  ObdPollingService(this._connection);

  void startPolling({Duration interval = const Duration(milliseconds: 250)}) {
    if (_isPolling) return;
    _isPolling = true;
    _pollingTimer = Timer.periodic(interval, (_) => _pollNextSnapshot());
    notifyListeners();
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
    notifyListeners();
  }

  Future<void> _pollNextSnapshot() async {
    if (!_connection.isConnected) return;

    double? rpm;
    double? speed;
    int? coolant;
    double? throttle;
    double? fuel;
    double? maf;
    double? voltage;

    // 1. Poll RPM
    final rawRpm = await _connection.sendCommand(ObdPid.engineRpm.code);
    if (rawRpm != null) rpm = PidDecoder.decodeRpm(rawRpm);

    // 2. Poll Speed
    final rawSpeed = await _connection.sendCommand(ObdPid.vehicleSpeed.code);
    if (rawSpeed != null) speed = PidDecoder.decodeSpeed(rawSpeed);

    // 3. Poll Throttle
    final rawThrottle = await _connection.sendCommand(ObdPid.throttlePosition.code);
    if (rawThrottle != null) throttle = PidDecoder.decodeThrottlePos(rawThrottle);

    // 4. Poll Coolant Temp
    final rawCoolant = await _connection.sendCommand(ObdPid.coolantTemp.code);
    if (rawCoolant != null) coolant = PidDecoder.decodeCoolantTemp(rawCoolant);

    // 5. Poll MAF
    final rawMaf = await _connection.sendCommand(ObdPid.mafFlowRate.code);
    if (rawMaf != null) maf = PidDecoder.decodeMaf(rawMaf);

    // 6. Poll Battery Voltage
    final rawVoltage = await _connection.sendCommand(Elm327Commands.batteryVoltage);
    if (rawVoltage != null) voltage = PidDecoder.decodeBatteryVoltage(rawVoltage);

    final reading = TelemetryReading(
      timestamp: DateTime.now(),
      rpm: rpm,
      speedKmh: speed,
      coolantTempC: coolant,
      throttlePosPct: throttle,
      fuelLevelPct: fuel,
      mafGps: maf,
      batteryVoltage: voltage,
    );

    _latestReading = reading;
    _readingStreamController.add(reading);
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    _readingStreamController.close();
    super.dispose();
  }
}
