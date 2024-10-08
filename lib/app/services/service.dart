import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../data/models/assessment_model.dart';

class AuthService extends GetxService {
  final String baseUrl = 'http://10.0.2.2:5000/api/v1'; // 10.0.2.2 untuk localhost pada emulator Android

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

class ApiService {
  final String baseUrl = 'http://10.0.2.2:5000/api/v1'; 

  Future<List<Assessment>> getAssessments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/assessments'),
        headers: {'Content-Type': 'application/json'},
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> assessmentDataNested = jsonResponse['data'];
          if (assessmentDataNested.isNotEmpty && assessmentDataNested[0] is List) {
            final List<dynamic> assessmentData = assessmentDataNested[0];
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
      rethrow;
    }
  }

  Future<Assessment> createAssessment(Map<String, dynamic> assessmentData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/assessments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(assessmentData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          if (data.isNotEmpty) {
            return Assessment.fromJson(data[0]);
          } else {
            throw Exception('API response data is empty');
          }
        } else {
          throw Exception('API response indicates failure: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to create assessment. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error in createAssessment: $e');
      rethrow;
    }
  }

  Future<List<SubArea>> getSubAreas() async {
    final response = await http.get(Uri.parse('$baseUrl/sub-areas'));
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
    final response = await http.get(Uri.parse('$baseUrl/models'));
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

  Future<Machine> getMachineDetails(String machineId) async {
    final response = await http.get(Uri.parse('$baseUrl/machines/$machineId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        return Machine.fromJson(jsonResponse['data']);
      } else {
        throw Exception('API response indicates failure');
      }
    } else {
      throw Exception('Failed to load machine details');
    }
  }

  Future<Assessment> updateAssessment(int id, Map<String, dynamic> assessmentData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/assessments/$id'),
        headers: {'Content-Type': 'application/json'},
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
      final response = await http.get(Uri.parse('$baseUrl/assessments/history/$machineId'));
      
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