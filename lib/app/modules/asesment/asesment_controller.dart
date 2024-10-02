import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:testcli/app/data/models/assessment_model.dart';

class AsesmentController extends GetxController {
  final assessments = <Assessment>[].obs;
  final filteredAssessments = <Assessment>[].obs;
  final searchQuery = ''.obs;
  final sortColumnIndex = 0.obs;
  final isAscending = true.obs;

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
          Assessment(no: 1, updatedTime: '2023-06-01', area: 'Area A', subArea: 'Sub A', sopNumber: 'SOP001', model: 'Model X', machineCodeAsset: 'MC001', machineName: 'Machine 1', status: 'Active', details: 'Detail 1'),
      Assessment(no: 2, updatedTime: '2023-06-02', area: 'Area B', subArea: 'Sub B', sopNumber: 'SOP002', model: 'Model Y', machineCodeAsset: 'MC002', machineName: 'Machine 2', status: 'Inactive', details: 'Detail 2'),
      Assessment(no: 3, updatedTime: '2023-06-03', area: 'Area C', subArea: 'Sub C', sopNumber: 'SOP003', model: 'Model Z', machineCodeAsset: 'MC003', machineName: 'Machine 3', status: 'Inactive', details: 'Detail 3'),
      Assessment(no: 4, updatedTime: '2023-06-04', area: 'Area D', subArea: 'Sub D', sopNumber: 'SOP004', model: 'Model C', machineCodeAsset: 'MC004', machineName: 'Machine 4', status: 'Active', details: 'Detail 4'),
      Assessment(no: 5, updatedTime: '2023-06-05', area: 'Area E', subArea: 'Sub E', sopNumber: 'SOP005', model: 'Model D', machineCodeAsset: 'MC005', machineName: 'Machine 5', status: 'Inactive', details: 'Detail 5'),
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

  void search(String query) {
    searchQuery.value = query;
    filteredAssessments.value = assessments.where((assessment) =>
        assessment.area.toLowerCase().contains(query.toLowerCase()) ||
        assessment.subArea.toLowerCase().contains(query.toLowerCase()) ||
        assessment.machineName.toLowerCase().contains(query.toLowerCase())).toList();
    _sort();
  }

  void sort(int columnIndex, bool ascending) {
    sortColumnIndex.value = columnIndex;
    isAscending.value = ascending;
    _sort();
  }

  void _sort() {
    filteredAssessments.sort((a, b) {
      switch (sortColumnIndex.value) {
        case 0:
          return isAscending.value ? a.no.compareTo(b.no) : b.no.compareTo(a.no);
        case 1:
          return isAscending.value ? a.updatedTime.compareTo(b.updatedTime) : b.updatedTime.compareTo(a.updatedTime);
        case 2:
          return isAscending.value ? a.area.compareTo(b.area) : b.area.compareTo(a.area);
        case 3:
          return isAscending.value ? a.subArea.compareTo(b.subArea) : b.subArea.compareTo(a.subArea);
        case 4:
          return isAscending.value ? a.sopNumber.compareTo(b.sopNumber) : b.sopNumber.compareTo(a.sopNumber);
        case 5:
          return isAscending.value ? a.model.compareTo(b.model) : b.model.compareTo(a.model);
        case 6:
          return isAscending.value ? a.machineCodeAsset.compareTo(b.machineCodeAsset) : b.machineCodeAsset.compareTo(a.machineCodeAsset);
        case 7:
          return isAscending.value ? a.machineName.compareTo(b.machineName) : b.machineName.compareTo(a.machineName);
        case 8:
          return isAscending.value ? a.status.compareTo(b.status) : b.status.compareTo(a.status);
        default:
          return 0;
      }
    });
  }
}
