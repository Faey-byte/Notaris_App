import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

class WebSocketService {
  static const String _wsUrl = 'wss://echo.websocket.org'; // ganti dengan WS server kamu
  
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final _notifController = StreamController<WsNotification>.broadcast();
  Stream<WsNotification> get notifications => _notifController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void connect(String userId) {
    try {
      // Kirim userId agar server tahu ini notif untuk siapa
      _channel = WebSocketChannel.connect(
        Uri.parse('$_wsUrl?userId=$userId'),
      );
      _isConnected = true;

      _subscription = _channel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data);
            final notif = WsNotification.fromJson(json);
            _notifController.add(notif);
          } catch (_) {
            // bukan JSON, abaikan
          }
        },
        onError: (_) => _isConnected = false,
        onDone: ()  => _isConnected = false,
      );
    } catch (e) {
      _isConnected = false;
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close(ws_status.normalClosure);
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    _notifController.close();
  }
}

// Model notif dari server
class WsNotification {
  final String type;      // misal: 'foto_ppat_baru'
  final String message;   // 'Orang A menambahkan foto baru'
  final String? ppatId;   // id ppat yang ditambah fotonya
  final DateTime timestamp;

  WsNotification({
    required this.type,
    required this.message,
    this.ppatId,
    required this.timestamp,
  });

  factory WsNotification.fromJson(Map<String, dynamic> json) {
    return WsNotification(
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      ppatId: json['ppat_id'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}