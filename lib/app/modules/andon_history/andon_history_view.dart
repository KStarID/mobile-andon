import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import 'andon_history_controller.dart';
class AndonHistoryView extends GetView<AndonHistoryController> {
  const AndonHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 32),
          onPressed: () {
            Get.offAllNamed('/andon-home');
          },
        ),
        title: Text('Andon History', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.white
          )
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary400,
        elevation: 0,
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
            _buildFilterSection(context),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary400)));
                } else if (controller.filteredAndonCalls.isEmpty) {
                  return _buildEmptyState();
                } else {
                  return _buildAndonCallList();
                }
              }),
            ),
            _buildPaginationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
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
                if (year != null) {
                  controller.setSelectedYear(year);
                }
              },
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.primary400),
            )),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Obx(() => DropdownButton<int>(
              value: controller.selectedMonth.value,
              items: controller.getMonthList().map((Map<String, dynamic> month) {
                return DropdownMenuItem<int>(
                  value: month['value'] as int,
                  child: Text(month['label'] as String, style: TextStyle(fontSize: 16)),
                );
              }).toList(),
              onChanged: (month) {
                if (month != null) {
                  controller.setSelectedMonth(month);
                }
              },
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: AppColors.primary400),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildAndonCallList() {
    controller.paginatedAndonCalls.sort((a, b) => b.startTime.compareTo(a.startTime));

    return RefreshIndicator(
      onRefresh: () async {
        await controller.fetchAndonCalls();
        return Future<void>.value();
      },
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Card(
            margin: EdgeInsets.all(16),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(AppColors.primary300),
              dataRowHeight: 60,
              horizontalMargin: 16,
              columnSpacing: 20,
              columns: [
                DataColumn(label: Text('Area', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Sub Area', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Model', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('PIC', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Leader', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Problem', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Solution', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Remarks', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Response Time', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Repairing Time', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Status', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
              ],
              rows: controller.paginatedAndonCalls.map((andonCall) {
                return DataRow(
                  cells: [
                    DataCell(Text(andonCall.area.name)),
                    DataCell(Text(andonCall.subarea.name)),
                    DataCell(Text(andonCall.model.name)),
                    DataCell(Text(andonCall.pic?.name ?? '-')),
                    DataCell(Text(andonCall.leader?.name ?? '-')),
                    DataCell(Text(andonCall.problem ?? '-')),
                    DataCell(Text(andonCall.solution ?? '-')),
                    DataCell(Text(andonCall.remarks ?? '-')),
                    DataCell(Text(andonCall.totalRepairingTime != null
                        ? '${andonCall.totalRepairingTime!.toStringAsFixed(2)} seconds'
                        : '-')),
                    DataCell(Text(andonCall.totalResponseTime != null
                        ? '${andonCall.totalResponseTime!.toStringAsFixed(2)} seconds'
                        : '-')),
                    DataCell(_buildStatusCell(andonCall.currentStatus)),
                  ],
                  onSelectChanged: (selected) {
                    if (selected == true) {
                      Get.toNamed('/andon-history-details/${andonCall.id}');
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Obx(() => Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: controller.currentPage.value > 1 ? controller.previousPage : null,
          ),
          Text('Page ${controller.currentPage.value} of ${controller.totalPages.value}'),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: controller.currentPage.value < controller.totalPages.value ? controller.nextPage : null,
          ),
        ],
      ),
    ));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 100, color: Colors.white),
          SizedBox(height: 20),
          Text(
            'No andon calls found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCell(String status) {
    Color backgroundColor;
    Color textColor;
    switch (status.toLowerCase()) {
      case 'completed':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'approved':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'repairing':
        backgroundColor = Colors.yellow[200]!;
        textColor = Colors.yellow[900]!;
        break;
      case 'calling':
        backgroundColor = Colors.red[200]!;
        textColor = Colors.red[800]!;
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
}
