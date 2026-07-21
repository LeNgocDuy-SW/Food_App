import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widget.dart';
import '../widgets/logout_dialog.dart';
import 'package:food_app/core/services/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String _name = 'Đang tải...';
  String _emailOrPhone = 'Đang tải...';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final result = await AuthService.getCurrentUser();
    if (!mounted) return;

    if (result['success'] == true && result['data'] != null) {
      final data = result['data'];
      setState(() {
        _name = data['full_name'] ?? 'Chưa thiết lập';
        _emailOrPhone = data['email'] ?? 'Chưa thiết lập';
      });
    }
  }

  Future<void> _showEditDialog({
    required String title,
    required String initialValue,
    required Function(String newValue) onSave,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Chỉnh sửa $title',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Nhập $title mới',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Vui lòng không để trống';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newValue = controller.text.trim();
                Navigator.of(dialogContext).pop();
                await onSave(newValue);
              }
            },
            child: const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateName(String newName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final result = await AuthService.updateProfile(fullName: newName);

    if (!mounted) return;
    Navigator.pop(context);

    if (result['success'] == true) {
      setState(() {
        _name = newName;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật tên thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Cập nhật thất bại!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateEmailOrPhone(String newEmailOrPhone) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final result = await AuthService.updateProfile(email: newEmailOrPhone);

    if (!mounted) return;
    Navigator.pop(context);

    if (result['success'] == true) {
      setState(() {
        _emailOrPhone = newEmailOrPhone;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật Email/SĐT thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Cập nhật thất bại!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
                      onTap: () => context.pop(),
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
                                  'Sửa ảnh',
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
                            _buildInfoRow(
                              'Họ và Tên',
                              _name,
                              onTap: () => _showEditDialog(
                                title: 'Họ và Tên',
                                initialValue: _name,
                                onSave: _updateName,
                              ),
                            ),
                            _buildInfoRow(
                              'Email / SĐT',
                              _emailOrPhone,
                              onTap: () => _showEditDialog(
                                title: 'Email / SĐT',
                                initialValue: _emailOrPhone,
                                onSave: _updateEmailOrPhone,
                              ),
                            ),
                            _buildInfoRow('Giới tính', 'Nam'),
                            _buildInfoRow('Ngày sinh', '**/ **/2005'),
                            _buildInfoRow('Tài khoản liên kết', 'Google / Facebook', showDivider: false),
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
    VoidCallback? onTap,
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
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
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
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: valueColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        onTap != null ? Icons.edit_note : Icons.arrow_forward_ios,
                        size: onTap != null ? 20 : 14,
                        color: onTap != null ? Colors.deepOrange : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
