import 'socket_transport.dart';

SocketTransport createSocketTransport() => _StubSocketTransport();

class _StubSocketTransport implements SocketTransport {
  @override
  Future<bool> connect(
    String host,
    int port,
    void Function(String data) onData,
    void Function(String error) onError,
  ) async {
    // Browsers cannot open raw TCP sockets
    onError('Raw TCP sockets are not supported in web browsers.');
    return false;
  }

  @override
  void send(String data) {}

  @override
  void destroy() {}
}
