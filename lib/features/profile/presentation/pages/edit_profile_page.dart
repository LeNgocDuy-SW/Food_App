import 'package:flutter/material.dart';
import '../../../../core/widget.dart';
import '../widgets/logout_dialog.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

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
                      'Sửa hồ sơ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              // Main content card
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5EFEB),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                        child: Column(
                          children: [
                            // Avatar circle
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                image: const DecorationImage(
                                  image: AssetImage('assets/image/avatar.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Edit avatar button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.edit_square, size: 18, color: Colors.black87),
                                SizedBox(width: 6),
                                Text(
                                  'Sửa',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Info Table rows
                            _buildInfoRow('Tên', 'Lê Ngọc Duy'),
                            _buildInfoRow('Tiểu sử', 'Thiết lập ngay', isPlaceholder: true),
                            _buildInfoRow('Giới tính', 'Nam'),
                            _buildInfoRow('Ngày sinh', '**/ **/2005'),
                            _buildInfoRow('Thông tin cá nhân', 'Thiết lập ngay', isPlaceholderRed: true),
                            _buildInfoRow('Số điện thoại', '********34'),
                            _buildInfoRow('Email', 'le********k@gmail.com'),
                            _buildInfoRow('Tài khoản liên kết', '', showDivider: false),
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

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isPlaceholder = false,
    bool isPlaceholderRed = false,
    bool showDivider = true,
  }) {
    Color valueColor = Colors.black87;
    if (isPlaceholder) {
      valueColor = Colors.black38;
    } else if (isPlaceholderRed) {
      valueColor = const Color(0xFFF22323);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: valueColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
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
