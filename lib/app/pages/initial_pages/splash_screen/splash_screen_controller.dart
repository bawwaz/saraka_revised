import 'package:get/get.dart';
import 'package:saraka_foto_box/app/route/app_pages.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration(seconds: 3), () {
      navigateToLogin();
    });
  }

  void navigateToLogin() {
    Get.offAllNamed(Routes.LOGIN); // Always navigate to login
  }
}
