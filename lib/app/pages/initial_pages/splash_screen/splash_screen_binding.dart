import 'package:get/get.dart';
import 'package:saraka_foto_box/app/pages/initial_pages/splash_screen/splash_screen_controller.dart';

class SplashScreenBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<SplashScreenController>(() => SplashScreenController());
  }
}