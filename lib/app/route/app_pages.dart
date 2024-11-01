import 'package:get/get.dart';
import 'package:saraka_foto_box/app/pages/features/form_page/form_page_bindings.dart';
import 'package:saraka_foto_box/app/pages/features/form_page/form_page_view.dart';
import 'package:saraka_foto_box/app/pages/features/form_page_detail/form_page_detail_binding.dart';
import 'package:saraka_foto_box/app/pages/features/form_page_detail/form_page_detail_view.dart';
import 'package:saraka_foto_box/app/pages/features/profile_page/profile_page_binding.dart';
import 'package:saraka_foto_box/app/pages/features/profile_page/profile_page_view.dart';
import 'package:saraka_foto_box/app/pages/initial_pages/login/login_page_binding.dart';
import 'package:saraka_foto_box/app/pages/initial_pages/login/login_page_view.dart';
import 'package:saraka_foto_box/app/pages/initial_pages/splash_screen/splash_screen_binding.dart';
import 'package:saraka_foto_box/app/pages/initial_pages/splash_screen/splash_screen_view.dart';

part 'routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASHSCREEN;

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
    ),
    GetPage(
      name: Routes.SPLASHSCREEN,
      page: () => SplashScreenView(),
      binding: SplashScreenBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
        name: Routes.PROFILE,
        page: () => ProfilePageView(),
        binding: ProfilePageBinding(),
        transition: Transition.noTransition)
  ];
}
