import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:food_app/core/constants/app_colors.dart';
import 'package:food_app/features/profile/presentation/pages/profile_page.dart';
import 'package:food_app/features/chat/presentation/pages/notification_page.dart';
import 'add_food_bottom_sheet.dart';
import '../pages/food_home_page.dart';
import '../pages/favorite_page.dart';

class TaskBarWidget extends StatefulWidget {
  const TaskBarWidget({super.key});

  @override
  State<TaskBarWidget> createState() => _TaskBarWidgetState();
}

class _TaskBarWidgetState extends State<TaskBarWidget> {
  int _selectedIndex = 0;

  void _openAddFoodSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddFoodBottomSheet(
          onFoodAdded: (category, newMeal) {
            FoodHomePage.addMeal(category, newMeal);
          },
        );
      },
    );
  }

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
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: SizedBox(
        height: 85 + bottomPadding,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Thanh Navigation Bar nén mờ phía dưới
            Container(
              height: 66 + bottomPadding,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.09),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 8,
                      right: 8,
                      bottom: bottomPadding,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.93),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.8),
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
                        // Khoảng trống dành cho Nút Add nhô cao ở giữa
                        const SizedBox(width: 58),
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

            // Nút Add (+) nhô lên vượt qua mép trên thanh taskbar
            Positioned(
              top: 0,
              child: _buildCenterAddButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterAddButton() {
    return GestureDetector(
      onTap: _openAddFoodSheet,
      child: Container(
        height: 62,
        width: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF7043), // Cam san hô rực rỡ
              AppColors.primaryRed, // Đỏ chủ đạo
              Color(0xFFC62828), // Đỏ đậm sang trọng
            ],
          ),
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryRed.withValues(alpha: 0.48),
              blurRadius: 18,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 35,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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
