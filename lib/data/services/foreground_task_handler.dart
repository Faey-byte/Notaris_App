import 'dart:async';
import 'dart:convert';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notaris_app/config/ws_url.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WsForegroundTaskHandler extends TaskHandler {
  WebSocketChannel? _channel;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  bool _isConnected = false;

 static const String _wsUrl = WsConfig.baseUrl;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print("🚀 [ForegroundTask] onStart dipanggil");
    await _initLocalNotification();
    await _connectWebSocket();
  }

  Future<void> _initLocalNotification() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotif.initialize(settings: initSettings);
    print("✅ [ForegroundTask] Local notification initialized");
  }

  Future<void> _connectWebSocket() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      print("🔍 [ForegroundTask] user_id dari SharedPreferences: $userId");

      if (userId == null) {
        print("❌ [ForegroundTask] user_id NULL — tidak bisa connect WS");
        _isConnected = false;
        FlutterForegroundTask.updateService(
          notificationTitle: 'Notaris App',
          notificationText: '⚠️ Belum login — menunggu login...',
        );
        return;
      }

      print("🔌 [ForegroundTask] Mencoba connect ke: $_wsUrl?userId=$userId");

      _channel = WebSocketChannel.connect(
        Uri.parse('$_wsUrl?userId=$userId'),
      );

      await _channel!.ready.then((_) {
        _isConnected = true;
        print("✅ [ForegroundTask] WebSocket TERHUBUNG");
        FlutterForegroundTask.updateService(
          notificationTitle: 'Notaris App',
          notificationText: '🟢 Terhubung — menunggu notifikasi baru',
        );
      }).catchError((error) {
        _isConnected = false;
        print("❌ [ForegroundTask] Gagal connect WebSocket: $error");
        FlutterForegroundTask.updateService(
          notificationTitle: 'Notaris App',
          notificationText: '🔴 Gagal terhubung — mencoba lagi...',
        );
        _reconnect();
        return;
      });

      _channel!.stream.listen(
        (data) async {
          print("📩 [ForegroundTask] Data diterima dari WS: $data");
          try {
            final json = jsonDecode(data);
            final message = json['message'] ?? 'Ada pembaruan baru';
            await _showNotification(message);
            print("🔔 [ForegroundTask] Notifikasi ditampilkan: $message");
          } catch (e) {
            print("⚠️ [ForegroundTask] Data bukan JSON valid: $e");
          }
        },
        onError: (error) {
          _isConnected = false;
          print("❌ [ForegroundTask] WS Error: $error");
          FlutterForegroundTask.updateService(
            notificationTitle: 'Notaris App',
            notificationText: '🔴 Koneksi terputus, mencoba lagi...',
          );
          _reconnect();
        },
        onDone: () {
          _isConnected = false;
          print("⚠️ [ForegroundTask] WS Connection Closed (onDone)");
          FlutterForegroundTask.updateService(
            notificationTitle: 'Notaris App',
            notificationText: '🔴 Terputus — menyambung ulang...',
          );
          _reconnect();
        },
      );
    } catch (e) {
      _isConnected = false;
      print("❌ [ForegroundTask] Exception saat connect: $e");
      _reconnect();
    }
  }

  void _reconnect() {
    print("🔄 [ForegroundTask] Reconnect dalam 5 detik...");
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isConnected) {
        _connectWebSocket();
      }
    });
  }

  Future<void> _showNotification(String message) async {
    const androidDetails = AndroidNotificationDetails(
      'ws_channel',
      'Notifikasi PPAT',
      channelDescription: 'Notifikasi upload berkas PPAT terbaru',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notifDetails = NotificationDetails(android: androidDetails);

    await _localNotif.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🔔 Notifikasi Baru',
      body: message,
      notificationDetails: notifDetails,
    );
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    print("🔁 [ForegroundTask] onRepeatEvent — isConnected: $_isConnected");
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    print("🛑 [ForegroundTask] onDestroy dipanggil — closing WebSocket");
    _channel?.sink.close();
    _isConnected = false;
  }
}

@pragma('vm:entry-point')
void startForegroundTaskCallback() {
  FlutterForegroundTask.setTaskHandler(WsForegroundTaskHandler());
}