class ApiEndpoints {
  static const String vehicles = '/api/v1/vehicles';
  static const String telemetryBatches = '/api/v1/telemetry/batches';
  static const String trips = '/api/v1/trips';
  static const String startTrip = '/api/v1/trips/start';
  static String endTrip(String tripId) => '/api/v1/trips/$tripId/end';
  static const String dtcRecords = '/api/v1/dtc/records';
  static String dtcVehicle(String vehicleId) => '/api/v1/dtc/records/vehicle/$vehicleId';
  static String dtcLookup(String code) => '/api/v1/dtc/lookup/$code';
  static const String entitlements = '/api/v1/billing/entitlements';
  static const String checkoutSession = '/api/v1/billing/checkout-session';
  static const String exportTripsCsv = '/api/v1/exports/trips.csv';
}
