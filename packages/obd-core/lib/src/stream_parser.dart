import 'dart:async';

/// Processes raw streaming byte chunks from ELM327 serial or socket connections
/// and emits sanitized, complete responses bounded by the '>' prompt character.
class Elm327StreamParser {
  final StringBuffer _buffer = StringBuffer();
  final StreamController<String> _controller = StreamController<String>.broadcast();

  Stream<String> get stream => _controller.stream;

  /// Feed incoming raw string chunks
  void addData(String chunk) {
    _buffer.write(chunk);
    _flushLines();
  }

  void _flushLines() {
    final content = _buffer.toString();
    if (content.contains('>')) {
      final parts = content.split('>');
      // All items except the last are completed responses
      for (int i = 0; i < parts.length - 1; i++) {
        final clean = _sanitize(parts[i]);
        if (clean.isNotEmpty) {
          _controller.add(clean);
        }
      }
      _buffer.clear();
      _buffer.write(parts.last);
    }
  }

  /// Cleans response string: removes echoes, BUS INIT, extra line endings
  static String _sanitize(String raw) {
    return raw
        .replaceAll('\r', ' ')
        .replaceAll('\n', ' ')
        .replaceAll('BUS INIT: ...', '')
        .replaceAll('SEARCHING...', '')
        .replaceAll('STOPPED', '')
        .trim();
  }

  /// Determines whether a response represents an error or no data
  static bool isErrorResponse(String response) {
    final upper = response.toUpperCase();
    return upper.contains('NO DATA') ||
        upper.contains('UNABLE TO CONNECT') ||
        upper.contains('CAN ERROR') ||
        upper.contains('BUS ERROR') ||
        upper.contains('FB ERROR') ||
        upper == '?';
  }

  void dispose() {
    _controller.close();
  }
}
