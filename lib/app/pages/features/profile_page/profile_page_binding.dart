import 'package:get/get.dart';
import 'package:saraka_revised/app/pages/features/profile_page/profile_page_controller.dart';

class ProfilePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfilePageController>(() => ProfilePageController());
  }
}