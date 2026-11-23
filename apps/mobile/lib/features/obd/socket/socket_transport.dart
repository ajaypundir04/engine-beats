import 'socket_transport_stub.dart'
    if (dart.library.io) 'socket_transport_io.dart';

abstract class SocketTransport {
  Future<bool> connect(
    String host,
    int port,
    void Function(String data) onData,
    void Function(String error) onError,
  );

  void send(String data);
  void destroy();

  factory SocketTransport() => createSocketTransport();
}
