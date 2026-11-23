import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:obd_core/obd_core.dart';
import '../../core/config/app_config.dart';
import 'socket/socket_transport.dart';

enum ObdConnectionStatus {
  disconnected,
  connecting,
  initializing,
  connected,
  error,
}

class ObdConnectionService extends ChangeNotifier {
  late SocketTransport _transport;
  final Elm327StreamParser _parser = Elm327StreamParser();
  StreamSubscription? _parserSubscription;

  ObdConnectionStatus _status = ObdConnectionStatus.disconnected;
  String? _errorMessage;
  String _currentProtocol = 'Unknown';
  Completer<String>? _pendingCommand;
  bool _isVirtual = false;

  // Virtual Vehicle Simulation Physics
  double _simTime = 0.0;
  final List<String> _simDtcs = ['P0171', 'P0300'];

  ObdConnectionStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get currentProtocol => _currentProtocol;
  bool get isConnected => _status == ObdConnectionStatus.connected;
  bool get isVirtual => _isVirtual;

  ObdConnectionService() {
    _transport = SocketTransport();
    _parserSubscription = _parser.stream.listen(_handleIncomingResponse);
  }

  void _handleIncomingResponse(String response) {
    if (_pendingCommand != null && !_pendingCommand!.isCompleted) {
      _pendingCommand!.complete(response);
    }
  }

  /// Automatically connect: on Web or when no dongle is available, uses the Virtual Car
  Future<void> autoConnect() async {
    if (kIsWeb) {
      await connectVirtual();
    } else {
      final success = await connectTcp();
      if (!success) {
        // Fallback to built-in virtual car if socket is unreachable
        await connectVirtual();
      }
    }
  }

  /// Connect to the Built-in Virtual Car Simulator (Works on Chrome/Web & Desktop)
  Future<bool> connectVirtual() async {
    _status = ObdConnectionStatus.connecting;
    _errorMessage = null;
    _isVirtual = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 250));
    _status = ObdConnectionStatus.initializing;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 250));
    _currentProtocol = 'Virtual ISO 15765-4 (CAN 11/500)';
    _status = ObdConnectionStatus.connected;
    notifyListeners();
    return true;
  }

  /// Connect to WiFi/TCP OBD dongle or python simulator
  Future<bool> connectTcp({
    String host = AppConfig.defaultDongleHost,
    int port = AppConfig.defaultDonglePort,
  }) async {
    if (kIsWeb) {
      // Web browsers cannot open raw TCP sockets due to sandbox restrictions
      return await connectVirtual();
    }

    _status = ObdConnectionStatus.connecting;
    _errorMessage = null;
    _isVirtual = false;
    notifyListeners();

    final connected = await _transport.connect(
      host,
      port,
      (data) => _parser.addData(data),
      (err) => _handleDisconnect(err),
    );

    if (!connected) {
      return false;
    }

    _status = ObdConnectionStatus.initializing;
    notifyListeners();

    // Initialize ELM327 dongle
    final initialized = await _runInitSequence();
    if (initialized) {
      _status = ObdConnectionStatus.connected;
      notifyListeners();
      return true;
    } else {
      _handleDisconnect('ELM327 initialization failed');
      return false;
    }
  }

  Future<bool> _runInitSequence() async {
    try {
      await sendCommand(Elm327Commands.reset, timeoutMs: 2000);
      await sendCommand(Elm327Commands.echoOff);
      await sendCommand(Elm327Commands.headersOff);
      await sendCommand(Elm327Commands.spacesOff);
      await sendCommand(Elm327Commands.autoProtocol);

      final dp = await sendCommand(Elm327Commands.describeProtocol);
      if (dp != null && dp.isNotEmpty) {
        _currentProtocol = dp;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sends an AT or OBD-II PID command and awaits response
  Future<String?> sendCommand(String cmd, {int timeoutMs = 1500}) async {
    if (_isVirtual) {
      return _handleVirtualCommand(cmd);
    }

    _pendingCommand = Completer<String>();
    final formatted = '${cmd.trim()}\r';
    _transport.send(formatted);

    try {
      return await _pendingCommand!.future.timeout(Duration(milliseconds: timeoutMs));
    } on TimeoutException {
      return null;
    }
  }

  /// In-memory ELM327 response generator with dynamic physics for Web & Demo mode
  String _handleVirtualCommand(String cmd) {
    final normalized = cmd.trim().toUpperCase().replaceAll(' ', '');

    // AT Commands
    if (normalized.startsWith('AT')) {
      if (normalized == 'ATZ') return 'ELM327 v1.5';
      if (normalized == 'ATE0' || normalized == 'ATE1') return 'OK';
      if (normalized == 'ATH0' || normalized == 'ATH1') return 'OK';
      if (normalized == 'ATS0' || normalized == 'ATS1') return 'OK';
      if (normalized.startsWith('ATSP')) return 'OK';
      if (normalized == 'ATDP') return _currentProtocol;
      if (normalized == 'ATRV') return '14.1V';
      if (normalized == 'ATI') return 'ELM327 v1.5';
      return 'OK';
    }

    // Advance driving cycle physics
    _simTime += 0.25;
    final cycle = (sin(_simTime * 0.2) + 1.0) / 2.0; // 0.0 to 1.0
    final rpm = 850.0 + (cycle * 2600.0) + (sin(_simTime * 2.0) * 60.0);
    final speed = cycle * 95.0;
    final throttle = 14.0 + (cycle * 55.0);
    const coolant = 90;
    const fuel = 68.0;

    // Mode 01 standard PIDs
    if (normalized == '010C') {
      // RPM ((A*256 + B)/4)
      final raw = (rpm * 4.0).toInt();
      final a = (raw >> 8) & 0xFF;
      final b = raw & 0xFF;
      return '41 0C ${a.toRadixString(16).padLeft(2, '0').toUpperCase()} ${b.toRadixString(16).padLeft(2, '0').toUpperCase()}';
    } else if (normalized == '010D') {
      // Speed
      final s = speed.clamp(0, 255).toInt();
      return '41 0D ${s.toRadixString(16).padLeft(2, '0').toUpperCase()}';
    } else if (normalized == '0105') {
      // Coolant Temp (A - 40)
      final c = (coolant + 40).clamp(0, 255);
      return '41 05 ${c.toRadixString(16).padLeft(2, '0').toUpperCase()}';
    } else if (normalized == '0111') {
      // Throttle (A * 100 / 255)
      final th = ((throttle / 100.0) * 255).clamp(0, 255).toInt();
      return '41 11 ${th.toRadixString(16).padLeft(2, '0').toUpperCase()}';
    } else if (normalized == '012F') {
      // Fuel Level (A * 100 / 255)
      final f = ((fuel / 100.0) * 255).clamp(0, 255).toInt();
      return '41 2F ${f.toRadixString(16).padLeft(2, '0').toUpperCase()}';
    } else if (normalized == '0110') {
      // MAF
      final raw = ((3.2 + (rpm / 200.0)) * 100.0).toInt();
      final a = (raw >> 8) & 0xFF;
      final b = raw & 0xFF;
      return '41 10 ${a.toRadixString(16).padLeft(2, '0').toUpperCase()} ${b.toRadixString(16).padLeft(2, '0').toUpperCase()}';
    }

    // Mode 03: Request Diagnostic Trouble Codes (DTCs)
    if (normalized == '03') {
      if (_simDtcs.isEmpty) {
        return '43 00 00 00 00 00 00';
      }
      return '43 01 71 03 00 00 00'; // P0171, P0300
    }

    // Mode 04: Clear Diagnostic Trouble Codes
    if (normalized == '04') {
      _simDtcs.clear();
      return '44';
    }

    return 'NO DATA';
  }

  void disconnect() {
    _handleDisconnect(null);
  }

  void _handleDisconnect(String? reason) {
    _transport.destroy();
    _isVirtual = false;
    _status = ObdConnectionStatus.disconnected;
    _errorMessage = reason;
    notifyListeners();
  }

  @override
  void dispose() {
    _parserSubscription?.cancel();
    _parser.dispose();
    _transport.destroy();
    super.dispose();
  }
}
