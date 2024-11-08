import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../services/service.dart';
import '../../services/user_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = Get.find<UserService>();
  
  final username = ''.obs;
  final password = ''.obs;
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;
  final rememberMe = false.obs;
  final savedUsers = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSavedCredentials();
    loadSavedUsers();
  }

  // Fungsi untuk load credentials yang tersimpan
  Future<void> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    username.value = prefs.getString('saved_username') ?? '';
    password.value = prefs.getString('saved_password') ?? '';
    rememberMe.value = prefs.getBool('remember_me') ?? false;
  }

  // Fungsi untuk menyimpan credentials
  Future<void> saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe.value) {
      await prefs.setString('saved_username', username.value);
      await prefs.setString('saved_password', password.value);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_username');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  Future<void> loadSavedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList('saved_users') ?? [];
    savedUsers.value = usersJson
        .map((user) => Map<String, String>.from(json.decode(user)))
        .toList();
  }

  Future<void> saveUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe.value) {
      final newUser = {
        'username': username.value,
        'password': password.value,
      };
      
      // Cek apakah user sudah ada
      final existingIndex = savedUsers
          .indexWhere((user) => user['username'] == username.value);
      
      if (existingIndex == -1) {
        savedUsers.add(newUser);
      } else {
        savedUsers[existingIndex] = newUser;
      }

      final usersJson = savedUsers
          .map((user) => json.encode(user))
          .toList();
      await prefs.setStringList('saved_users', usersJson);
    }
  }

  Future<void> removeSavedUser(int index) async {
    final prefs = await SharedPreferences.getInstance();
    savedUsers.removeAt(index);
    
    final usersJson = savedUsers
        .map((user) => json.encode(user))
        .toList();
    await prefs.setStringList('saved_users', usersJson);
    
    Get.snackbar(
      'Success',
      'User removed from saved accounts',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  Future<void> login() async {
    // Validasi input kosong atau hanya whitespace
    if (username.value.trim().isEmpty || password.value.trim().isEmpty) {
      Get.snackbar(
        'Error', 
        'Please fill username and password',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        icon: Icon(Icons.error, color: Colors.white),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
        duration: Duration(seconds: 3),
      );
      return;
    }

    // Validasi panjang minimum
    if (username.value.trim().length < 3) {
      Get.snackbar(
        'Error', 
        'Username must be at least 3 characters',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        icon: Icon(Icons.error, color: Colors.white),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
        duration: Duration(seconds: 3),
      );
      return;
    }

    if (password.value.trim().length < 6) {
      Get.snackbar(
        'Error', 
        'Password must be at least 6 characters',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        icon: Icon(Icons.error, color: Colors.white),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
        duration: Duration(seconds: 3),
      );
      return;
    }

    isLoading.value = true;
    try {
      await _authService.login(username.value.trim(), password.value.trim());
      await saveUser(); 
      
      ApiService().getCurrentUser();

      final userId = _authService.getUserId();
      if (userId != null) {
        _userService.setUserId(userId);
      }

      _userService.setUsername(username.value.trim());

      Get.snackbar(
        'Login', 
        'Login Successfully',
        backgroundColor: Colors.green[400],
        colorText: Colors.white,
        icon: Icon(Icons.check_circle, color: Colors.white),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
        duration: Duration(seconds: 3),
        isDismissible: true,
        overlayBlur: 0,
        overlayColor: Colors.transparent,
      );
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar(
        'Error', 
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        icon: Icon(Icons.error_outline, color: Colors.white),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
        duration: Duration(seconds: 3),
        isDismissible: true,
        overlayBlur: 0,
        overlayColor: Colors.transparent,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi terpisah untuk login dari saved user
  Future<void> loginFromSavedUser(Map<String, String> user) async {
    isLoading.value = true;
    try {
      // Login menggunakan credentials dari saved user
      await _authService.login(user['username'] ?? '', user['password'] ?? '');
      
      ApiService().getCurrentUser();
      final userId = _authService.getUserId();
      if (userId != null) {
        _userService.setUserId(userId);
      }
      _userService.setUsername(user['username'] ?? '');

      Get.snackbar(
        'Login', 
        'Login Successfully',
        backgroundColor: Colors.green[400],
        colorText: Colors.white,
        icon: Icon(Icons.check_circle, color: Colors.white),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
        duration: Duration(seconds: 3),
        isDismissible: true,
        overlayBlur: 0,
        overlayColor: Colors.transparent,
      );
      
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar(
        'Error', 
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        icon: Icon(Icons.error_outline, color: Colors.white),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
        duration: Duration(seconds: 3),
        isDismissible: true,
        overlayBlur: 0,
        overlayColor: Colors.transparent,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update fungsi selectSavedUser untuk hanya mengisi form
  void selectSavedUser(Map<String, String> user) {
    username.value = user['username'] ?? '';
    password.value = user['password'] ?? '';
    rememberMe.value = true;
  }
}
