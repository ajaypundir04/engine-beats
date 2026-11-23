import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:obd_core/obd_core.dart';
import '../../core/config/app_config.dart';

enum ObdConnectionStatus {
  disconnected,
  connecting,
  initializing,
  connected,
  error,
}

class ObdConnectionService extends ChangeNotifier {
  Socket? _socket;
  final Elm327StreamParser _parser = Elm327StreamParser();
  StreamSubscription? _parserSubscription;

  ObdConnectionStatus _status = ObdConnectionStatus.disconnected;
  String? _errorMessage;
  String _currentProtocol = 'Unknown';
  Completer<String>? _pendingCommand;

  ObdConnectionStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get currentProtocol => _currentProtocol;
  bool get isConnected => _status == ObdConnectionStatus.connected;

  ObdConnectionService() {
    _parserSubscription = _parser.stream.listen(_handleIncomingResponse);
  }

  void _handleIncomingResponse(String response) {
    if (_pendingCommand != null && !_pendingCommand!.isCompleted) {
      _pendingCommand!.complete(response);
    }
  }

  /// Connect to WiFi/TCP OBD dongle or simulator
  Future<bool> connectTcp({
    String host = AppConfig.defaultDongleHost,
    int port = AppConfig.defaultDonglePort,
  }) async {
    _status = ObdConnectionStatus.connecting;
    _errorMessage = null;
    notifyListeners();

    try {
      _socket = await Socket.connect(host, port, timeout: const Duration(seconds: 5));
      _socket!.listen(
        (data) => _parser.addData(utf8.decode(data, allowMalformed: true)),
        onError: (err) => _handleDisconnect('Socket error: $err'),
        onDone: () => _handleDisconnect('Dongle disconnected'),
      );

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
    } catch (e) {
      _handleDisconnect('Failed to connect: $e');
      return false;
    }
  }

  Future<bool> _runInitSequence() async {
    try {
      // 1. Reset
      await sendCommand(Elm327Commands.reset, timeoutMs: 2000);
      // 2. Echo off
      await sendCommand(Elm327Commands.echoOff);
      // 3. Headers off
      await sendCommand(Elm327Commands.headersOff);
      // 4. Spaces off
      await sendCommand(Elm327Commands.spacesOff);
      // 5. Auto Protocol
      await sendCommand(Elm327Commands.autoProtocol);

      // Read protocol
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
    if (_socket == null) return null;

    _pendingCommand = Completer<String>();
    final formatted = '${cmd.trim()}\r';
    _socket!.add(utf8.encode(formatted));

    try {
      return await _pendingCommand!.future.timeout(Duration(milliseconds: timeoutMs));
    } on TimeoutException {
      return null;
    }
  }

  void disconnect() {
    _handleDisconnect(null);
  }

  void _handleDisconnect(String? reason) {
    _socket?.destroy();
    _socket = null;
    _status = ObdConnectionStatus.disconnected;
    _errorMessage = reason;
    notifyListeners();
  }

  @override
  void dispose() {
    _parserSubscription?.cancel();
    _parser.dispose();
    _socket?.destroy();
    super.dispose();
  }
}
