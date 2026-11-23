import 'dart:convert';
import 'dart:io';
import 'socket_transport.dart';

SocketTransport createSocketTransport() => _IoSocketTransport();

class _IoSocketTransport implements SocketTransport {
  Socket? _socket;

  @override
  Future<bool> connect(
    String host,
    int port,
    void Function(String data) onData,
    void Function(String error) onError,
  ) async {
    try {
      _socket = await Socket.connect(host, port, timeout: const Duration(seconds: 4));
      _socket!.listen(
        (data) => onData(utf8.decode(data, allowMalformed: true)),
        onError: (err) => onError('Socket error: $err'),
        onDone: () => onError('Dongle disconnected'),
      );
      return true;
    } catch (e) {
      onError('Failed to connect: $e');
      return false;
    }
  }

  @override
  void send(String data) {
    _socket?.add(utf8.encode(data));
  }

  @override
  void destroy() {
    _socket?.destroy();
    _socket = null;
  }
}
