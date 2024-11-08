import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:oppoandon/app/modules/reviewing/reviewing_controller.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../data/models/andon_model.dart';
import '../data/models/assessment_model.dart';
import '../modules/andon_home/andon_home_controller.dart';

final String baseUrl = 'http://10.0.2.2:5000/api/v1'; // 10.0.2.2 untuk localhost pada emulator Android
// final String baseUrl = 'http://192.168.0.100:5000/api/v1';
// final String baseUrl = 'http://10.106.88.254:5000/api/v1';

final String baseUrl2 = 'http://10.0.2.2:8080/api/v1';
// final String baseUrl2 = 'http://192.168.0.100:8080/api/v1';
// final String baseUrl2 = 'http://10.106.88.254:8080/api/v1';

final websocketUrl = 'ws://10.0.2.2:5001/api/v1/ws';
// final websocketUrl = 'ws://192.168.0.100:5001/api/v1/ws';
// final websocketUrl = 'ws://10.106.88.254:5001/api/v1/ws';

class AuthService extends GetxService {

  String? _accessToken;
  final isLoading = false.obs;

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      isLoading.value = true;
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          _accessToken = responseData['data'][0]['accessToken'];
          return responseData;
        } else {
          throw Exception('Invalid response format: ${response.body}');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to login');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  int? getUserId() {
    if (_accessToken != null) {
      try {
        final decodedToken = JwtDecoder.decode(_accessToken!);
        return decodedToken['sub'];
      } catch (e) {
        print('Error decoding token: $e');
      }
    }
    return null;
  }

  String? getAccessToken() {
    return _accessToken;
  }

  Future<void> logout() async {
  try {
    await http.post(
      Uri.parse('$baseUrl/auth/logout'),
    );
    Get.snackbar(
      'Logout', 
      'Logout Successfully',
      backgroundColor: Colors.green[400],
      colorText: Colors.white,
      icon: Icon(Icons.check_circle, color: Colors.white),
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      duration: Duration(seconds: 3),
    );
  } catch (e) {
    Get.snackbar(
      'Error', 
      'Failed to logout. Please try again.',
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      icon: Icon(Icons.error_outline, color: Colors.white),
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      duration: Duration(seconds: 3),
    );
  }
  }
}

class ApiService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();
  String? _nama;
  String? _role;
  int? _id;
  String? _roles;
  Map<String, String> _getHeaders() {
    print('access token: ${_authService.getAccessToken()}');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_authService.getAccessToken()}',
    };
  }
  
  Future<String?> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {
          'Authorization': 'Bearer ${_authService.getAccessToken()}',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final userData = jsonResponse['data'];
          _nama = userData['name'];
          _role = userData['role'];
          _id = userData['id'];
          return _nama;
        } else {
          throw Exception('Respons API menunjukkan kegagalan');
        }
      } else {
        throw Exception('Gagal mendapatkan pengguna saat ini. Kode status: ${response.statusCode}');
      }
    } catch (e) {
      print('Kesalahan dalam getCurrentUser: $e');
      return null;
    }
  }

  Future<String?> getRoles() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      _roles = jsonResponse['data']['role'];
      return _roles;
    }
    return null;
  }

  String? getNama() {
    return _nama;
  }

  String? getRole() {
    print('ini coba role service $_role');
    return _role;
  }

  int getUserId() {
    return _id!;
  }

  Future<List<Assessment>?> getAssessments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/assessments'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> assessmentDataNested = jsonResponse['data'];
          if (assessmentDataNested.isNotEmpty) {
            final List<dynamic> assessmentData = assessmentDataNested;
            return assessmentData.map((data) => Assessment.fromJson(data)).toList();
          } else {
            throw Exception('Unexpected data structure in API response');
          }
        } else {
          throw Exception('API response indicates failure');
        }
      } else {
        throw Exception('Failed to load assessments. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAssessments: $e');
      return null;
    }
  }

  Future<Assessment?> createAssessment(Map<String, dynamic> assessmentData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/assessments'),
        headers: _getHeaders(),
        body: json.encode(assessmentData),
      );

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final dynamic data = jsonResponse['data'];
          if (data != null && data is List && data.isNotEmpty) {
            return Assessment.fromJson(data[0]);
          } else if (data != null && data is Map<String, dynamic>) {
            return Assessment.fromJson(data);
          } else {
            print('Data tidak valid: $data');
            return null;
          }
        } else {
          print('API menunjukkan kegagalan: ${jsonResponse['message']}');
          return null;
        }
      } else {
        print('Gagal membuat assessment. Kode status: ${response.statusCode}, Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error dalam createAssessment: $e');
      return null;
    }
  }

  Future<List<SubArea>> getSubAreas() async {
    final response = await http.get(
      Uri.parse('$baseUrl/sub-areas'),
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        final List<dynamic> subAreaData = jsonResponse['data'][0];
        return subAreaData.map((data) => SubArea.fromJson(data)).toList();
      } else {
        throw Exception('API response indicates failure');
      }
    } else {
      throw Exception('Failed to load sub areas');
    }
  }

  Future<List<Model>> getModels() async {
    final response = await http.get(
      Uri.parse('$baseUrl/models'),
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        final List<dynamic> modelData = jsonResponse['data'][0];
        return modelData.map((data) => Model.fromJson(data)).toList();
      } else {
        throw Exception('API response indicates failure');
      }
    } else {
      throw Exception('Failed to load models');
    }
  }

  Future<List<SOP>> getSOPs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/sops'),
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        final List<dynamic> sopData = jsonResponse['data'];
        return sopData.map((data) => SOP.fromJson(data)).toList();
      } else {
        throw Exception('API response indicates failure');
      }
    } else {
      throw Exception('Failed to load SOPs');
    }
  }

  Future<Machine?> createMachine(Map<String, dynamic> machineData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/machines'),
        headers: _getHeaders(),
        body: jsonEncode(machineData),
      );
      if (response.statusCode == 201) {
        return Machine.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error creating machine: $e');
      return null;
    }
  }

  Future<Machine?> getMachineDetails(String machineCode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/machines/$machineCode'),
        headers: _getHeaders(),
      );
      
      print('Response machine: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return Machine(
            id: jsonResponse['data']['id'] ?? '',
            name: jsonResponse['data']['name'] ?? '',
            status: jsonResponse['data']['status']?.toString().toLowerCase() ?? 'ok',
          );
        }
      }
      return null;
    } catch (e) {
      print('Error getting machine details: $e');
      return null;
    }
  }

  Future<Assessment> updateAssessment(int id, Map<String, dynamic> assessmentData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/assessments/$id'),
        headers: _getHeaders(),
        body: json.encode(assessmentData),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return Assessment.fromJson(jsonResponse['data']);
        } else {
          throw Exception('API response indicates failure: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to update assessment. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error in updateAssessment: $e');
      rethrow;
    }
  }

  Future<List<Assessment>> getAssessmentHistoryByMachineId(String machineId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/assessments/history/$machineId'),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> assessmentData = jsonResponse['data'];
          return assessmentData.map((data) => Assessment.fromJson(data)).toList();
        } else {
          throw Exception('API response indicates failure');
        }
      } else {
        throw Exception('Failed to load assessment history. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAssessmentHistoryByMachineId: $e');
      rethrow;
    }
  }
}

class WebSocketService extends GetxService {
  final ApiService _apiService = Get.put(ApiService());
  late WebSocketChannel _channel;
  final messages = <Map<String, dynamic>>[].obs;

  WebSocketService() {
    _connectWebSocket();
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(Uri.parse(websocketUrl));
    _channel.stream.listen((message) {
      try {
        final decodedMessage = json.decode(message);
        final role = _apiService.getRole()?.toUpperCase();
        final id = _apiService.getUserId();
        var type = decodedMessage['type']?.toString().toLowerCase();

        // Tambahkan pesan ke messages untuk didengarkan controller
        messages.add(decodedMessage);

      if (type == 'leader') {
        _initNotification(decodedMessage, id);
      } else if (type == 'pic') {
        _targetAlarm(decodedMessage, id);
      } else if (type == 'andon') {
        _checkAndScheduleAlarm(decodedMessage, role);
      }
      } catch (e) {
        print('Error processing WebSocket message: $e');
      }
    });
  }

  void _initNotification(Map<String, dynamic> message, int? id) {
    final assignedTo = message['leader_id'];
    if (id != null && assignedTo == id) {
      messages.add(message);
      Get.put(ReviewingController()).initializeNotifications();
    }
  }

  void _targetAlarm(Map<String, dynamic> message, int? id) {
    final assignedTo = message['pic_id'];
    if (assignedTo != null && assignedTo == id) {
      messages.add(message);
      print('ini message target alarm: $message');
      Get.put(AndonHomeController()).scheduleAlarm(message);
    }
  }

  void _checkAndScheduleAlarm(Map<String, dynamic> message, String? role) {
    final assignedTo = message['assigned_to']?.toString().toLowerCase() ?? '';
    if (role != null && role.toLowerCase() == assignedTo) {
      messages.add(message);
      print('ini message check and schedule alarm: $message');
      Get.put(AndonHomeController()).scheduleAlarm(message);
    }
  }

  void closeConnection() {
    _channel.sink.close();
  }

  @override
  void onClose() {
    closeConnection();
    super.onClose();
  }
}

class AndonService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();

  Map<String, String> _getHeaders() {
    print('access token: ${_authService.getAccessToken()}');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_authService.getAccessToken()}',
    };
  }

  Future<List<AndonCall>> andonscanner(int andonId) async {
    final response = await http.post(
      Uri.parse('$baseUrl2/andons/scan-qr'),
      headers: _getHeaders(),
      body: json.encode({'andon_call_id': andonId}),
    );
    if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> andonData = jsonResponse['data'];
          return andonData.map((data) => AndonCall.fromJson(data)).toList();
        } else {
          throw Exception('API menunjukkan kegagalan');
        }
    } else {
      throw Exception('Failed to scan QR code. Status code: ${response.statusCode}');
    }
  }

  Future<List<Leader>> getLeader() async {
    final response = await http.get(
      Uri.parse('$baseUrl2/leaders'),
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        final List<dynamic> leaderData = jsonResponse['data'];
        return leaderData.map((data) => Leader.fromJson(data)).toList();
      } else {
        throw Exception('API response indicates failure');
      }
    } else {
      throw Exception('Failed to load leader');
    }
  }

  Future<List<AndonCall>> getAndonsByRoleActive() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl2/andons/active'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> andonData = jsonResponse['data'];
          return andonData.map((data) => AndonCall.fromJson(data)).toList();
        } else {
          throw Exception('API menunjukkan kegagalan');
        }
      } else {
        throw Exception('Gagal memuat data andon. Kode status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error dalam getAndonsByRole: $e');
      rethrow;
    }
  }

  Future<List<AndonCall>> getAndonsByRoleCompleted() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl2/andons/completed'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> andonData = jsonResponse['data'];
          return andonData.map((data) => AndonCall.fromJson(data)).toList();
        } else {
          throw Exception('API menunjukkan kegagalan');
        }
      } else {
        throw Exception('Gagal memuat data andon. Kode status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error dalam getAndonsByRole: $e');
      rethrow;
    }
  }

  Future<List<AndonCall>> getAndonsAllCompleted() async {
  try {
      final response = await http.get(
        Uri.parse('$baseUrl2/andons/completed/all'),
        headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> andonData = jsonResponse['data'];
      return andonData.map((data) => AndonCall.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load andon history. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error in getAndonsAllCompleted: $e');
    rethrow;
  }
  }

  Future<List<AndonCall>> getAndonHistoryByAndonId(String andonId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl2/andons/$andonId'),
        headers: _getHeaders(),
      );

      
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final success = jsonResponse['success'];
          return success;
        } else {
          throw Exception('API response indicates failure');
        }
      } else {
        throw Exception('Failed to load andon history. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAndonHistoryByAndonId: $e');
      rethrow;
    }
  }

  Future<void> addRepairing(Map<String, dynamic> repairingData, int andonId) async {
    final response = await http.put(
      Uri.parse('$baseUrl2/andons/$andonId'),
      headers: _getHeaders(),
      body: json.encode(repairingData),
    );
    if (response.statusCode == 200) {
      Get.snackbar('Success', 'Repairing added successfully',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      );
    } else {
      Get.snackbar('Error', 'Failed to add repairing',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      );
    }
  }

  Future<void> LeaderReview(int andonId, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl2/andons/$andonId/status'),
      headers: _getHeaders(),
      body: json.encode({'status': status}),
    );
    if (response.statusCode == 200) {
      Get.snackbar('Success', 'Status updated successfully',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      );
    } else {
      Get.snackbar('Error', 'Failed to update status',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      );
    }
  }

  Future<List<AndonCall>> getCallbyLeader(int leaderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl2/leaders/$leaderId/andons'),
      headers: _getHeaders(),
    );
    print('response: ${response.body}');
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        final List<dynamic> andonData = jsonResponse['data'];
        return andonData.map((data) => AndonCall.fromJson(data)).toList();
      } else {
        throw Exception('API response indicates failure');
      }
    } else {
      throw Exception('Failed to load andon history. Status code: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> getDailyMTTR(String year, String month) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl2/metrics/mttr?year=$year&month=$month'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return List<Map<String, dynamic>>.from(jsonResponse['data']);
        } else {
          throw Exception('API menunjukkan kegagalan');
        }
      } else {
        throw Exception('Gagal memuat data MTTR. Kode status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error dalam getDailyMTTR: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getDailyMTBF(String year, String month) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl2/metrics/mtbf?year=$year&month=$month'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return List<Map<String, dynamic>>.from(jsonResponse['data']);
        } else {
          throw Exception('API menunjukkan kegagalan');
        }
      } else {
        throw Exception('Gagal memuat data MTBF. Kode status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error dalam getDailyMTBF: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getDailyDowntime(String year, String month) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl2/metrics/downtime?year=$year&month=$month'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return List<Map<String, dynamic>>.from(jsonResponse['data']);
        } else {
          throw Exception('API menunjukkan kegagalan');
        }
      } else {
        throw Exception('Gagal memuat data downtime. Kode status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error dalam getDailyDowntime: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getMachineStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/machines/status-count'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return jsonResponse['data'] as Map<String, dynamic>;
        } else {
          throw Exception('API menunjukkan kegagalan');
        }
      } else {
        throw Exception('Gagal memuat data machine status. Kode status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error dalam getMachineStatus: $e');
      rethrow;
    }
  }
}

