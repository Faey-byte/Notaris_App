import 'package:get/get.dart';
import 'package:notaris_app/Controller/Notification_Controller.dart';
import '../Controller/Splash_screen_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
    Get.put(NotificationController());
  }
}