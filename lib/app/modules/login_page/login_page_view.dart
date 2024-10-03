import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_page_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => controller.isLoading.value
        ? Center(child: CircularProgressIndicator())
        : Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFD6FFEA),
                  Color(0xFFADFFD5),
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logos/oppo-mascott.png', // Ganti dengan nama file logo Anda
                        width: 800,
                        height: 600,
                      ),
                      const SizedBox(height: 48),
                      TextField(
                        onChanged: (value) => controller.username.value = value,
                        decoration: InputDecoration(
                          hintText: 'Username',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Obx(() => TextField(
                        onChanged: (value) => controller.password.value = value,
                        obscureText: controller.isPasswordHidden.value,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordHidden.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Color(0xFF00BD5B),
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                      )),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: controller.login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF006B33),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ),
    );
  }
}
