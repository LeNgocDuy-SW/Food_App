import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/summer_animated_background.dart';
import '../widgets/login_button.dart';
import 'package:food_app/core/router/app_router.dart';
import 'package:food_app/core/services/auth_service.dart';

class ChangePasswordPage extends StatefulWidget {
  final String phoneOrEmail;
  final String otpCode;

  const ChangePasswordPage({
    super.key,
    this.phoneOrEmail = '',
    this.otpCode = '',
  });

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword(String targetPhoneOrEmail, String targetOtpCode) async {
    if (!_formKey.currentState!.validate()) return;

    final phoneOrEmail = targetPhoneOrEmail.isNotEmpty
        ? targetPhoneOrEmail
        : widget.phoneOrEmail;
    final otpCode = targetOtpCode.isNotEmpty ? targetOtpCode : widget.otpCode;

    if (phoneOrEmail.isEmpty || otpCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thiếu thông tin xác thực OTP! Vui lòng làm lại từ bước Quên mật khẩu.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.resetPassword(
      phoneOrEmail: phoneOrEmail,
      otpCode: otpCode,
      newPassword: _newPasswordController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Đổi mật khẩu thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      context.go(AppRouter.login);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Đổi mật khẩu thất bại!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final extraPhoneOrEmail = extra?['phoneOrEmail'] as String? ?? '';
    final extraOtpCode = extra?['otpCode'] as String? ?? '';

    final phoneOrEmail = extraPhoneOrEmail.isNotEmpty
        ? extraPhoneOrEmail
        : widget.phoneOrEmail;
    final otpCode = extraOtpCode.isNotEmpty ? extraOtpCode : widget.otpCode;


    return Scaffold(
      body: SummerAnimatedBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: const Icon(
                              Icons.chevron_left_outlined,
                              size: 35,
                              color: Colors.black,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Change Password',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    TextFormField(
                                      controller: _newPasswordController,
                                      obscureText: _obscureNewPassword,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Vui lòng nhập mật khẩu mới';
                                        }
                                        if (value.length < 6) {
                                          return 'Mật khẩu phải từ 6 ký tự trở lên';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'New Password',
                                        filled: true,
                                        fillColor: AppColors.white,
                                        errorStyle: const TextStyle(
                                          color: Colors.yellowAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 16,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 12,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: AnimatedSwitcher(
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  transitionBuilder:
                                                      (child, animation) =>
                                                          ScaleTransition(
                                                            scale: animation,
                                                            child: child,
                                                          ),
                                                  child: Icon(
                                                    _obscureNewPassword
                                                        ? Icons.visibility_off
                                                        : Icons.visibility,
                                                    key: ValueKey<bool>(
                                                      _obscureNewPassword,
                                                    ),
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscureNewPassword =
                                                        !_obscureNewPassword;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    TextFormField(
                                      controller: _confirmPasswordController,
                                      obscureText: _obscureConfirmPassword,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Vui lòng xác nhận mật khẩu';
                                        }
                                        if (value != _newPasswordController.text) {
                                          return 'Mật khẩu xác nhận không trùng khớp';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Confirm Password',
                                        filled: true,
                                        fillColor: AppColors.white,
                                        errorStyle: const TextStyle(
                                          color: Colors.yellowAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 16,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 12,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: AnimatedSwitcher(
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  transitionBuilder:
                                                      (child, animation) =>
                                                          ScaleTransition(
                                                            scale: animation,
                                                            child: child,
                                                          ),
                                                  child: Icon(
                                                    _obscureConfirmPassword
                                                        ? Icons.visibility_off
                                                        : Icons.visibility,
                                                    key: ValueKey<bool>(
                                                      _obscureConfirmPassword,
                                                    ),
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscureConfirmPassword =
                                                        !_obscureConfirmPassword;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 35),
                                    _isLoading
                                        ? const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          )
                                        : LoginButton(
                                            title: 'Change Password',
                                            onPressed: () => _handleChangePassword(
                                              phoneOrEmail,
                                              otpCode,
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

