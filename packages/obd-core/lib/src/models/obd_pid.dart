/// Standard OBD-II Mode 01 PIDs
enum ObdPid {
  engineRpm('010C', 'Engine RPM', 'rpm'),
  vehicleSpeed('010D', 'Vehicle Speed', 'km/h'),
  coolantTemp('0105', 'Engine Coolant Temperature', '°C'),
  throttlePosition('0111', 'Throttle Position', '%'),
  fuelLevel('012F', 'Fuel Tank Level', '%'),
  mafFlowRate('0110', 'MAF Air Flow Rate', 'g/s'),
  calculatedEngineLoad('0104', 'Calculated Engine Load', '%'),
  fuelPressure('010A', 'Fuel Pressure', 'kPa'),
  intakeAirTemp('010F', 'Intake Air Temperature', '°C'),
  ambientAirTemp('0146', 'Ambient Air Temperature', '°C'),
  controlModuleVoltage('0142', 'Control Module Voltage', 'V');

  final String code;
  final String label;
  final String unit;

  const ObdPid(this.code, this.label, this.unit);
}
