import 'package:get/get.dart';

class SplashScreenController extends GetxController {
  //TODO: Implement SplashScreenController

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    print('SplashController initialized');
    _navigateToLogin();
  }

  void _navigateToLogin() async {
    print('Waiting for 3 seconds before navigation');
    await Future.delayed(Duration(seconds: 3)); // Tunggu 3 detik
    print('Attempting to navigate to /login-page');
    Get.offAllNamed('/login-page');
    print('Navigation command executed');
  }



  void increment() => count.value++;
}
