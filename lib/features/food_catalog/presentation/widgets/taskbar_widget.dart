import 'dart:ui';
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

    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true, // Content scrolls under the glass bar
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 70 + bottomPadding,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: bottomPadding,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.90),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    0,
                    Icons.home_rounded,
                    Icons.home_outlined,
                    "Trang chủ",
                  ),
                  _buildNavItem(
                    1,
                    Icons.favorite_rounded,
                    Icons.favorite_border_rounded,
                    "Yêu thích",
                  ),
                  _buildNavItem(
                    2,
                    Icons.notifications_rounded,
                    Icons.notifications_none_rounded,
                    "Thông báo",
                  ),
                  _buildNavItem(
                    3,
                    Icons.person_rounded,
                    Icons.person_outline_rounded,
                    "Tôi",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData selectedIcon,
    IconData unselectedIcon,
    String label,
  ) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryRed.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: isSelected ? AppColors.primaryRed : Colors.grey[600],
              size: 24,
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              firstChild: Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
              secondChild: const SizedBox.shrink(),
              crossFadeState: isSelected
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
            ),
          ],
        ),
      ),
    );
  }
}
