import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/assessment_model.dart';
import '../../../services/service.dart';

class AsesmentController extends GetxController {
  late final ApiService _apiService;
  final assessments = <Assessment>[].obs;
  final filteredAssessments = <Assessment>[].obs;
  final isLoading = true.obs;
  final error = Rx<String?>(null);
  final sortColumnIndex = Rx<int?>(null); 
  final isAscending = RxBool(true);
  final selectedYear = DateTime.now().year.obs;
  final selectedMonth = DateTime.now().month.obs;
  final selectedYearString = RxString(DateTime.now().year.toString());
  final selectedMonthString = RxString(DateFormat('MMMM').format(DateTime.now()));

  final itemsPerPage = 10;
  final currentPage = 1.obs;
  final totalPages = 1.obs;

  List<Assessment> get paginatedAssessments {
    final startIndex = (currentPage.value - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return filteredAssessments.sublist(
      startIndex,
      endIndex > filteredAssessments.length ? filteredAssessments.length : endIndex,
    );
  }

  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeApiService();
    fetchAssessments();
  }

  @override
  void onClose() {
    super.onClose();
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
      final latestAssessments = groupAndGetLatestAssessments(fetchedAssessments!);
      assessments.assignAll(latestAssessments);
      applyDateFilter();
    } catch (e) {
      print('Error in fetchAssessments: $e');
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
      assessments.add(createdAssessment!);
      applyDateFilter();
      update();
      Get.offAllNamed('/asesment');
    }finally {
      Get.offAllNamed('/asesment');
      isLoading(false);
    }
  }

  void setStartDate(DateTime date) {
    startDate.value = date;
  }

  void setEndDate(DateTime date) {
    endDate.value = date;
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
    if (sortColumnIndex.value == null) return; // Jangan urutkan jika tidak ada kolom yang dipilih

    filteredAssessments.sort((a, b) {
      switch (sortColumnIndex.value) {
        case 1: // Shift
          final shiftOrder = {'day': 0, 'night': 1};
          final aShift = a.shift.toLowerCase();
          final bShift = b.shift.toLowerCase();
          final comparison = shiftOrder[aShift]!.compareTo(shiftOrder[bShift]!);
          return isAscending.value ? comparison : -comparison;
        case 2: // Updated Time
          final comparison = a.assessmentDate.compareTo(b.assessmentDate);
          return isAscending.value ? comparison : -comparison;
        default:
          return 0;
      }
    });
    filteredAssessments.refresh();
  }

  void updateAssessmentList(Assessment updatedAssessment) {
    final index = assessments.indexWhere((a) => a.id == updatedAssessment.id);
    if (index != -1) {
      assessments[index] = updatedAssessment;
      assessments.refresh();
    }
  }

  void setSelectedYear(int year) {
    selectedYear.value = year;
    selectedYearString.value = year.toString();
    applyDateFilter();
  }

  void setSelectedMonth(int month) {
    selectedMonth.value = month;
    selectedMonthString.value = DateFormat('MMMM').format(DateTime(2022, month));
    applyDateFilter();
  }

  void applyDateFilter() {
    filteredAssessments.value = assessments.where((assessment) {
      return assessment.assessmentDate.year == selectedYear.value &&
             assessment.assessmentDate.month == selectedMonth.value;
    }).toList();
    _sort();
    updatePagination();
  }

  void updatePagination() {
    totalPages.value = (filteredAssessments.length / itemsPerPage).ceil();
    currentPage.value = 1;
  }

  // Tambahkan metode ini untuk mendapatkan daftar tahun
  List<int> getYearList() {
    final currentYear = DateTime.now().year;
    return List.generate(5, (index) => currentYear - 2 + index);
  }

  // Tambahkan metode ini untuk mendapatkan daftar bulan
  List<Map<String, dynamic>> getMonthList() {
    return List.generate(12, (index) {
      final month = index + 1;
      return {
        'value': month,
        'label': DateFormat('MMMM').format(DateTime(2022, month)),
      };
    });
  }
}