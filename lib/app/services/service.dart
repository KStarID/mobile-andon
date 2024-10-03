import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class AuthService extends GetxService {
  final String baseUrl = 'http://10.0.2.2:3000/api/v1'; // Gunakan 10.0.2.2 untuk localhost pada emulator Android

  Future<Map<String, dynamic>> login(String username, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }
}
