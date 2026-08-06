// import 'package:get/get.dart';
// import 'package:notaris_app/Model/Notifikasi_Model.dart'; // Sesuaikan path modelmu

// class NotifikasiController extends GetxController {
//   var isLoading = false.obs;
//   var notifikasiList = <NotifikasiModel>[].obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchNotifikasi();
//   }

//   Future<void> fetchNotifikasi() async {
//     isLoading.value = true;
//     try {
//       await Future.delayed(const Duration(seconds: 1));

//       final dummyData = [
//         {
//           "id": 1,
//           "title": "Status Berkas Diperbarui",
//           "message":
//               "Berkas PPAT atas nama Rustafff telah diubah statusnya menjadi REVISI.",
//           "type": "berkas",
//           "created_at": DateTime.now()
//               .subtract(const Duration(minutes: 5))
//               .toString(),
//           "is_read": 0,
//         },
//         {
//           "id": 2,
//           "title": "Pembayaran Terverifikasi",
//           "message":
//               "Status pajak untuk AJB No. 98 berhasil diverifikasi oleh sistem.",
//           "type": "pembayaran",
//           "created_at": DateTime.now()
//               .subtract(const Duration(hours: 2))
//               .toString(),
//           "is_read": 1,
//         },
//         {
//           "id": 3,
//           "title": "Pengingat Berkas",
//           "message": "Laporan bulanan PPAT bulan Juni 2026 siap diunduh.",
//           "type": "sistem",
//           "created_at": DateTime.now()
//               .subtract(const Duration(days: 1))
//               .toString(),
//           "is_read": 1,
//         },
//       ];

//       notifikasiList.value = dummyData
//           .map((json) => NotifikasiModel.fromJson(json))
//           .toList();
//     } catch (e) {
//       print("Error fetching notifications: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void markAsRead(int id) {
//     final index = notifikasiList.indexWhere((n) => n.id == id);
//     if (index != -1) {
//       notifikasiList[index].isRead = true;
//       notifikasiList.refresh();
//     }
//   }

//   void markAllAsRead() {
//     for (var notif in notifikasiList) {
//       notif.isRead = true;
//     }
//     notifikasiList.refresh();
//   }
// }
