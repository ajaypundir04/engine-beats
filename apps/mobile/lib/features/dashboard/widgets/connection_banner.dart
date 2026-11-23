import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../obd/obd_connection_service.dart';

class ConnectionBanner extends StatelessWidget {
  final ObdConnectionStatus status;
  final String protocol;
  final VoidCallback onConnectPressed;
  final VoidCallback onDisconnectPressed;

  const ConnectionBanner({
    super.key,
    required this.status,
    required this.protocol,
    required this.onConnectPressed,
    required this.onDisconnectPressed,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case ObdConnectionStatus.connected:
        statusColor = Colors.greenAccent;
        statusText = 'Connected: $protocol';
        statusIcon = Icons.check_circle;
        break;
      case ObdConnectionStatus.connecting:
        statusColor = AppTheme.accentAmber;
        statusText = 'Connecting to OBD dongle...';
        statusIcon = Icons.sync;
        break;
      case ObdConnectionStatus.initializing:
        statusColor = AppTheme.accentCyan;
        statusText = 'Initializing ELM327 protocol...';
        statusIcon = Icons.settings_input_component;
        break;
      case ObdConnectionStatus.error:
        statusColor = AppTheme.accentRed;
        statusText = 'Connection error';
        statusIcon = Icons.error_outline;
        break;
      case ObdConnectionStatus.disconnected:
      default:
        statusColor = AppTheme.textMuted;
        statusText = 'OBD Disconnected';
        statusIcon = Icons.power_off;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(fontSize: 13, color: statusColor, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (status == ObdConnectionStatus.connected)
            TextButton(
              onPressed: onDisconnectPressed,
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: const Text('Disconnect', style: TextStyle(color: AppTheme.accentRed, fontSize: 12)),
            )
          else
            ElevatedButton(
              onPressed: status == ObdConnectionStatus.connecting ? null : onConnectPressed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
              ),
              child: const Text('Connect', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}
