import 'package:get/get.dart';
import 'package:saraka_revised/app/pages/features/form_page/form_page_bindings.dart';
import 'package:saraka_revised/app/pages/features/form_page/form_page_view.dart';
import 'package:saraka_revised/app/pages/features/form_page_detail/form_page_detail_binding.dart';
import 'package:saraka_revised/app/pages/features/form_page_detail/form_page_detail_view.dart';
import 'package:saraka_revised/app/pages/initial_pages/login/login_page_binding.dart';
import 'package:saraka_revised/app/pages/initial_pages/login/login_page_view.dart';

part 'routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginPageView(),
      binding: LoginPageBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.FORM,
      page: () => FormPageView(),
      binding: FormPageBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: Routes.FORMDETAIL,
      page: () => FormPageDetailView(),
      binding: FormPageDetailBinding(),
      transition: Transition.noTransition,
    )
  ];
}
