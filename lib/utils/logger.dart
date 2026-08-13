import 'dart:developer' as developer;

class AppLogger {
  static void log(
    Object? message, {
    String name = 'NotarisApp',
    int level = 0,
  }) {
    developer.log(message?.toString() ?? '', name: name, level: level);
  }
}
