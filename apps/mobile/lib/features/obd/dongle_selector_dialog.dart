import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';

class DongleSelectorDialog extends StatefulWidget {
  final Function(String host, int port) onConnect;
  final VoidCallback onConnectVirtual;

  const DongleSelectorDialog({
    super.key,
    required this.onConnect,
    required this.onConnectVirtual,
  });

  @override
  State<DongleSelectorDialog> createState() => _DongleSelectorDialogState();
}

class _DongleSelectorDialogState extends State<DongleSelectorDialog> {
  final _hostController = TextEditingController(text: AppConfig.defaultDongleHost);
  final _portController = TextEditingController(text: AppConfig.defaultDonglePort.toString());

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Connect to Vehicle / OBD'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                widget.onConnectVirtual();
              },
              icon: const Icon(Icons.play_circle_fill),
              label: const Text('Run Virtual Car Simulator'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('OR HARDWARE DONGLE', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: 'Host / IP Address',
                hintText: '127.0.0.1 or 192.168.0.10',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _portController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'TCP Port',
                hintText: '35000',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    _hostController.text = '127.0.0.1';
                    _portController.text = '35000';
                  },
                  child: const Text('127.0.0.1'),
                ),
                TextButton(
                  onPressed: () {
                    _hostController.text = '10.0.2.2';
                    _portController.text = '35000';
                  },
                  child: const Text('Android 10.0.2.2'),
                ),
              ],
            )
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final host = _hostController.text.trim();
            final port = int.tryParse(_portController.text.trim()) ?? 35000;
            Navigator.pop(context);
            widget.onConnect(host, port);
          },
          child: const Text('Connect Socket'),
        ),
      ],
    );
  }
}
