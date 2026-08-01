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
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: SizedBox(
        height: 84 + bottomPadding,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Thanh Navigation Bar cong lõm mờ cao cấp phía dưới
            CustomPaint(
              painter: NotchedTaskBarPainter(
                shadowColor: Colors.black.withValues(alpha: 0.14),
                borderColor: Colors.white.withValues(alpha: 0.85),
              ),
              child: ClipPath(
                clipper: NotchedTaskBarClipper(
                  notchRadius: 36,
                  cornerRadius: 26,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    height: 66 + bottomPadding,
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      bottom: bottomPadding + 4,
                      top: 10,
                    ),
                    color: Colors.white.withValues(alpha: 0.93),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: _buildNavItem(
                            0,
                            Icons.home_rounded,
                            Icons.home_outlined,
                            "Trang chủ",
                          ),
                        ),
                        Expanded(
                          child: _buildNavItem(
                            1,
                            Icons.favorite_rounded,
                            Icons.favorite_border_rounded,
                            "Yêu thích",
                          ),
                        ),
                        // Khoảng trống cố định dành cho nút Add nhô lõm ở giữa
                        const SizedBox(width: 58),
                        Expanded(
                          child: _buildNavItem(
                            2,
                            Icons.notifications_rounded,
                            Icons.notifications_none_rounded,
                            "Thông báo",
                          ),
                        ),
                        Expanded(
                          child: _buildNavItem(
                            3,
                            Icons.person_rounded,
                            Icons.person_outline_rounded,
                            "Tôi",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Nút Add (+) nhô ôm vừa khít đường cong lõm của taskbar
            Positioned(top: 4, child: _buildCenterAddButton()),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterAddButton() {
    return GestureDetector(
      onTap: _openAddFoodSheet,
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF7043),
              AppColors.primaryRed,
              Color(0xFFC62828),
            ],
          ),
          border: Border.all(color: Colors.white, width: 3.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryRed.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.add_rounded, color: Colors.white, size: 32),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: isSelected ? 1.12 : 1.0,
            child: Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: isSelected ? AppColors.primaryRed : Colors.grey[500],
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primaryRed : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: isSelected ? 12 : 0,
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Clipper tạo đường cong uốn lõm mềm mại ôm trọn nút Add (+)
class NotchedTaskBarClipper extends CustomClipper<Path> {
  final double notchRadius;
  final double cornerRadius;

  NotchedTaskBarClipper({this.notchRadius = 36.0, this.cornerRadius = 26.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final notchWidth = notchRadius * 2.2;
    final p1 = Offset(cx - notchWidth / 2, 0);
    final p2 = Offset(cx + notchWidth / 2, 0);

    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);
    path.lineTo(p1.dx, 0);

    // Đường cong Bezier lõm uốn mềm mại ôm nút (+)
    path.cubicTo(
      cx - notchRadius * 0.85,
      0,
      cx - notchRadius * 0.85,
      notchRadius * 0.9,
      cx,
      notchRadius * 0.92,
    );
    path.cubicTo(
      cx + notchRadius * 0.85,
      notchRadius * 0.9,
      cx + notchRadius * 0.85,
      0,
      p2.dx,
      0,
    );

    path.lineTo(w - cornerRadius, 0);
    path.quadraticBezierTo(w, 0, w, cornerRadius);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Custom Painter vẽ bóng đổ và viền sắc nét dọc theo đường cong lõm
class NotchedTaskBarPainter extends CustomPainter {
  final Color shadowColor;
  final Color borderColor;

  NotchedTaskBarPainter({required this.shadowColor, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final clipper = NotchedTaskBarClipper();
    final path = clipper.getClip(size);

    // Vẽ bóng đổ 3D mềm mại theo đường cong
    canvas.drawShadow(path, shadowColor, 10.0, true);

    // Vẽ đường viền trắng tinh tế sát mép trên đường cong
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
