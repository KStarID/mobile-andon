import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../../routes/app_pages.dart';
import 'asesment_controller.dart';
import 'package:intl/intl.dart';

class AsesmentView extends GetView<AsesmentController> {
  const AsesmentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessments', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.primary100,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.offAllNamed('/splash-screen');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterButtons(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              } else if (controller.filteredAssessments.isEmpty) {
                return _buildEmptyState();
              } else {
                return _buildAssessmentList();
              }
            }),
          ),
          _buildPaginationControls(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildFilterButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => DropdownButton<int>(
              value: controller.selectedYear.value,
              items: controller.getYearList().map((year) {
                return DropdownMenuItem<int>(
                  value: year,
                  child: Text(year.toString()),
                );
              }).toList(),
              onChanged: (year) {
                if (year != null) controller.setSelectedYear(year);
              },
              isExpanded: true,
            )),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Obx(() => DropdownButton<int>(
              value: controller.selectedMonth.value,
              items: controller.getMonthList().map((month) {
                return DropdownMenuItem<int>(
                  value: month['value'],
                  child: Text(month['label']),
                );
              }).toList(),
              onChanged: (month) {
                if (month != null) controller.setSelectedMonth(month);
              },
              isExpanded: true,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assessment_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'No assessments found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('Total assessments: ${controller.assessments.length}'),
          SizedBox(height: 10),
          Text('Start Date: ${controller.startDate.value}'),
          Text('End Date: ${controller.endDate.value}'),
        ],
      ),
    );
  }

  Widget _buildAssessmentList() {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.fetchAssessments();
        return Future<void>.value();
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Card(
            margin: EdgeInsets.all(16),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Obx(() => DataTable(
              headingRowColor: MaterialStateProperty.all(AppColors.primary300),
              dataRowHeight: 60,
              horizontalMargin: 16,
              columnSpacing: 20,
              sortColumnIndex: controller.sortColumnIndex.value,
              sortAscending: controller.isAscending.value,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              columns: [
                DataColumn(label: Text('ID', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                DataColumn(
                  label: Text('Shift', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending),
                ),
                DataColumn(
                  label: Text('Updated Time', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending),
                ),
                DataColumn(label: Text('Area', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Sub Area', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('SOP Number', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Model', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('M/C Code', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('M/C Name', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Status', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Remarks', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
              ],
              rows: controller.paginatedAssessments.asMap().entries.map((entry) {
                final index = entry.key + ((controller.currentPage.value - 1) * controller.itemsPerPage);
                final assessment = entry.value;
                return DataRow(
                  cells: [
                    DataCell(Text('${index + 1}'.padLeft(2, '0'))),
                    DataCell(Text(assessment.shift.toUpperCase())),
                    DataCell(Text(DateFormat('yyyy-MM-dd').format(assessment.assessmentDate))),
                    DataCell(Text(assessment.subArea.area.name)),
                    DataCell(Text(assessment.subArea.name)),
                    DataCell(Text(assessment.sopNumber)),
                    DataCell(Text(assessment.model.name)),
                    DataCell(Text(assessment.machine.id)),
                    DataCell(Text(assessment.machine.name)),
                    DataCell(_buildStatusCell(assessment.machine.status.toUpperCase())),
                    DataCell(Text(assessment.notes ?? '')),
                  ],
                  onSelectChanged: (selected) {
                    if (selected == true) {
                      Get.toNamed(Routes.DETAIL_HISTORY, arguments: assessment);
                    }
                  },
                );
              }).toList(),
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCell(String status) {
    Color backgroundColor;
    Color textColor;
    switch (status.toLowerCase()) {
      case 'ok':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'ng':
        backgroundColor = Colors.red[200]!;
        textColor = Colors.red[800]!;
        break;
      case 'repairing':
        backgroundColor = Colors.yellow[200]!;
        textColor = Colors.yellow[900]!;
        break;
      default:
        backgroundColor = Colors.grey[200]!;
        textColor = Colors.grey[800]!;
    }
    return Container(
      width: 80, 
      height: 30, 
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: textColor, fontSize: 12),
        textAlign: TextAlign.center, 
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'add-ases',
          onPressed: () => Get.toNamed('/add-ases'),
          child: const Icon(Icons.add, size: 40),
          backgroundColor: AppColors.primary100,
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: 'qr-scanner',
          onPressed: () async {
            final result = await Get.toNamed(Routes.QR_SCAN, arguments: true);
            if (result != null) {
              Get.toNamed(Routes.DETAIL_HISTORY, arguments: result);
            }
          },
          child: const Icon(Icons.qr_code_scanner, size: 40),
          backgroundColor: AppColors.primary100,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 1,
      selectedItemColor: AppColors.primary400,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assessment),
          label: 'Assessment',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notification_important),
          label: 'Andon System',
        ),
      ],
      onTap: (index) {
        if (index == 0) {
          Get.offAllNamed('/home');
        } 
        else if (index == 1) {
          Get.offAllNamed('/asesment');
        }
        else if (index == 2) {
          Get.offAllNamed('/andon-home');
        }
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Year and Month'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.maxFinite,
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: controller.selectedYear.value,
                  items: List.generate(5, (index) => DateTime.now().year + index).map((year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  onChanged: (year) {
                    if (year != null) controller.setSelectedYear(year);
                  },
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: double.maxFinite,
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: controller.selectedMonth.value,
                  items: List.generate(12, (index) => index + 1).map((month) {
                    return DropdownMenuItem<int>(
                      value: month,
                      child: Text(DateFormat('MMMM').format(DateTime(2022, month))),
                    );
                  }).toList(),
                  onChanged: (month) {
                    if (month != null) controller.setSelectedMonth(month);
                  },
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                child: Text('Apply Filter'),
                onPressed: () {
                  controller.applyDateFilter();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaginationControls() {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: controller.currentPage.value > 1 ? controller.previousPage : null,
        ),
        Text('Halaman ${controller.currentPage.value} dari ${controller.totalPages.value}'),
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: controller.currentPage.value < controller.totalPages.value ? controller.nextPage : null,
        ),
      ],
    ));
  }
}