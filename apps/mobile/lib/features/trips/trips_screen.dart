import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../billing/entitlements_provider.dart';
import '../billing/paywall_screen.dart';
import 'trip_recording_controller.dart';

class TripsScreen extends ConsumerWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripState = ref.watch(tripRecordingProvider);
    final entitlements = ref.watch(entitlementsProvider);
    final isPremium = entitlements.value?.isPremium ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Computer & History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export CSV',
            onPressed: () {
              if (!isPremium) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaywallScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading trips.csv...')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Active Trip Banner / Recorder
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: tripState.isRecording ? AppTheme.accentCyan : Colors.white10,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tripState.isRecording ? 'ACTIVE TRIP RECORDING' : 'READY TO DRIVE',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: tripState.isRecording ? AppTheme.accentCyan : AppTheme.textMuted,
                          letterSpacing: 1.1,
                        ),
                      ),
                      if (tripState.isRecording)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppTheme.accentCyan,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _TripStat(
                        label: 'DISTANCE',
                        value: '${tripState.distanceKm.toStringAsFixed(1)} km',
                      ),
                      _TripStat(
                        label: 'MAX SPEED',
                        value: '${tripState.maxSpeedKmh.toInt()} km/h',
                      ),
                      _TripStat(
                        label: 'FUEL',
                        value: '${tripState.fuelConsumedLiters.toStringAsFixed(1)} L',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (tripState.isRecording) {
                        ref.read(tripRecordingProvider.notifier).endTrip();
                      } else {
                        ref.read(tripRecordingProvider.notifier).startTrip('default_vehicle');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tripState.isRecording ? AppTheme.accentRed : AppTheme.accentCyan,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      tripState.isRecording ? 'Stop & Save Trip' : 'Start Recording Trip',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Past Trips',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (!isPremium)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentAmber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.accentAmber.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, color: AppTheme.accentAmber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Cloud Trip History Locked',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Upgrade to EngineBeats Pro for unlimited cloud sync and CSV exports.',
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TripStat extends StatelessWidget {
  final String label;
  final String value;

  const _TripStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
      ],
    );
  }
}
