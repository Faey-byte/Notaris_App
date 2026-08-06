// // import 'dart:async';
// // import 'package:get/get.dart';
// // import '../data/services/websocket_service.dart';

// // class NotificationController extends GetxController {
// //   final WebSocketService _wsService = WebSocketService();

// //   final notifications = <WsNotification>[].obs;
// //   final unreadCount = 0.obs;
// //   final isConnected = false.obs;

// //   StreamSubscription? _notifSub;

// //   // Panggil ini saat user sudah login
// //   void startListening(String userId) {
// //     _notifSub?.cancel(); // cegah listener dobel kalau dipanggil ulang

// //     _wsService.connect(userId);
// //     isConnected.value = true;

// //     _notifSub = _wsService.notifications.listen((notif) {
// //       notifications.insert(0, notif); // terbaru di atas
// //       unreadCount.value++;

// //       Get.snackbar(
// //         '🔔 Notifikasi Baru',
// //         notif.message,
// //         duration: const Duration(seconds: 3),
// //         snackPosition: SnackPosition.TOP,
// //         onTap: (_) {
// //           if (notif.ppatId != null) {
// //             Get.toNamed('/ppat', arguments: notif.ppatId);
// //           }
// //           markAsRead(notif.id);
// //         },
// //       );
// //     });
// //   }

// //   // ✅ Tandai satu notif sebagai sudah dibaca
// //   void markAsRead(String notificationId) {
// //     final index = notifications.indexWhere((n) => n.id == notificationId);
// //     if (index != -1 && !notifications[index].isRead) {
// //       notifications[index].isRead = true;
// //       notifications.refresh(); // trigger update UI
// //       if (unreadCount.value > 0) unreadCount.value--;
// //     }
// //   }

// //   // ✅ Tandai semua notif sebagai sudah dibaca
// //   void markAllRead() {
// //     for (var n in notifications) {
// //       n.isRead = true;
// //     }
// //     notifications.refresh();
// //     unreadCount.value = 0;
// //   }

// //   void stopListening() {
// //     _notifSub?.cancel();
// //     _wsService.disconnect();
// //     isConnected.value = false;
// //   }

// //   @override
// //   void onClose() {
// //     _notifSub?.cancel();
// //     _wsService.dispose();
// //     super.onClose();
// //   }
// // }
// // Controller/Notification_Controller.dart

// import 'dart:async';
// import 'dart:math';
// import 'package:get/get.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import '../data/services/websocket_service.dart';

// class NotificationController extends GetxController {
//   final WebSocketService _wsService = WebSocketService();

//   // ✅ SAKLAR DUMMY MODE — set ke false lagi kalau backend sudah siap
//   static const bool useDummyMode = true;

//   final notifications = <WsNotification>[].obs;
//   final unreadCount = 0.obs;
//   final isConnected = false.obs;

//   StreamSubscription? _notifSub;
//   Timer? _dummyTimer;

//   final FlutterLocalNotificationsPlugin _localNotif =
//       FlutterLocalNotificationsPlugin();
//   bool _localNotifInitialized = false;

//   final List<Map<String, String?>> _dummyTemplates = [
//     {
//       'message': 'Andi menambahkan foto baru pada berkas PPAT #A-102',
//       'ppatId': 'A-102',
//     },
//     {'message': 'Berkas Notaris #N-045 berhasil diverifikasi', 'ppatId': null},
//     {
//       'message': 'Siti mengunggah dokumen tambahan untuk PPAT #A-098',
//       'ppatId': 'A-098',
//     },
//     {'message': 'Proses berkas #N-051 telah selesai', 'ppatId': null},
//     {
//       'message': 'Ada pembaruan status pada berkas PPAT #A-110',
//       'ppatId': 'A-110',
//     },
//   ];

//   // Panggil ini saat user sudah login
//   void startListening(String userId) {
//     print(
//       "🚀 [NotificationController] startListening dipanggil, userId=$userId, useDummyMode=$useDummyMode",
//     );

//     if (useDummyMode) {
//       _startDummyMode();
//       return;
//     }

//     // ================== KODE ASLI (WS BENERAN) — TIDAK DIHAPUS ==================
//     _notifSub?.cancel();

//     _wsService.connect(userId);
//     isConnected.value = true;

//     _notifSub = _wsService.notifications.listen((notif) {
//       notifications.insert(0, notif);
//       unreadCount.value++;

//       Get.snackbar(
//         '🔔 Notifikasi Baru',
//         notif.message,
//         duration: const Duration(seconds: 1),
//         snackPosition: SnackPosition.TOP,
//         onTap: (_) {
//           if (notif.ppatId != null) {
//             Get.toNamed('/ppat', arguments: notif.ppatId);
//           }
//           markAsRead(notif.id);
//         },
//       );
//     });
//     // ================================================================================
//   }

//   // ✅ Inisialisasi plugin — TANPA request permission manual di sini
//   // (izin notifikasi sudah diminta di LoginController._startForegroundService())
//   Future<void> _initLocalNotificationIfNeeded() async {
//     if (_localNotifInitialized) return;

//     try {
//       const androidSettings = AndroidInitializationSettings(
//         '@mipmap/ic_launcher',
//       );
//       const initSettings = InitializationSettings(android: androidSettings);
//       final initResult = await _localNotif.initialize(settings: initSettings);
//       print("✅ [NotificationController] Local notif initialize: $initResult");
//       _localNotifInitialized = true;
//     } catch (e) {
//       print("❌ [NotificationController] Gagal inisialisasi local notif: $e");
//     }
//   }

//   Future<void> _showLocalNotification(WsNotification notif) async {
//     try {
//       await _initLocalNotificationIfNeeded();

//       const androidDetails = AndroidNotificationDetails(
//         'ws_channel',
//         'Notifikasi PPAT',
//         channelDescription: 'Notifikasi upload berkas PPAT terbaru',
//         importance: Importance.high,
//         priority: Priority.high,
//       );
//       const notifDetails = NotificationDetails(android: androidDetails);

//       await _localNotif.show(
//         id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
//         title: '🔔 Notifikasi Baru',
//         body: notif.message,
//         notificationDetails: notifDetails,
//       );
//       print(
//         "🔔 [NotificationController] Notif lokal berhasil ditampilkan: ${notif.message}",
//       );
//     } catch (e) {
//       print("❌ [NotificationController] Gagal menampilkan notif lokal: $e");
//     }
//   }

//   void _startDummyMode() {
//     print("🎬 [NotificationController] _startDummyMode dijalankan");
//     _dummyTimer?.cancel();

//     notifications.clear();
//     unreadCount.value = 0;
//     isConnected.value = true;

//     _initLocalNotificationIfNeeded();

//     final now = DateTime.now();
//     for (var i = 0; i < 3; i++) {
//       final template = _dummyTemplates[i % _dummyTemplates.length];
//       notifications.add(
//         WsNotification(
//           type: 'dummy',
//           message: template['message']!,
//           ppatId: template['ppatId'],
//           timestamp: now.subtract(Duration(minutes: (i + 1) * 12)),
//         ),
//       );
//     }
//     unreadCount.value = notifications.length;

//     final rand = Random();
//     _dummyTimer = Timer.periodic(const Duration(seconds: 25), (_) async {
//       print("⏰ [NotificationController] Timer tick — kirim dummy notif baru");
//       final template = _dummyTemplates[rand.nextInt(_dummyTemplates.length)];
//       final notif = WsNotification(
//         type: 'dummy',
//         message: template['message']!,
//         ppatId: template['ppatId'],
//         timestamp: DateTime.now(),
//       );

//       notifications.insert(0, notif);
//       unreadCount.value++;

//       await _showLocalNotification(notif);

//       Get.snackbar(
//         '🔔 Notifikasi Baru',
//         notif.message,
//         duration: const Duration(seconds: 3),
//         snackPosition: SnackPosition.TOP,
//         onTap: (_) => markAsRead(notif.id),
//       );
//     });
//   }

//   void markAsRead(String notificationId) {
//     final index = notifications.indexWhere((n) => n.id == notificationId);
//     if (index != -1 && !notifications[index].isRead) {
//       notifications[index].isRead = true;
//       notifications.refresh();
//       if (unreadCount.value > 0) unreadCount.value--;
//     }
//   }

//   void markAllRead() {
//     for (var n in notifications) {
//       n.isRead = true;
//     }
//     notifications.refresh();
//     unreadCount.value = 0;
//   }

//   void stopListening() {
//     _notifSub?.cancel();
//     _dummyTimer?.cancel();
//     if (!useDummyMode) {
//       _wsService.disconnect();
//     }
//     isConnected.value = false;
//   }

//   @override
//   void onClose() {
//     _notifSub?.cancel();
//     _dummyTimer?.cancel();
//     if (!useDummyMode) {
//       _wsService.dispose();
//     }
//     super.onClose();
//   }
// }
