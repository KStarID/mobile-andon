import 'package:get/get.dart';

import '../modules/asesment/asesment_binding.dart';
import '../modules/asesment/asesment_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/login_page/login_page_binding.dart';
import '../modules/login_page/login_page_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN_PAGE;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN_PAGE,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.ASESMENT,
      page: () => AsesmentView(),
      binding: AsesmentBinding(),
    ),
  ];
}
