/// Represents a diagnostic trouble code (e.g. P0300)
class DtcRecord {
  final String code;
  final String? description;
  final String severity; // CRITICAL, WARNING, INFO
  final bool milActive;
  final DateTime detectedAt;

  const DtcRecord({
    required this.code,
    this.description,
    this.severity = 'WARNING',
    this.milActive = false,
    required this.detectedAt,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        if (description != null) 'description': description,
        'severity': severity,
        'milActive': milActive,
        'detectedAt': detectedAt.toIso8601String(),
      };
}
