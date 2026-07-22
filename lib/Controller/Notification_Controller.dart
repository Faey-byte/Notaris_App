import 'dart:async';
import 'package:get/get.dart';
import '../data/services/websocket_service.dart';

class NotificationController extends GetxController {
  final WebSocketService _wsService = WebSocketService();

  final notifications = <WsNotification>[].obs;
  final unreadCount = 0.obs;
  final isConnected = false.obs;

  StreamSubscription? _notifSub;

  // Panggil ini saat user sudah login
  void startListening(String userId) {
    _notifSub?.cancel(); // cegah listener dobel kalau dipanggil ulang

    _wsService.connect(userId);
    isConnected.value = true;

    _notifSub = _wsService.notifications.listen((notif) {
      notifications.insert(0, notif); // terbaru di atas
      unreadCount.value++;

      Get.snackbar(
        '🔔 Notifikasi Baru',
        notif.message,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        onTap: (_) {
          if (notif.ppatId != null) {
            Get.toNamed('/ppat', arguments: notif.ppatId);
          }
          markAsRead(notif.id);
        },
      );
    });
  }

  // ✅ Tandai satu notif sebagai sudah dibaca
  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !notifications[index].isRead) {
      notifications[index].isRead = true;
      notifications.refresh(); // trigger update UI
      if (unreadCount.value > 0) unreadCount.value--;
    }
  }

  // ✅ Tandai semua notif sebagai sudah dibaca
  void markAllRead() {
    for (var n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    unreadCount.value = 0;
  }

  void stopListening() {
    _notifSub?.cancel();
    _wsService.disconnect();
    isConnected.value = false;
  }

  @override
  void onClose() {
    _notifSub?.cancel();
    _wsService.dispose();
    super.onClose();
  }
}