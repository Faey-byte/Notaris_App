import 'package:get/get.dart';
import '../data/services/websocket_service.dart';

class NotificationController extends GetxController {
  final WebSocketService _wsService = WebSocketService();

  final notifications = <WsNotification>[].obs;
  final unreadCount = 0.obs;
  final isConnected = false.obs;

  get isLoading => null;

  void startListening(String userId) {
    _wsService.connect(userId);
    isConnected.value = true;

    _wsService.notifications.listen((notif) {
      notifications.insert(0, notif);
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
          markAllRead();
        },
      );
    });
  }

  void markAllRead() => unreadCount.value = 0;

  void stopListening() {
    _wsService.disconnect();
    isConnected.value = false;
  }

  @override
  void onClose() {
    _wsService.dispose();
    super.onClose();
  }
}