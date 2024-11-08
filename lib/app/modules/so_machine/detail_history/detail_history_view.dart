import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import 'detail_history_controller.dart';
import 'package:intl/intl.dart';

class DetailHistoryView extends GetView<DetailHistoryController> {
  const DetailHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 32),
          onPressed: () {
            Get.offAllNamed('/asesment');
          },
        ),
        title: const Text('Detail History', 
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primary400,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary400),
          ));
        }
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary400, Colors.white],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailSection(),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'History Movements',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary400,),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                _buildHistoryList(),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'update-ases',
        backgroundColor: AppColors.primary400,
        onPressed: () {
          if (controller.assessment.value != null) {
            Get.toNamed('/update-ases', arguments: controller.assessment.value);
          } else {
            Get.snackbar('Error', 'No assessment data available');
          }
        },
        icon: const Icon(Icons.edit),
        label: Text('Update'),
      ),
    );
  }

  Widget _buildDetailSection() {
    final assessment = controller.assessment.value;
    if (assessment == null) return SizedBox.shrink();

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assessment Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary400)),
            Divider(color: AppColors.primary400),
            _buildDetailItem('Submitted by', assessment.user.name.toUpperCase()),
            _buildDetailItem('Shift', assessment.shift.toUpperCase()),
            _buildDetailItem('Updated Time', DateFormat('yyyy-MM-dd HH:mm:ss').format(assessment.assessmentDate)),
            _buildDetailItem('Area', assessment.subArea.area.name),
            _buildDetailItem('Sub Area', assessment.subArea.name),
            _buildDetailItem('SOP', assessment.sop.name),
            _buildDetailItem('Model', assessment.model.name),
            _buildDetailItem('M/C Code', assessment.machine.id),
            _buildDetailItem('M/C Name', assessment.machine.name),
            _buildDetailItem('M/C Status', assessment.status.toUpperCase()),
            _buildDetailItem('Remarks', assessment.notes ?? 'No notes'),
          ],
        ),
      ),
    );
  }
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  '$label ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary400),
                ),
              ),
              Expanded(
                flex: 2,
                child: label == 'M/C Status' ? _buildStatusCell(value) : Text(":  $value", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
          SizedBox(height: 4),
          Divider(color: Colors.grey[300]),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: controller.historyList.length,
      itemBuilder: (context, index) {
        final assessment = controller.historyList[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Text(
              'Assessment #${index + 1}',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary400),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHistoryItem('Submitted By', assessment.user.name.toUpperCase()),
                    _buildHistoryItem('Updated Time', DateFormat('yyyy-MM-dd HH:mm:ss').format(assessment.assessmentDate)),
                    _buildHistoryItem('Area', assessment.subArea.area.name),
                    _buildHistoryItem('SubArea', assessment.subArea.name),
                    _buildHistoryItem('Status', assessment.status.toUpperCase()),
                    _buildHistoryItem('Remarks', assessment.notes ?? 'No notes'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  '$label ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary400),
                ),
              ),
              Expanded(
                flex: 2,
                child: label == 'Status' ? _buildStatusCell(value) : Text(":  $value", style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
          Divider(color: AppColors.primary400.withOpacity(0.5), thickness: 0.5),
        ],
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
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      case 'repairing':
        backgroundColor = Colors.yellow[100]!;
        textColor = Colors.yellow[900]!;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );  
  }
}
