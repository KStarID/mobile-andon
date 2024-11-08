import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_colors.dart';
import '../../data/models/andon_model.dart';
import 'andon_history_details_controller.dart';

class AndonHistoryDetailsView extends GetView<AndonHistoryDetailsController> {
  const AndonHistoryDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary400, Colors.white],
          ),
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary400)));
        } else if (controller.andonCall.value == null) {
          return Center(child: Text('Data tidak ditemukan'));
        } else {
          final andon = controller.andonCall.value!;
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(andon),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(andon),
                      SizedBox(height: 20),
                      _buildDetailSection(andon),
                      SizedBox(height: 20),
                      _buildStatusHistory(andon),
                    ],
                  ),
                ),
              ),
              ],
            );
          }
        }),
      ),
    );
  }

  Widget _buildSliverAppBar(AndonCall andon) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('Issued Andon #${andon.id}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary400, AppColors.primary400],
            ),
          ),
          child: Center(
            child: Icon(Icons.warning_amber_rounded, size: 80, color: Colors.white),
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildInfoCard(AndonCall andon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Andon Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary400)),
            Divider(color: AppColors.primary400),
            _buildInfoItem('Status', andon.currentStatus.toUpperCase(), isStatus: true),
            _buildInfoItem('PIC', andon.pic?.name ?? 'N/A'),
            _buildInfoItem('Leader', andon.leader?.name ?? 'N/A'),
            _buildInfoItem('Shift', andon.shift?.toUpperCase() ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          if (isStatus) _buildStatusChip(value) else Text(value),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
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
      case 'rejected':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      case 'under review':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        break;
      case 'repairing':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      case 'calling':
        backgroundColor = Colors.yellow[100]!;
        textColor = Colors.yellow[800]!;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
    }

    return Chip(
      label: Text(status.toUpperCase()),
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDetailSection(AndonCall andon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detail', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary400)),
            Divider(color: AppColors.primary400),
            _buildDetailItem('Area', andon.area.name),
            _buildDetailItem('Sub Area', andon.subarea.name),
            _buildDetailItem('Model', andon.model.name),
            _buildDetailItem('SOP', andon.sop.name),
            _buildDetailItem('Start Time', _formatDateTime(andon.startTime)),
            _buildDetailItem('Response Time', _formatDateTime(andon.responseTime)),
            _buildDetailItem('Repairing Time', '${andon.totalRepairingTime?.toStringAsFixed(2) ?? 'N/A'} seconds'),
            _buildDetailItem('Total Response Time', '${andon.totalResponseTime?.toStringAsFixed(2) ?? 'N/A'} seconds'),
            _buildDetailItem('Problem', andon.problem ?? 'N/A'),
            _buildDetailItem('Solution', andon.solution ?? 'N/A'),
            _buildDetailItem('Remarks', andon.remarks ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(': $value')),
        ],
      ),
    );
  }

  Widget _buildStatusHistory(AndonCall andon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary400)),
            Divider(color: AppColors.primary400),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: andon.statusHistories.length,
              itemBuilder: (context, index) {
                final history = andon.statusHistories[index];
                return ListTile(
                  leading: Icon(Icons.history, color: AppColors.primary400),
                  title: Text(history.status.toUpperCase()),
                  subtitle: Text(_formatDateTime(history.changedAt)),
                  trailing: _buildStatusChip(history.status),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime.toLocal());
  }
}
