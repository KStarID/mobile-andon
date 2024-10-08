import 'package:get/get.dart';
import '../../services/service.dart';
import '../../services/user_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = Get.find<UserService>();
  
  final username = 'kstarid'.obs;
  final password = 'test'.obs;
  final role = 'admin'.obs;
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login() async {
    if (username.value.isEmpty || password.value.isEmpty) {
      Get.snackbar('Error', 'Silakan masukkan username dan password');
      return;
    }

    isLoading.value = true;
    try {
      await _authService.login(username.value, password.value, role.value);
      
      final userId = _authService.getUserId();
      if (userId != null) {
        _userService.setUserId(userId);
      }
      
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
