import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/andon_model.dart';
import '../../services/service.dart';

class AndonHistoryController extends GetxController {
  late final AndonService _andonService;
  
  final andonCalls = <AndonCall>[].obs;
  final filteredAndonCalls = <AndonCall>[].obs;
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

  List<AndonCall> get paginatedAndonCalls {
    final startIndex = (currentPage.value - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return filteredAndonCalls.sublist(
      startIndex,
      endIndex > filteredAndonCalls.length ? filteredAndonCalls.length : endIndex,
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
    cekleader();
  }

  Future<void> cekleader() async {
    final role = await ApiService().getRoles();
    if (role == 'leader') {
      fetchAndonCallsAll();
      print('leader');
    } else {
      fetchAndonCalls();
      print('not leader');
    }
  }

  void _initializeApiService() {
    try {
      _andonService = Get.find<AndonService>();
    } catch (e) {
      Get.lazyPut(() => AndonService());
      _andonService = Get.find<AndonService>();
    }
  }

  final startDate = Rx<DateTime?>(null);
  final endDate = Rx<DateTime?>(null);

  Future<void> fetchAndonCalls() async {
    try {
      isLoading(true);
      final fetchedAndonCalls = await _andonService.getAndonsByRoleCompleted();
      andonCalls.assignAll(fetchedAndonCalls);
      applyDateFilter();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch andon calls. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        icon: Icon(Icons.error_outline, color: Colors.white),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchAndonCallsAll() async {
    try {
      isLoading(true);
      final fetchedAndonCallsAll = await _andonService.getAndonsAllCompleted();
      andonCalls.assignAll(fetchedAndonCallsAll);
      applyDateFilter();
      print('fetchedAndonCallsAll: $fetchedAndonCallsAll');
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch andon calls. Please try again.',
        snackPosition: SnackPosition.TOP,
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
    filteredAndonCalls.value = andonCalls;
    _sort();
  }

  void sort(int columnIndex, bool ascending) {
    sortColumnIndex.value = columnIndex;
    isAscending.value = ascending;
    _sort();
  }

  void _sort() {
    if (sortColumnIndex.value == null) return;

    filteredAndonCalls.sort((a, b) {
      switch (sortColumnIndex.value) {
        case 2: // Shift
          final shiftOrder = {'day': 0, 'night': 1};
          final aShift = a.shift?.toLowerCase() ?? '';
          final bShift = b.shift?.toLowerCase() ?? '';
          final comparison = shiftOrder[aShift]!.compareTo(shiftOrder[bShift]!);
          return isAscending.value ? comparison : -comparison;
        case 3: // Start Time
          final comparison = a.startTime.compareTo(b.startTime);
          return isAscending.value ? comparison : -comparison;
        default:
          return 0;
      }
    });
    filteredAndonCalls.refresh();
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
    filteredAndonCalls.value = andonCalls.where((andonCall) {
      return andonCall.startTime.year == selectedYear.value &&
             andonCall.startTime.month == selectedMonth.value;
    }).toList();
    _sort();
    updatePagination();
  }

  void updatePagination() {
    totalPages.value = (filteredAndonCalls.length / itemsPerPage).ceil();
    currentPage.value = 1;
  }

  List<int> getYearList() {
    final currentYear = DateTime.now().year;
    return List.generate(5, (index) => currentYear - 2 + index);
  }

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
