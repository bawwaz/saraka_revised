import 'package:get/get.dart';
import 'package:saraka_foto_box/app/pages/features/form_page_detail/form_page_detail_controller.dart';

class FormPageDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FormPageDetailController>(() => FormPageDetailController());
  }
}
