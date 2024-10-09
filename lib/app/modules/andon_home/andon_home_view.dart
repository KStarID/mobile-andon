import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import 'andon_home_controller.dart';

class AndonHomeView extends GetView<AndonHomeController> {
  const AndonHomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AndonHomeView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AndonHomeView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}

Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 2,
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
        } else if (index == 1) {
          Get.offAllNamed('/asesment');
        }
        else if (index == 2) {
          Get.offAllNamed('/andon-home');
        }
      },
    );
}