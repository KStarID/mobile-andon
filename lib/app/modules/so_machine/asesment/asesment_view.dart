import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../../services/service.dart';
import 'asesment_controller.dart';
import 'package:intl/intl.dart';

class AsesmentView extends GetView<AsesmentController> {
  const AsesmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Machinery', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.white
          )
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary400,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white, size: 30),
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white, size: 30),
            onPressed: () {
              Get.find<AuthService>().logout();
              Get.offAllNamed('/splash-screen');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary400, Colors.white],
          ),
        ),
        child: Column(
          children: [
            _buildFilterButtons(context),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary400)));
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
      ),
      floatingActionButton: _buildFloatingActionButtons(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildFilterButtons(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => DropdownButton<int>(
              value: controller.selectedYear.value,
              items: controller.getYearList().map((year) {
                return DropdownMenuItem<int>(
                  value: year,
                  child: Text(year.toString(), style: TextStyle(fontSize: 16)),
                );
              }).toList(),
              onChanged: (year) {
                if (year != null) controller.setSelectedYear(year);
              },
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.primary400),
            )),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Obx(() => DropdownButton<int>(
              value: controller.selectedMonth.value,
              items: controller.getMonthList().map((month) {
                return DropdownMenuItem<int>(
                  value: month['value'],
                  child: Text(month['label'], style: TextStyle(fontSize: 16)),
                );
              }).toList(),
              onChanged: (month) {
                if (month != null) controller.setSelectedMonth(month);
              },
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.primary400),
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
          Icon(Icons.assessment_outlined, size: 100, color: Colors.white),
          SizedBox(height: 20),
          Text(
            'No assessments found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          SizedBox(height: 10),
          Text('Total assessments: ${controller.assessments.length}', style: TextStyle(color: Colors.black)),
          SizedBox(height: 10),
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
              headingRowColor: WidgetStateProperty.all(AppColors.primary300),
              dataRowHeight: 60,
              horizontalMargin: 16,
              columnSpacing: 20,
              sortColumnIndex: controller.sortColumnIndex.value,
              sortAscending: controller.isAscending.value,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
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
                    DataCell(Text('${index + 1}'.padLeft(2, '0'), textAlign: TextAlign.center)),
                    DataCell(Text(assessment.shift.toUpperCase(), textAlign: TextAlign.center)),
                    DataCell(Text(DateFormat('yyyy-MM-dd').format(assessment.assessmentDate), textAlign: TextAlign.center)),
                    DataCell(Text(assessment.subArea.area.name, textAlign: TextAlign.center)),
                    DataCell(Text(assessment.subArea.name, textAlign: TextAlign.center)),
                    DataCell(Text(assessment.sop.name, textAlign: TextAlign.center)),
                    DataCell(Text(assessment.model.name, textAlign: TextAlign.center)),
                    DataCell(Text(assessment.machine.id, textAlign: TextAlign.center)),
                    DataCell(Text(assessment.machine.name, textAlign: TextAlign.center)),
                    DataCell(_buildStatusCell(assessment.status.toUpperCase())),
                    DataCell(Text(
                      assessment.notes != null 
                        ? (assessment.notes!.length > 20 
                            ? '${assessment.notes!.substring(0, 20)}...' 
                            : assessment.notes!)
                        : '',
                      textAlign: TextAlign.center
                    )),
                  ],
                  onSelectChanged: (selected) {
                    if (selected == true) {
                      Get.offAllNamed('/detail-history', arguments: assessment);
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
      height: 35, 
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
          onPressed: () => Get.offAllNamed('/add-ases'),
          backgroundColor: AppColors.primary400,
          elevation: 4,
          child: const Icon(Icons.add, size: 32),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: 'qr-scanner',
          onPressed: () async {
            final result = await Get.toNamed('/qr-scan', arguments: true);
            if (result != null) {
              Get.offAllNamed('/detail-history', arguments: result);
            }
          },
          backgroundColor: AppColors.primary400,
          elevation: 4,
          child: const Icon(Icons.qr_code_scanner, size: 32),
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
      selectedFontSize: 14,
      unselectedFontSize: 14,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_suggest),
          label: 'Machinery',
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
          title: Text('Choose Year and Month', style: TextStyle(color: AppColors.primary400)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.maxFinite,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: controller.selectedYear.value,
                    items: List.generate(5, (index) => DateTime.now().year - index).map((year) {
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
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.maxFinite,
                child: DropdownButtonHideUnderline(
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
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary400,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  controller.applyDateFilter();
                  Navigator.of(context).pop();
                },
                child: Text('Apply Filter'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: AppColors.primary400),
            onPressed: controller.currentPage.value > 1 ? controller.previousPage : null,
          ),
          Text(
            'Page ${controller.currentPage.value} of ${controller.totalPages.value}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary400),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: AppColors.primary400),
            onPressed: controller.currentPage.value < controller.totalPages.value ? controller.nextPage : null,
          ),
        ],
      )),
    );
  }
}