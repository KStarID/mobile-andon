import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../routes/app_pages.dart';
import 'asesment_controller.dart';
import 'package:intl/intl.dart';

class AsesmentView extends GetView<AsesmentController> {
  const AsesmentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment'),
        centerTitle: true,
        backgroundColor: AppColors.primary100,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _showDateRangeDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.offAllNamed('/splash-screen');
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else if (controller.filteredAssessments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('No assessments found'),
                SizedBox(height: 10),
                Text('Total assessments: ${controller.assessments.length}'),
                SizedBox(height: 10),
                Text('Start Date: ${controller.startDate.value}'),
                Text('End Date: ${controller.endDate.value}'),
              ],
            ),
          );
        } else {
          return RefreshIndicator(
            onRefresh: () async {
              controller.fetchAssessments();
              return Future<void>.value();
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(AppColors.primary300),
                  columns: [
                    DataColumn(label: Text('ID', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending)),
                    DataColumn(label: Text('Shift', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending)),
                    DataColumn(label: Text('SOP Number', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending)),
                    DataColumn(label: Text('Assessment Date', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending)),
                    DataColumn(label: Text('Area', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending)),
                    DataColumn(label: Text('Sub Area', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending)),
                    DataColumn(label: Text('Machine ID', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending)),
                    DataColumn(label: Text('Machine Name', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending)),
                    DataColumn(label: Text('Machine Status', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending)),
                    DataColumn(label: Text('Model', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending)),
                    DataColumn(label: Text('Remarks', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                  ],
                  rows: controller.filteredAssessments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final assessment = entry.value;
                    return DataRow(
                      cells: [
                        DataCell(Text('${index + 1}'.padLeft(2, '0'))),
                        DataCell(Text(assessment.shift.toUpperCase())),
                        DataCell(Text(assessment.sopNumber)),
                        DataCell(Text(DateFormat('yyyy-MM-dd').format(assessment.assessmentDate))),
                        DataCell(Text(assessment.subArea.area.name)),
                        DataCell(Text(assessment.subArea.name)),
                        DataCell(Text(assessment.machine.id)),
                        DataCell(Text(assessment.machine.name)),
                        DataCell(Text(assessment.machine.status.toUpperCase())),
                        DataCell(Text(assessment.model.name)),
                        DataCell(Text(assessment.notes ?? '')),
                      ],
                      onSelectChanged: (selected) {
                        if (selected == true) {
                          Get.toNamed(Routes.DETAIL_HISTORY, arguments: assessment);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        }
      }),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add-ases',
            onPressed: () => Get.toNamed('/add-ases'),
            child: const Icon(Icons.add),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'qr-scanner',
            onPressed: () async {
              final result = await Get.toNamed(Routes.QR_SCAN, arguments: true);
              if (result != null) {
                Get.toNamed(Routes.DETAIL_HISTORY, arguments: result);
              }
            },
            child: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Assessment',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Get.offAllNamed('/home');
          }
        },
      ),
    );
  }

  void _showDateRangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Date Range'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                child: Text('Select Start Date'),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: controller.startDate.value ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null) {
                    controller.setStartDate(picked);
                  }
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                child: Text('Select End Date'),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: controller.endDate.value ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null) {
                    controller.setEndDate(picked);
                  }
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                child: Text('Apply Filter'),
                onPressed: () {
                  controller.applyDateFilter();
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                child: Text('Clear Filter'),
                onPressed: () {
                  controller.clearDateFilter();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
