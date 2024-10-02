import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void login() {
    // Implementasi logika login di sini
    print('Username: ${usernameController.text}');
    print('Password: ${passwordController.text}');
    // Contoh: navigasi ke halaman utama setelah login berhasil
    Get.offAllNamed('/home');
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
