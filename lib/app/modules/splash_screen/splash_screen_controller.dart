import 'package:get/get.dart';

class SplashScreenController extends GetxController {

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    _navigateToLogin();
  }

  void _navigateToLogin() async {
    await Future.delayed(Duration(seconds: 3)); 
    Get.offAllNamed('/login-page');
  }



  void increment() => count.value++;
}
