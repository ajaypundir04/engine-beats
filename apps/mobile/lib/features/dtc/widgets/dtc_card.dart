import 'package:flutter/material.dart';
import 'package:obd_core/obd_core.dart';
import '../../../core/theme/app_theme.dart';

class DtcCard extends StatelessWidget {
  final DtcRecord record;

  const DtcCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    Color severityColor;
    switch (record.severity.toUpperCase()) {
      case 'CRITICAL':
        severityColor = AppTheme.accentRed;
        break;
      case 'WARNING':
        severityColor = AppTheme.accentAmber;
        break;
      case 'INFO':
      default:
        severityColor = AppTheme.accentCyan;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: severityColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record.code,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.1),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: severityColor.withOpacity(0.4)),
                ),
                child: Text(
                  record.severity.toUpperCase(),
                  style: TextStyle(color: severityColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            record.description ?? 'Standard Diagnostic Trouble Code',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                record.milActive ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                size: 16,
                color: record.milActive ? AppTheme.accentAmber : Colors.greenAccent,
              ),
              const SizedBox(width: 6),
              Text(
                record.milActive ? 'Check Engine Light (MIL) Active' : 'Pending / Stored Code',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
