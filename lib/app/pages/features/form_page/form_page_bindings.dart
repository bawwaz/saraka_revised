import 'package:get/get.dart';
import 'package:saraka_foto_box/app/pages/features/form_page/form_page_controller.dart';

class FormPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FormPageController>(() => FormPageController());
  }
}
