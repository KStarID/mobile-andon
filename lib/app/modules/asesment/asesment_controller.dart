import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/models/assessment_model.dart';

class AsesmentController extends GetxController {
  final assessments = <Assessment>[].obs;
  final filteredAssessments = <Assessment>[].obs;
  final searchQuery = ''.obs;
  final sortColumnIndex = 0.obs;
  final isAscending = true.obs;
  
  final selectedDate = Rx<DateTime?>(null);
  final selectedMonth = Rx<DateTime?>(null);
  final selectedYear = Rx<DateTime?>(null);

  Assessment? findAssessmentByQRCode(String qrCode) {
    try {
      return filteredAssessments.firstWhereOrNull((assessment) => assessment.machineCodeAsset == qrCode);
    } catch (e) {
      print('Error dalam findAssessmentByQRCode: $e');
      return null;
    }
  }

  @override

  void onInit() {
    super.onInit();
    // Inisialisasi data dummy
    try {
      
      assessments.addAll([
      Assessment(no: 1, shift: 'Day', updatedTime: '2023-06-01', area: 'Area A', subArea: 'Sub A', sopNumber: 'SOP001', model: 'Model X', machineCodeAsset: 'MC001', machineName: 'Machine 1', status: 'OK', details: 'Detail 1'),
      Assessment(no: 2, shift: 'Night', updatedTime: '2023-06-02', area: 'Area B', subArea: 'Sub B', sopNumber: 'SOP002', model: 'Model Y', machineCodeAsset: 'MC002', machineName: 'Machine 2', status: 'NG', details: 'Detail 2'),
      Assessment(no: 3, shift: 'Day', updatedTime: '2023-06-03', area: 'Area C', subArea: 'Sub C', sopNumber: 'SOP003', model: 'Model Z', machineCodeAsset: 'MC003', machineName: 'Machine 3', status: 'OK', details: 'Detail 3'),
      Assessment(no: 4, shift: 'Night', updatedTime: '2023-06-04', area: 'Area D', subArea: 'Sub D', sopNumber: 'SOP004', model: 'Model C', machineCodeAsset: 'MC004', machineName: 'Machine 4', status: 'REPAIRING', details: 'Detail 4'),
      Assessment(no: 5, shift: 'Day', updatedTime: '2023-06-05', area: 'Area E', subArea: 'Sub E', sopNumber: 'SOP005', model: 'Model D', machineCodeAsset: 'MC005', machineName: 'Machine 5', status: 'OK', details: 'Detail 5'),
      // Tambahkan data dummy lainnya...
    ]);
    filteredAssessments.addAll(assessments);
    if (kDebugMode) {
      print('assessments successfully added');
    }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding assessments: $e');
      }
    }
  }

  void addAssessment(Assessment assessment) {
    assessments.add(assessment);
    filteredAssessments.add(assessment);
  }

  void _applyFilters() {
    filteredAssessments.value = assessments.where((assessment) {
      final assessmentDate = DateTime.parse(assessment.updatedTime);
      
      bool dateMatch = true;
      bool monthMatch = true;
      bool yearMatch = true;

      if (selectedDate.value != null) {
        dateMatch = assessmentDate.year == selectedDate.value!.year &&
                    assessmentDate.month == selectedDate.value!.month &&
                    assessmentDate.day == selectedDate.value!.day;
      }

      if (selectedMonth.value != null) {
        monthMatch = assessmentDate.year == selectedMonth.value!.year &&
                     assessmentDate.month == selectedMonth.value!.month;
      }

      if (selectedYear.value != null) {
        yearMatch = assessmentDate.year == selectedYear.value!.year;
      }

      return dateMatch && monthMatch && yearMatch &&
             (assessment.area.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
              assessment.subArea.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
              assessment.machineName.toLowerCase().contains(searchQuery.value.toLowerCase()));
    }).toList();

    _sort();
  }

  void search(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void sort(int columnIndex, bool ascending) {
    sortColumnIndex.value = columnIndex;
    isAscending.value = ascending;
    _sort();
  }

  void filterByDate(DateTime? date) {
    selectedDate.value = date;
    _applyFilters();
  }

  void filterByMonth(DateTime? month) {
    selectedMonth.value = month;
    _applyFilters();
  }

  void filterByYear(DateTime? year) {
    selectedYear.value = year;
    _applyFilters();
  }

  void _sort() {
    filteredAssessments.sort((a, b) {
      switch (sortColumnIndex.value) {
        case 0:
          return isAscending.value ? a.no.compareTo(b.no) : b.no.compareTo(a.no);
        case 1:
          return isAscending.value ? a.shift.compareTo(b.shift) : b.shift.compareTo(a.shift);
        case 2:
          return isAscending.value ? a.updatedTime.compareTo(b.updatedTime) : b.updatedTime.compareTo(a.updatedTime);
        case 3:
          return isAscending.value ? a.area.compareTo(b.area) : b.area.compareTo(a.area);
        case 4:
          return isAscending.value ? a.subArea.compareTo(b.subArea) : b.subArea.compareTo(a.subArea);
        case 5:
          return isAscending.value ? a.sopNumber.compareTo(b.sopNumber) : b.sopNumber.compareTo(a.sopNumber);
        case 6:
          return isAscending.value ? a.model.compareTo(b.model) : b.model.compareTo(a.model);
        case 7:
          return isAscending.value ? a.machineCodeAsset.compareTo(b.machineCodeAsset) : b.machineCodeAsset.compareTo(a.machineCodeAsset);
        case 8:
          return isAscending.value ? a.machineName.compareTo(b.machineName) : b.machineName.compareTo(a.machineName);
        case 9:
          final statusOrder = {'OK': 0, 'NG': 1, 'REPAIRING': 2};
          final aStatus = statusOrder[a.status.toUpperCase()] ?? 3;
          final bStatus = statusOrder[b.status.toUpperCase()] ?? 3;
          return isAscending.value ? aStatus.compareTo(bStatus) : bStatus.compareTo(aStatus);
        default:
          return 0;
      }
    });
  }
}
