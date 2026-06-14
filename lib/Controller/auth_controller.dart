import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notaris_app/Controller/Notification_Controller.dart'; // ← tambah ini
import '../Routes/routes.dart';

class AuthController extends GetxController {

  Future<void> logout() async {
    // Putuskan WS saat logout
    Get.find<NotificationController>().stopListening(); // ← tambah ini

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("email");
    await prefs.remove("user_id"); // ← hapus userId juga

    Get.snackbar("Info", "Berhasil logout");
    Get.offAllNamed(AppRoutes.loginpage);
  }
}