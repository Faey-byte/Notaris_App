import 'dart:async';
import 'dart:convert';
import 'package:notaris_app/config/ws_url.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

class WebSocketService {
  static const String _wsUrl = WsConfig.baseUrl;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final _notifController = StreamController<WsNotification>.broadcast();
  Stream<WsNotification> get notifications => _notifController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void connect(String userId) {
    print("🔌 [WebSocketService] Mencoba connect ke: $_wsUrl?userId=$userId");
    try {
      // Kirim userId agar server tahu ini notif untuk siapa
      _channel = WebSocketChannel.connect(
        Uri.parse('$_wsUrl?userId=$userId'),
      );
      _isConnected = true;
      print("✅ [WebSocketService] Channel dibuat, menunggu stream...");

      _subscription = _channel!.stream.listen(
        (data) {
          print("📩 [WebSocketService] Data diterima: $data");
          try {
            final json = jsonDecode(data);
            final notif = WsNotification.fromJson(json);
            _notifController.add(notif);
            print("🔔 [WebSocketService] Notifikasi diteruskan ke controller");
          } catch (_) {
            print("⚠️ [WebSocketService] Data bukan JSON valid, diabaikan: $data");
          }
        },
        onError: (error) {
          _isConnected = false;
          print("❌ [WebSocketService] Error: $error");
        },
        onDone: () {
          _isConnected = false;
          print("⚠️ [WebSocketService] Connection closed (onDone)");
        },
      );
    } catch (e) {
      _isConnected = false;
      print("❌ [WebSocketService] Exception saat connect: $e");
    }
  }

  void disconnect() {
    print("🛑 [WebSocketService] Disconnect dipanggil");
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
  final String id;        // ✅ ditambahkan — dibutuhkan untuk markAsRead per-item
  final String type;      // misal: 'foto_ppat_baru'
  final String message;   // 'Orang A menambahkan foto baru'
  final String? ppatId;   // id ppat yang ditambah fotonya
  final DateTime timestamp;
  bool isRead;            // ✅ ditambahkan — status sudah/belum dibaca

  WsNotification({
    String? id,
    required this.type,
    required this.message,
    this.ppatId,
    required this.timestamp,
    this.isRead = false,
  }) : id = id ?? '${timestamp.millisecondsSinceEpoch}_${message.hashCode}';
  // ✅ kalau backend belum kirim field 'id', tetap auto-generate id unik

  factory WsNotification.fromJson(Map<String, dynamic> json) {
    return WsNotification(
      id: json['id']?.toString(),
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      ppatId: json['ppat_id'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] == true, // sesuaikan kalau backend pakai nama field lain
    );
  }
}