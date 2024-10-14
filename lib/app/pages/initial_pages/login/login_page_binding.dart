import 'package:get/get.dart';
import 'package:saraka_revised/app/pages/initial_pages/login/login_page_controller.dart';

class LoginPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginPageController>(() => LoginPageController());
  }
}