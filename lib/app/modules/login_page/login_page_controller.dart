
import 'package:get/get.dart';
import '../../services/user_service.dart';

class LoginController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  
  final username = ''.obs;
  final password = ''.obs;
  final role = 'admin'.obs;
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login() async {
    if (username.value.isEmpty || password.value.isEmpty) {
      Get.snackbar('Error', 'Please enter username and password');
      return;
    }

    isLoading.value = true;
    try {
      // Simpan username
      _userService.setUsername(username.value);
      
      // Jika login berhasil, arahkan ke halaman utama
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
