import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oppoandon/app/services/service.dart';
import '../../services/user_service.dart';
import '../../services/user_roles.dart';

class HomeController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final ApiService _apiService = Get.put(ApiService());
  final AndonService _andonService = Get.put(AndonService());
  final username = Rx<String?>('');
  var name = Rx<String?>('');
  var role = Rx<UserRole>(UserRole.unknown);

  final downtimeData = <ChartData>[].obs;
  final machineStatusData = <ChartData>[].obs;
  final mtbfMonth = DateTime.now().obs;
  final mttrMonth = DateTime.now().obs;
  final mttrData = <ChartData>[].obs;
  final mtbfData = <ChartData>[].obs;

  final selectedYearMTTR = DateTime.now().year.obs;
  final selectedMonthMTTR = DateTime.now().month.obs;
  final selectedYearMTBF = DateTime.now().year.obs;
  final selectedMonthMTBF = DateTime.now().month.obs;

  final selectedYearDowntime = DateTime.now().year.obs;
  final selectedMonthDowntime = DateTime.now().month.obs;
  final selectedYearMachineStatus = DateTime.now().year.obs;
  final selectedMonthMachineStatus = DateTime.now().month.obs;

  final monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // Tambahkan flag untuk status inisialisasi
  bool isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    username.value = _userService.getUsername();
    loadUserData();
    fetchMTTRData();
    fetchMTBFData();
    fetchDowntimeData();
    fetchMachineStatusData();
  }

  Future<void> loadUserData() async {
    try {
      await Alarm.init();
      await _apiService.getCurrentUser();
      name.value = _apiService.getNama();
      role.value = parseUserRole(_apiService.getRole());
      isInitialized = true; // Set flag setelah inisialisasi berhasil
    } catch (e) {
      print('Error loading user data: $e');
      isInitialized = false;
    }
  }

  Future<void> fetchMTTRData() async {
    try {
      mttrData.clear();
      final year = selectedYearMTTR.value.toString();
      final month = selectedMonthMTTR.value.toString().padLeft(2, '0');
      
      final data = await _andonService.getDailyMTTR(year, month);
      if (data.isEmpty) {
        Get.snackbar('Info', 'Tidak ada data MTTR untuk periode ini',
          duration: Duration(seconds: 3),
          isDismissible: true,
          overlayBlur: 0,
          overlayColor: Colors.transparent,
        );
        return;
      }
      
      mttrData.value = data.map((item) => ChartData(
        'Period ${item['period']}',
        (item['mttr'] as num).toDouble()
      )).toList();
    } catch (e) {
      print('Error fetching MTTR data: $e');
      Get.snackbar('Error', 'Gagal memuat data MTTR',
        duration: Duration(seconds: 3),
        isDismissible: true,
        overlayBlur: 0,
        overlayColor: Colors.transparent,
      );
    }
  }

  void updateMTTRPeriod(int year, int month) {
    selectedYearMTTR.value = year;
    selectedMonthMTTR.value = month;
    fetchMTTRData();
  }

  Future<void> fetchMTBFData() async {
    try {
      mtbfData.clear();
      final year = selectedYearMTBF.value.toString();
      final month = selectedMonthMTBF.value.toString().padLeft(2, '0');
      
      final data = await _andonService.getDailyMTBF(year, month);
      if (data.isEmpty) {
        Get.snackbar('Info', 'Tidak ada data MTBF untuk periode ini',
          duration: Duration(seconds: 3),
          isDismissible: true,
          overlayBlur: 0,
          overlayColor: Colors.transparent,
        );
        return;
      }
      
      mtbfData.value = data.map((item) => ChartData(
        'Period ${item['period']}',
        (item['mtbf'] as num).toDouble()
      )).toList();
    } catch (e) {
      print('Error fetching MTBF data: $e');
      Get.snackbar('Error', 'Gagal memuat data MTBF',
        duration: Duration(seconds: 3),
        isDismissible: true,
        overlayBlur: 0,
        overlayColor: Colors.transparent,
      );
    }
  }

  void updateMTBFPeriod(int year, int month) {
    selectedYearMTBF.value = year;
    selectedMonthMTBF.value = month;
    fetchMTBFData();
  }

  Future<void> fetchDowntimeData() async {
    try {
      downtimeData.clear();
      final year = selectedYearDowntime.value.toString();
      final month = selectedMonthDowntime.value.toString().padLeft(2, '0');
      
      final data = await _andonService.getDailyDowntime(year, month);
      if (data.isEmpty) {
        Get.snackbar('Info', 'Tidak ada data downtime untuk periode ini',
          duration: Duration(seconds: 3),
          isDismissible: true,
          overlayBlur: 0,
          overlayColor: Colors.transparent,
        );
        return;
      }
      
      downtimeData.value = data.map((item) => ChartData(
        'Period ${item['period']}',
        (item['downtime'] as num).toDouble()
      )).toList();
    } catch (e) {
      print('Error fetching downtime data: $e');
      Get.snackbar('Error', 'Gagal memuat data downtime',
        duration: Duration(seconds: 3),
        isDismissible: true,
        overlayBlur: 0,
        overlayColor: Colors.transparent,
      );
    }
  }

  Future<void> fetchMachineStatusData() async {
    try {
      machineStatusData.clear();
      
      final data = await _andonService.getMachineStatus();
      if (data == null) {
        Get.snackbar('Info', 'Tidak ada data status mesin',
          duration: Duration(seconds: 3),
          isDismissible: true,
          overlayBlur: 0,
          overlayColor: Colors.transparent,
        );
        return;
      }
      
      // Convert map to list of ChartData
      machineStatusData.value = [
        ChartData('OK', (data['ok'] ?? 0).toDouble()),
        ChartData('REPAIRING', (data['repairing'] ?? 0).toDouble()),
        ChartData('NG', (data['ng'] ?? 0).toDouble()),
      ];
      
    } catch (e) {
      print('Error fetching machine status data: $e');
      Get.snackbar('Error', 'Gagal memuat data status mesin',
        duration: Duration(seconds: 3),
        isDismissible: true,
        overlayBlur: 0,
        overlayColor: Colors.transparent,
      );
    }
  }

  void updateDowntimePeriod(int year, int month) {
    selectedYearDowntime.value = year;
    selectedMonthDowntime.value = month;
    fetchDowntimeData();
  }

  void updateMachineStatusPeriod(int year, int month) {
    selectedYearMachineStatus.value = year;
    selectedMonthMachineStatus.value = month;
    fetchMachineStatusData();
  }

  bool get canViewAssessment => role.value.canViewAssessment;
  bool get canReview => role.value.canReview;
  bool get canAssess {
    try {
      return role.value.canAssess;
    } catch (e) {
      print('Error getting canAssess: $e');
      return false;
    }
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}
