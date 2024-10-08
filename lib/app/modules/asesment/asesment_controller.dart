import 'package:get/get.dart';
import '../../data/models/assessment_model.dart';
import '../../services/service.dart';

class AsesmentController extends GetxController {
  late final ApiService _apiService;
  final assessments = <Assessment>[].obs;
  final filteredAssessments = <Assessment>[].obs;
  final isLoading = true.obs;
  final error = Rx<String?>(null);
  final sortColumnIndex = 0.obs;
  final isAscending = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApiService();
    fetchAssessments();
  }

  void _initializeApiService() {
    try {
      _apiService = Get.find<ApiService>();
    } catch (e) {
      Get.lazyPut(() => ApiService());
      _apiService = Get.find<ApiService>();
    }
  }

  final startDate = Rx<DateTime?>(null);
  final endDate = Rx<DateTime?>(null);

  Assessment? findAssessmentByQRCode(String qrCode) {
    try {
      return assessments.firstWhereOrNull((assessment) => assessment.machine.id == qrCode);
    } catch (e) {
      print('Error dalam findAssessmentByQRCode: $e');
      return null;
    }
  }

  Future<void> fetchAssessments() async {
    try {
      isLoading(true);
      final fetchedAssessments = await _apiService.getAssessments();
      // Mengelompokkan assessment berdasarkan machineId dan mengambil yang terbaru
      final latestAssessments = groupAndGetLatestAssessments(fetchedAssessments);
      assessments.assignAll(latestAssessments);
      applyDateFilter();
    } catch (e) {
      print('Error fetching assessments: $e');
      Get.snackbar('Error', 'Failed to fetch assessments: $e');
    } finally {
      isLoading(false);
    }
  }

  List<Assessment> groupAndGetLatestAssessments(List<Assessment> allAssessments) {
    final groupedAssessments = <String, Assessment>{};
    for (var assessment in allAssessments) {
      final existingAssessment = groupedAssessments[assessment.machine.id];
      if (existingAssessment == null || assessment.assessmentDate.isAfter(existingAssessment.assessmentDate)) {
        groupedAssessments[assessment.machine.id] = assessment;
      }
    }
    return groupedAssessments.values.toList();
  }

  Future<void> addAssessment(Map<String, dynamic> assessmentData) async {
    try {
      isLoading(true);
      final createdAssessment = await _apiService.createAssessment(assessmentData);
      assessments.add(createdAssessment);
      applyDateFilter();
    } catch (e) {
      print('Error adding assessment: $e');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  void setStartDate(DateTime date) {
    startDate.value = date;
  }

  void setEndDate(DateTime date) {
    endDate.value = date;
  }

  void applyDateFilter() {
    if (startDate.value != null && endDate.value != null) {
      filteredAssessments.value = assessments.where((assessment) {
        return assessment.assessmentDate.isAfter(startDate.value!) && 
               assessment.assessmentDate.isBefore(endDate.value!.add(Duration(days: 1)));
      }).toList();
    } else {
      filteredAssessments.value = assessments;
    }
    print('Applied date filter. Filtered assessments: ${filteredAssessments.length}');
    _sort();
  }

  void clearDateFilter() {
    startDate.value = null;
    endDate.value = null;
    filteredAssessments.value = assessments;
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
          return isAscending.value ? a.id.compareTo(b.id) : b.id.compareTo(a.id);
        case 1:
          return isAscending.value ? a.shift.compareTo(b.shift) : b.shift.compareTo(a.shift);
        case 2:
          return isAscending.value ? a.sopNumber.compareTo(b.sopNumber) : b.sopNumber.compareTo(a.sopNumber);
        case 3:
          return isAscending.value ? a.assessmentDate.compareTo(b.assessmentDate) : b.assessmentDate.compareTo(a.assessmentDate);
        case 4:
          return isAscending.value ? a.subArea.name.compareTo(b.subArea.name) : b.subArea.name.compareTo(a.subArea.name);
        case 5:
          return isAscending.value ? a.machine.id.compareTo(b.machine.id) : b.machine.id.compareTo(a.machine.id);
        case 6:
          return isAscending.value ? a.machine.name.compareTo(b.machine.name) : b.machine.name.compareTo(a.machine.name);
        case 7:
          return isAscending.value ? a.machine.status.compareTo(b.machine.status) : b.machine.status.compareTo(a.machine.status);
        case 8:
          return isAscending.value ? a.model.name.compareTo(b.model.name) : b.model.name.compareTo(a.model.name);
        default:
          return 0;
      }
    });
  }

  void updateAssessmentList(Assessment updatedAssessment) {
    final index = assessments.indexWhere((a) => a.id == updatedAssessment.id);
    if (index != -1) {
      assessments[index] = updatedAssessment;
      assessments.refresh();
    }
  }
}