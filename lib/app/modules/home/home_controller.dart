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
  final downtimeMonth = DateTime.now().obs;
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

  final downtimeTarget = Rx<double?>(null);
  final mttrTarget = Rx<double?>(null);
  final mtbfTarget = Rx<double?>(null);

  // Separate monthly view states for each metric
  final isMTTRMonthlyView = true.obs;
  final isMTBFMonthlyView = true.obs;
  final isDowntimeMonthlyView = true.obs;

  @override
  void onInit() {
    super.onInit();
    username.value = _userService.getUsername();
    loadUserData();
    fetchMTTRData();
    fetchMTBFData();
    fetchDowntimeData();
    fetchMachineStatusData();
    fetchTargets();
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
      final month = isMTTRMonthlyView.value ? selectedMonthMTTR.value.toString().padLeft(2, '0') : null;
      
      final data = await _andonService.getMTTRData(year, month: month);
      if (data.isEmpty) {
        Get.snackbar('Info', 'Tidak ada data MTTR untuk periode ini');
        return;
      }
      
      mttrData.value = data.map((item) => ChartData(
        isMTTRMonthlyView.value 
            ? 'Week ${item['period'].toString()}' 
            : monthNames[int.parse(item['period'].toString()) - 1],
        double.parse(item['mttr'].toString())
      )).toList();

      await fetchMTTRTarget();
    } catch (e) {
      print('Error fetching MTTR data: $e');
    }
  }

  Future<void> fetchMTTRTarget() async {
    try {
      final year = selectedYearMTTR.value.toString();
      final month = isMTTRMonthlyView.value 
          ? selectedMonthMTTR.value.toString().padLeft(2, '0')
          : null;
      
      mttrTarget.value = await _andonService.getTarget(
        year, 
        month: month,
        metricType: 'mttr'
      );
    } catch (e) {
      print('Error fetching MTTR target: $e');
      mttrTarget.value = null;
    }
  }

  void updateMTTRPeriod(int year, int month) {
    selectedYearMTTR.value = year;
    selectedMonthMTTR.value = month;
    fetchMTTRData();
    fetchMTTRTarget();
  }

  Future<void> fetchMTBFData() async {
    try {
      mtbfData.clear();
      final year = selectedYearMTBF.value.toString();
      final month = isMTBFMonthlyView.value ? selectedMonthMTBF.value.toString().padLeft(2, '0') : null;
      
      final data = await _andonService.getMTBFData(year, month: month);
      if (data.isEmpty) {
        Get.snackbar('Info', 'Tidak ada data MTBF untuk periode ini');
        return;
      }
      
      mtbfData.value = data.map((item) => ChartData(
        isMTBFMonthlyView.value 
            ? 'Week ${item['period'].toString()}' 
            : monthNames[int.parse(item['period'].toString()) - 1],
        double.parse(item['mtbf'].toString())
      )).toList();

      await fetchMTBFTarget();
    } catch (e) {
      print('Error fetching MTBF data: $e');
    }
  }

  Future<void> fetchMTBFTarget() async {
    try {
      final year = selectedYearMTBF.value.toString();
      final month = isMTBFMonthlyView.value 
          ? selectedMonthMTBF.value.toString().padLeft(2, '0')
          : null;
      
      mtbfTarget.value = await _andonService.getTarget(
        year, 
        month: month,
        metricType: 'mtbf'
      );
    } catch (e) {
      print('Error fetching MTBF target: $e');
      mtbfTarget.value = null;
    }
  }

  void updateMTBFPeriod(int year, int month) {
    selectedYearMTBF.value = year;
    selectedMonthMTBF.value = month;
    fetchMTBFData();
    fetchMTBFTarget();
  }

  Future<void> fetchDowntimeData() async {
    try {
      downtimeData.clear();
      final year = selectedYearDowntime.value.toString();
      final month = isDowntimeMonthlyView.value ? selectedMonthDowntime.value.toString().padLeft(2, '0') : null;
      
      final data = await _andonService.getDowntimeData(year, month: month);
      if (data.isEmpty) {
        Get.snackbar('Info', 'Tidak ada data downtime untuk periode ini');
        return;
      }
      
      downtimeData.value = data.map((item) => ChartData(
        isDowntimeMonthlyView.value 
            ? 'Week ${item['period'].toString()}' 
            : monthNames[int.parse(item['period'].toString()) - 1],
        double.parse(item['downtime'].toString())
      )).toList();

      await fetchDowntimeTarget();
    } catch (e) {
      print('Error fetching downtime data: $e');
      Get.snackbar('Error', 'Gagal memuat data downtime');
    }
  }

  Future<void> fetchDowntimeTarget() async {
    try {
      final year = selectedYearDowntime.value.toString();
      final month = isDowntimeMonthlyView.value 
          ? selectedMonthDowntime.value.toString().padLeft(2, '0')
          : null;
      
      downtimeTarget.value = await _andonService.getTarget(
        year, 
        month: month,
        metricType: 'downtime'
      );
    } catch (e) {
      print('Error fetching Downtime target: $e');
      downtimeTarget.value = null;
    }
  }

  void updateDowntimePeriod(int year, int month) {
    selectedYearDowntime.value = year;
    selectedMonthDowntime.value = month;
    fetchDowntimeData();
    fetchDowntimeTarget();
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
    }
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

  void toggleMTTRViewMode() {
    isMTTRMonthlyView.value = !isMTTRMonthlyView.value;
    fetchMTTRData();
    fetchMTTRTarget();
  }

  void toggleMTBFViewMode() {
    isMTBFMonthlyView.value = !isMTBFMonthlyView.value;
    fetchMTBFData();
    fetchMTBFTarget();
  }

  void toggleDowntimeViewMode() {
    isDowntimeMonthlyView.value = !isDowntimeMonthlyView.value;
    fetchDowntimeData();
    fetchDowntimeTarget();
  }

  Future<void> fetchTargets() async {
    await Future.wait([
      fetchMTTRTarget(),
      fetchMTBFTarget(),
      fetchDowntimeTarget(),
    ]);
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}
