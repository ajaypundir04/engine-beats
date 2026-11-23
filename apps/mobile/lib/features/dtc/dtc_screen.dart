import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obd_core/obd_core.dart';
import '../../core/theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import 'widgets/dtc_card.dart';

class DtcScreen extends ConsumerStatefulWidget {
  const DtcScreen({super.key});

  @override
  ConsumerState<DtcScreen> createState() => _DtcScreenState();
}

class _DtcScreenState extends ConsumerState<DtcScreen> {
  bool _isScanning = false;
  List<DtcRecord> _detectedCodes = [];
  String? _scanMessage;

  Future<void> _scanDtcs() async {
    final connection = ref.read(obdConnectionProvider);
    if (!connection.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please connect to OBD dongle before scanning.')),
      );
      return;
    }

    setState(() {
      _isScanning = true;
      _scanMessage = 'Querying ECU for Diagnostic Trouble Codes...';
    });

    try {
      final response = await connection.sendCommand(Elm327Commands.mode03RequestDtc, timeoutMs: 3000);
      if (response != null) {
        final records = DtcDecoder.parseToRecords(response);
        setState(() {
          _detectedCodes = records;
          _scanMessage = records.isEmpty
              ? 'No Diagnostic Trouble Codes found. Engine status normal!'
              : 'Found ${records.length} fault code(s).';
        });
      } else {
        setState(() {
          _scanMessage = 'No response received from ECU.';
        });
      }
    } catch (e) {
      setState(() {
        _scanMessage = 'Error during scan: $e';
      });
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _clearDtcs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Trouble Codes?'),
        content: const Text(
          'This will reset the Check Engine light and clear diagnostic fault memory in your vehicle ECU.\n\nMake sure the engine is OFF with ignition ON.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear Codes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final connection = ref.read(obdConnectionProvider);
      final res = await connection.sendCommand(Elm327Commands.mode04ClearDtc);
      if (res != null) {
        setState(() {
          _detectedCodes.clear();
          _scanMessage = 'Trouble codes cleared successfully.';
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ECU trouble codes cleared.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OBD-II Diagnostics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.car_repair, size: 48, color: AppTheme.accentCyan),
                  const SizedBox(height: 12),
                  const Text(
                    'ECU Diagnostic Scan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Read active & pending DTCs across Powertrain, Chassis, Body, and Network modules.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isScanning ? null : _scanDtcs,
                          icon: _isScanning
                              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.search),
                          label: Text(_isScanning ? 'Scanning...' : 'Scan DTCs'),
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
                      if (_detectedCodes.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppTheme.accentRed),
                          tooltip: 'Clear Codes',
                          onPressed: _clearDtcs,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_scanMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _scanMessage!,
                  style: const TextStyle(color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ..._detectedCodes.map((record) => DtcCard(record: record)),
          ],
        ),
      ),
    );
  }
}
