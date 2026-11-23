-- Seed standard SAE J2012 Diagnostic Trouble Code definitions

INSERT INTO dtc_definitions (code, system, description, severity, common_causes) VALUES
('P0171', 'Powertrain / Fuel & Air Metering', 'System Too Lean (Bank 1)', 'MEDIUM', 'Dirty MAF sensor, vacuum leak, faulty PCV valve, clogged fuel filter or injectors'),
('P0300', 'Powertrain / Ignition System', 'Random/Multiple Cylinder Misfire Detected', 'CRITICAL', 'Worn spark plugs, failing ignition coil packs, low fuel pressure, vacuum leak'),
('P0301', 'Powertrain / Ignition System', 'Cylinder 1 Misfire Detected', 'CRITICAL', 'Faulty spark plug or coil on cylinder 1, bad fuel injector, low cylinder compression'),
('P0420', 'Powertrain / Emissions', 'Catalyst System Efficiency Below Threshold (Bank 1)', 'MEDIUM', 'Failing catalytic converter, downstream oxygen sensor malfunction, exhaust leak'),
('P0128', 'Powertrain / Engine Cooling', 'Coolant Thermostat Temperature Below Regulating Range', 'LOW', 'Thermostat stuck open, faulty engine coolant temperature sensor'),
('P0101', 'Powertrain / Fuel & Air Metering', 'Mass Air Flow (MAF) Circuit Range/Performance Problem', 'MEDIUM', 'Dirty or faulty MAF sensor, cracked air intake boot, dirty air filter'),
('P0442', 'Powertrain / Evaporative Emission', 'Evaporative Emission Control System Leak Detected (Small Leak)', 'LOW', 'Loose or damaged gas cap, cracked EVAP canister vent solenoid or vapor hose'),
('P0455', 'Powertrain / Evaporative Emission', 'Evaporative Emission Control System Leak Detected (Gross Leak)', 'LOW', 'Missing or loose gas cap, disconnected purge valve hose, cracked charcoal canister'),
('C0035', 'Chassis / Brake System', 'Left Front Wheel Speed Sensor Circuit', 'MEDIUM', 'Damaged wheel speed sensor wiring, debris on tone ring, failing wheel hub bearing'),
('U0100', 'Network / CAN Bus Communication', 'Lost Communication with Engine Control Module (ECM/PCM)', 'CRITICAL', 'Blown fuse, CAN bus wiring short or open, loose battery terminal, faulty ECM')
ON CONFLICT (code) DO NOTHING;
