import 'package:get/get.dart';

import '../modules/andon_history/andon_history_binding.dart';
import '../modules/andon_history/andon_history_view.dart';
import '../modules/andon_history_details/andon_history_details_binding.dart';
import '../modules/andon_history_details/andon_history_details_view.dart';
import '../modules/andon_home/andon_home_binding.dart';
import '../modules/andon_home/andon_home_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/login_page/login_page_binding.dart';
import '../modules/login_page/login_page_view.dart';
import '../modules/repairing/repairing_binding.dart';
import '../modules/repairing/repairing_view.dart';
import '../modules/reviewing/reviewing_binding.dart';
import '../modules/reviewing/reviewing_view.dart';
import '../modules/so_machine/add_ases/add_ases_binding.dart';
import '../modules/so_machine/add_ases/add_ases_view.dart';
import '../modules/so_machine/asesment/asesment_binding.dart';
import '../modules/so_machine/asesment/asesment_view.dart';
import '../modules/so_machine/detail_history/detail_history_binding.dart';
import '../modules/so_machine/detail_history/detail_history_view.dart';
import '../modules/so_machine/qr_scan/qr_scan_binding.dart';
import '../modules/so_machine/qr_scan/qr_scan_view.dart';
import '../modules/so_machine/update_ases/update_ases_binding.dart';
import '../modules/so_machine/update_ases/update_ases_view.dart';
import '../modules/splash_screen/splash_screen_binding.dart';
import '../modules/splash_screen/splash_screen_view.dart';

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
    GetPage(
      name: _Paths.ANDON_HOME,
      page: () => AndonHomeView(),
      binding: AndonHomeBinding(),
    ),
    GetPage(
      name: _Paths.REPAIRING,
      page: () => RepairingView(),
      binding: RepairingBinding(),
    ),
    GetPage(
      name: _Paths.REVIEWING,
      page: () => const ReviewingView(),
      binding: ReviewingBinding(),
    ),
    GetPage(
      name: _Paths.ANDON_HISTORY,
      page: () => const AndonHistoryView(),
      binding: AndonHistoryBinding(),
    ),
    GetPage(
      name: _Paths.ANDON_HISTORY_DETAILS,
      page: () => const AndonHistoryDetailsView(),
      binding: AndonHistoryDetailsBinding(),
    ),
  ];
}
