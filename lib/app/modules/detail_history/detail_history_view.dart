import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import 'detail_history_controller.dart';
import 'package:intl/intl.dart';

class DetailHistoryView extends GetView<DetailHistoryController> {
  const DetailHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Assessment'),
        centerTitle: true,
        backgroundColor: AppColors.primary100,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailSection(),
              SizedBox(height: 24),
              Center(
                child: Text(
                  'History Movements',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 16),
              _buildHistoryList(),
            ],
          ),
        );
      }),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'update-ases',
            backgroundColor: AppColors.primary100,
            onPressed: () {
              if (controller.assessment.value != null) {
                Get.toNamed('/update-ases', arguments: controller.assessment.value);
              } else {
                Get.snackbar('Error', 'No assessment data available');
              }
            },
            child: const Icon(Icons.edit),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDetailSection() {
    final assessment = controller.assessment.value;
    if (assessment == null) return SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Submitted by', assessment.user.username),
            _buildDetailItem('Shift', assessment.shift),
            _buildDetailItem('Sub Area', assessment.subArea.name),
            _buildDetailItem('Area', assessment.subArea.area.name),
            _buildDetailItem('SOP Number', assessment.sopNumber),
            _buildDetailItem('Model', assessment.model.name),
            _buildDetailItem('Machine Code', assessment.machine.id),
            _buildDetailItem('Machine Name', assessment.machine.name),
            _buildDetailItem('Machine Status', assessment.machine.status),
            _buildDetailItem('Assess Date', DateFormat('yyyy-MM-dd HH:mm:ss').format(assessment.assessmentDate)),
            _buildDetailItem('Remarks', assessment.notes ?? 'No notes'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
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
          margin: EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assessment #${index + 1}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                _buildHistoryItem('Submitted By', assessment.user.username),
                _buildHistoryItem('Assess Date', DateFormat('yyyy-MM-dd HH:mm:ss').format(assessment.assessmentDate)),
                _buildHistoryItem('Area', assessment.subArea.area.name),
                _buildHistoryItem('SubArea', assessment.subArea.name),
                _buildHistoryItem('Status', assessment.machine.status),
                _buildHistoryItem('Remarks', assessment.notes ?? 'No notes'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }
}
