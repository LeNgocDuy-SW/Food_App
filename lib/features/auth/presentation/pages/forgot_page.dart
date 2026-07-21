import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/summer_animated_background.dart';
import '../widgets/login_button.dart';
import 'package:food_app/core/router/app_router.dart';
import 'package:food_app/core/services/auth_service.dart';

class ForgotPage extends StatefulWidget {
  const ForgotPage({super.key});

  @override
  State<ForgotPage> createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final phoneOrEmail = _phoneController.text.trim();
    final result = await AuthService.forgotPassword(phoneOrEmail: phoneOrEmail);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      final otpCode = result['otp_code'];
      
      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.mark_email_read, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text(
                'Mã OTP của bạn',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hệ thống vừa tạo mã xác thực gửi tới $phoneOrEmail:',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade700, width: 1.5),
                ),
                child: Text(
                  otpCode ?? '----',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                    color: Colors.brown,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '(Chế độ mô phỏng SMS Demo)',
                style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Nhập OTP ngay',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );

      if (!mounted) return;

      context.push(
        AppRouter.confirmPassword,
        extra: {'phoneOrEmail': phoneOrEmail},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Có lỗi xảy ra!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                                      'Forgot Password',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Enter your email or phone number below. We will send you a verification pin code',
                                            style: TextStyle(
                                              fontSize: AppSizes.TextSize16,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                      ],
                                    ),
                                    const SizedBox(height: 22),
                                    TextFormField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.emailAddress,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Vui lòng nhập Email hoặc Số điện thoại';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Email / Phone number',
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
                                        prefixIcon: const Padding(
                                          padding: EdgeInsets.only(
                                            left: 24,
                                            right: 12,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.person_outline),
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
                                            title: 'Send OTP',
                                            onPressed: _handleSendOtp,
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

