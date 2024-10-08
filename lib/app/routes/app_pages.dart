import 'package:get/get.dart';

import '../modules/add_ases/add_ases_binding.dart';
import '../modules/add_ases/add_ases_view.dart';
import '../modules/asesment/asesment_binding.dart';
import '../modules/asesment/asesment_view.dart';
import '../modules/detail_history/detail_history_binding.dart';
import '../modules/detail_history/detail_history_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/login_page/login_page_binding.dart';
import '../modules/login_page/login_page_view.dart';
import '../modules/qr_scan/qr_scan_binding.dart';
import '../modules/qr_scan/qr_scan_view.dart';
import '../modules/splash_screen/splash_screen_binding.dart';
import '../modules/splash_screen/splash_screen_view.dart';
import '../modules/update_ases/update_ases_binding.dart';
import '../modules/update_ases/update_ases_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH_SCREEN;

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
    GetPage(
      name: _Paths.ADD_ASES,
      page: () => const AddAsesView(),
      binding: AddAsesBinding(),
    ),
    GetPage(
      name: _Paths.QR_SCAN,
      page: () => QRScannerView(isFromAsesment: Get.arguments ?? false),
      binding: QrScanBinding(),
    ),
    GetPage(
      name: _Paths.DETAIL_HISTORY,
      page: () => DetailHistoryView(),
      binding: DetailHistoryBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH_SCREEN,
      page: () => const SplashView(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: _Paths.UPDATE_ASES,
      page: () => const UpdateAsesView(),
      binding: UpdateAsesBinding(),
    ),
  ];
}
