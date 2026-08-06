import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/auth_controller.dart';
import 'package:notaris_app/Pages/Home_Page.dart';
import 'Routes/routes.dart';
import 'Routes/pages.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:notaris_app/data/db_helper.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart'; 


// void _initForegroundTask() {
//   FlutterForegroundTask.init(
//     androidNotificationOptions: AndroidNotificationOptions(
//       channelId: 'ws_foreground_channel',
//       channelName: 'Notaris App Background Service',
//       channelDescription: 'Menjaga koneksi notifikasi tetap aktif di background',
//       channelImportance: NotificationChannelImportance.LOW,
//       priority: NotificationPriority.LOW,
//     ),
//     iosNotificationOptions: const IOSNotificationOptions(
//       showNotification: false,
//       playSound: false,
//     ),
//     foregroundTaskOptions: ForegroundTaskOptions(
//       eventAction: ForegroundTaskEventAction.repeat(300000), // cek tiap 5 menit (fallback)
//       autoRunOnBoot: true,
//       allowWakeLock: true,
//       allowWifiLock: true,
//     ),
//   );
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // _initForegroundTask();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Info: Gagal memuat file .env: $e");
  }

  print("reload info data notaris");
  await DbHelper().cekSeluruhDataNotaris();

  Get.put(AuthController());
  // Get.put<NotificationController>(NotificationController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Notaris & PPAT',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splashpage,
      getPages: AppPages.pages,
    );
  }
}