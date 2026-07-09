import 'package:flutter/material.dart';
import 'package:food_app/core/constants/app_colors.dart';
import 'package:food_app/features/profile/presentation/pages/profile_page.dart';
import 'package:food_app/features/chat/presentation/pages/notification_page.dart';
import '../pages/food_home_page.dart';
import '../pages/favorite_page.dart';

class TaskBarWidget extends StatefulWidget {
  const TaskBarWidget({super.key});

  @override
  State<TaskBarWidget> createState() => _TaskBarWidgetState();
}

class _TaskBarWidgetState extends State<TaskBarWidget> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const FoodHomePage(),
      FavoritePage(
        onBack: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),
      const NotificationPage(showBackButton: false),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Color(0xFFEB9C6C),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primaryRed),
            label: "Trang chủ",
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_outlined),
            selectedIcon: Icon(Icons.favorite, color: AppColors.primaryRed),
            label: "Yêu thích",
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_outlined),
            selectedIcon: Icon(
              Icons.notifications,
              color: AppColors.primaryRed,
            ),
            label: "Thông báo",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_2_outlined),
            selectedIcon: Icon(Icons.person, color: AppColors.primaryRed),
            label: "Tôi",
          ),
        ],
      ),
    );
  }
}
