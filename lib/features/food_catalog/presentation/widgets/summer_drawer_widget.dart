import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget.dart';
import '../../../order/presentation/pages/order_history_page.dart';
import '../../../profile/presentation/pages/settings_page.dart';
import '../../../profile/presentation/widgets/logout_dialog.dart';

class SummerDrawerWidget extends StatelessWidget {
  const SummerDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          // Gradient mang phong cách mùa hè (Biển xanh - Nắng vàng)
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4FC3F7), // Xanh dương nhạt (Biển/Trời)
              Color(0xFFFFF9C4), // Vàng nhạt (Cát/Nắng)
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header phong cách mùa hè
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.4),
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                        ),
                        const Text('🏖️', style: TextStyle(fontSize: 50)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Summer Vibes',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Chào hè rực rỡ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Các mục Menu
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    _buildMenuItem(
                      icon: Icons.local_offer_rounded,
                      title: 'Khuyến mãi mùa hè',
                      iconColor: Colors.orange,
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.fastfood_rounded,
                      title: 'Món mới giải nhiệt',
                      iconColor: Colors.redAccent,
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.star_rounded,
                      title: 'Món yêu thích',
                      iconColor: Colors.amber.shade700,
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.history_rounded,
                      title: 'Lịch sử đơn hàng',
                      iconColor: Colors.blue,
                      onTap: () {
                        Navigator.pop(context); // Đóng drawer trước
                        Navigator.push(context, createRoute(const OrderHistoryPage()));
                      },
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(color: Colors.white54, thickness: 1.5),
              ),

              // Footer menu
              _buildMenuItem(
                icon: Icons.settings_rounded,
                title: 'Cài đặt',
                iconColor: Colors.black54,
                onTap: () {
                  Navigator.pop(context); // Đóng drawer trước
                  Navigator.push(context, createRoute(const SettingsPage()));
                },
              ),
              _buildMenuItem(
                icon: Icons.help_outline_rounded,
                title: 'Hỗ trợ & Trợ giúp',
                iconColor: Colors.black54,
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.logout_rounded,
                title: 'Đăng xuất',
                iconColor: Colors.redAccent,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => LogoutDialog(),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        hoverColor: Colors.white.withOpacity(0.3),
        splashColor: Colors.white.withOpacity(0.4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.black87.withOpacity(0.4),
        ),
        onTap: onTap,
      ),
    );
  }
}
