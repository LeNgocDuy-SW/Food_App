import 'package:flutter/material.dart';
import '../../../../core/widget.dart';
import 'edit_profile_page.dart';
import '../widgets/logout_dialog.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        opacity: 0.5,
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      'Thiết lập tài khoản',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              // Settings list options
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5EFEB), // Pinkish white base color
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tài khoản',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildSettingsItem(
                              context,
                              'Tài khoản & Bảo mật',
                              onTap: () {
                                Navigator.push(context, createRoute(const EditProfilePage()));
                              },
                            ),
                            _buildSettingsItem(context, 'Địa chỉ'),
                            _buildSettingsItem(context, 'Cài đặt thông báo'),
                            _buildSettingsItem(context, 'Cài đặt riêng tư'),
                            _buildSettingsItem(context, 'Ngôn ngữ'),
                            _buildSettingsItem(context, 'Điều khoản'),
                            _buildSettingsItem(context, 'Giới thiệu'),
                            _buildSettingsItem(context, 'Tài khoản/Thẻ ngân hàng'),
                            _buildSettingsItem(context, 'Yêu cầu xóa tài khoản', showDivider: false),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Logout Button
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => const LogoutDialog(),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5EFEB),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black12, width: 0.5),
                          ),
                          child: const Center(
                            child: Text(
                              'Đổi tài khoản/Đăng xuất',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF22323),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title, {
    VoidCallback? onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
          onTap: onTap ?? () {},
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.black12,
          ),
      ],
    );
  }
}
