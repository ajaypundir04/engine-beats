import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';

class DongleSelectorDialog extends StatefulWidget {
  final Function(String host, int port) onConnect;

  const DongleSelectorDialog({super.key, required this.onConnect});

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
      title: const Text('Connect to OBD Dongle / Emulator'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                child: const Text('Local Host'),
              ),
              TextButton(
                onPressed: () {
                  _hostController.text = '10.0.2.2';
                  _portController.text = '35000';
                },
                child: const Text('Android Emul'),
              ),
            ],
          )
        ],
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
          child: const Text('Connect'),
        ),
      ],
    );
  }
}
