/// Represents an instant snapshot of vehicle telemetry reading
class TelemetryReading {
  final DateTime timestamp;
  final double? rpm;
  final double? speedKmh;
  final int? coolantTempC;
  final double? throttlePosPct;
  final double? fuelLevelPct;
  final double? mafGps;
  final double? batteryVoltage;
  final int? ambientTempC;
  final double? engineLoadPct;

  const TelemetryReading({
    required this.timestamp,
    this.rpm,
    this.speedKmh,
    this.coolantTempC,
    this.throttlePosPct,
    this.fuelLevelPct,
    this.mafGps,
    this.batteryVoltage,
    this.ambientTempC,
    this.engineLoadPct,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        if (rpm != null) 'rpm': rpm,
        if (speedKmh != null) 'speedKmh': speedKmh,
        if (coolantTempC != null) 'coolantTempC': coolantTempC,
        if (throttlePosPct != null) 'throttlePosPct': throttlePosPct,
        if (fuelLevelPct != null) 'fuelLevelPct': fuelLevelPct,
        if (mafGps != null) 'mafGps': mafGps,
        if (batteryVoltage != null) 'batteryVoltage': batteryVoltage,
        if (ambientTempC != null) 'ambientTempC': ambientTempC,
        if (engineLoadPct != null) 'engineLoadPct': engineLoadPct,
      };

  factory TelemetryReading.fromJson(Map<String, dynamic> json) {
    return TelemetryReading(
      timestamp: DateTime.parse(json['timestamp'] as String),
      rpm: (json['rpm'] as num?)?.toDouble(),
      speedKmh: (json['speedKmh'] as num?)?.toDouble(),
      coolantTempC: json['coolantTempC'] as int?,
      throttlePosPct: (json['throttlePosPct'] as num?)?.toDouble(),
      fuelLevelPct: (json['fuelLevelPct'] as num?)?.toDouble(),
      mafGps: (json['mafGps'] as num?)?.toDouble(),
      batteryVoltage: (json['batteryVoltage'] as num?)?.toDouble(),
      ambientTempC: json['ambientTempC'] as int?,
      engineLoadPct: (json['engineLoadPct'] as num?)?.toDouble(),
    );
  }
}
