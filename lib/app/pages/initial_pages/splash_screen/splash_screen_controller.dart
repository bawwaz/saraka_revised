import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saraka_revised/app/route/app_pages.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration(seconds: 3), () {
      checkLoginStatus();
    });
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedToken = prefs.getString('token');
    String? username = prefs.getString('username');

    if (savedToken != null && savedToken.isNotEmpty) {
      if (username != null) {
        print("Navigating to FormPageView. Username: $username");
      }
      Get.offAllNamed(Routes.FORM,
          arguments: {'username': username}); // Navigate to FormPageView
    } else {
      Get.offAllNamed(Routes.LOGIN); // Navigate to Login page
    }
  }
}
