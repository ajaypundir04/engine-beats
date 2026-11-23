import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../obd/dongle_selector_dialog.dart';
import '../obd/obd_connection_service.dart';
import '../obd/obd_polling_service.dart';
import 'widgets/circular_gauge.dart';
import 'widgets/connection_banner.dart';
import 'widgets/metric_card.dart';

final obdConnectionProvider = ChangeNotifierProvider<ObdConnectionService>((ref) {
  return ObdConnectionService();
});

final obdPollingProvider = ChangeNotifierProvider<ObdPollingService>((ref) {
  final conn = ref.watch(obdConnectionProvider);
  return ObdPollingService(conn);
});

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-start polling when connection state becomes connected
    ref.listenManual(obdConnectionProvider, (previous, next) {
      if (next.isConnected && !ref.read(obdPollingProvider).isPolling) {
        ref.read(obdPollingProvider).startPolling();
      } else if (!next.isConnected && ref.read(obdPollingProvider).isPolling) {
        ref.read(obdPollingProvider).stopPolling();
      }
    });
  }

  void _showConnectDialog() {
    showDialog(
      context: context,
      builder: (context) => DongleSelectorDialog(
        onConnect: (host, port) {
          ref.read(obdConnectionProvider).connectTcp(host: host, port: port);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connection = ref.watch(obdConnectionProvider);
    final polling = ref.watch(obdPollingProvider);
    final reading = polling.latestReading;

    final speed = reading?.speedKmh ?? 0.0;
    final rpm = reading?.rpm ?? 0.0;
    final coolant = reading?.coolantTempC ?? 0;
    final throttle = reading?.throttlePosPct ?? 0.0;
    final fuel = reading?.fuelLevelPct ?? 0.0;
    final voltage = reading?.batteryVoltage ?? 12.6;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Cockpit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_ethernet),
            tooltip: 'Configure Dongle',
            onPressed: _showConnectDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ConnectionBanner(
              status: connection.status,
              protocol: connection.currentProtocol,
              onConnectPressed: _showConnectDialog,
              onDisconnectPressed: () => ref.read(obdConnectionProvider).disconnect(),
            ),
            const SizedBox(height: 20),
            // Primary Gauges: Speed & RPM
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircularGauge(
                  value: speed,
                  minValue: 0,
                  maxValue: 220,
                  label: 'SPEED',
                  unit: 'KM/H',
                  activeColor: AppTheme.accentCyan,
                ),
                CircularGauge(
                  value: rpm,
                  minValue: 0,
                  maxValue: 7000,
                  label: 'TACHO',
                  unit: 'RPM',
                  activeColor: rpm > 5000 ? AppTheme.accentRed : AppTheme.accentAmber,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Secondary Telemetry Metrics Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                MetricCard(
                  title: 'Coolant Temp',
                  value: coolant > 0 ? '$coolant' : '--',
                  unit: '°C',
                  icon: Icons.thermostat,
                  iconColor: coolant > 105 ? AppTheme.accentRed : AppTheme.accentCyan,
                ),
                MetricCard(
                  title: 'Throttle Position',
                  value: throttle > 0 ? throttle.toStringAsFixed(1) : '--',
                  unit: '%',
                  icon: Icons.electric_bolt,
                  iconColor: AppTheme.accentAmber,
                ),
                MetricCard(
                  title: 'Battery Voltage',
                  value: voltage.toStringAsFixed(1),
                  unit: 'V',
                  icon: Icons.battery_charging_full,
                  iconColor: Colors.greenAccent,
                ),
                MetricCard(
                  title: 'Fuel Tank Level',
                  value: fuel > 0 ? fuel.toStringAsFixed(0) : '--',
                  unit: '%',
                  icon: Icons.local_gas_station,
                  iconColor: fuel < 15 ? AppTheme.accentRed : AppTheme.accentCyan,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
