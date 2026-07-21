import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/summer_animated_background.dart';
import '../widgets/login_button.dart';
import '../widgets/confirm_pin.dart';
import 'package:food_app/core/router/app_router.dart';
import 'package:food_app/core/services/auth_service.dart';

class ConfirmPassWordPage extends StatefulWidget {
  final String phoneOrEmail;
  const ConfirmPassWordPage({super.key, this.phoneOrEmail = ''});

  @override
  State<ConfirmPassWordPage> createState() => _ConfirmPassWordPageState();
}

class _ConfirmPassWordPageState extends State<ConfirmPassWordPage> {
  final List<TextEditingController> _pinController = List.generate(
    4,
    (_) => TextEditingController(),
  );
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _pinController) {
      controller.dispose();
    }
    super.dispose();
  }

  String getFullPin() {
    return _pinController.map((c) => c.text.trim()).join();
  }

  Future<void> _handleVerifyOtp(String targetPhoneOrEmail) async {
    final phoneOrEmail = targetPhoneOrEmail.isNotEmpty
        ? targetPhoneOrEmail
        : widget.phoneOrEmail;
    final pin = getFullPin();
    if (pin.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đủ 4 chữ số OTP'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.verifyOtp(
      phoneOrEmail: phoneOrEmail,
      otpCode: pin,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Xác thực OTP thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      context.push(
        AppRouter.changePassword,
        extra: {
          'phoneOrEmail': phoneOrEmail,
          'otpCode': pin,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Mã OTP không đúng!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final extraPhoneOrEmail = extra?['phoneOrEmail'] as String? ?? '';
    final phoneOrEmail = extraPhoneOrEmail.isNotEmpty
        ? extraPhoneOrEmail
        : widget.phoneOrEmail;


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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Confirm OTP',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          phoneOrEmail.isNotEmpty
                                              ? 'Enter the pin code sent to $phoneOrEmail'
                                              : 'Enter the pin code sent to your mobile phone or email',
                                          style: const TextStyle(
                                            fontSize: AppSizes.TextSize16,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                  ),
                                  const SizedBox(height: 22),
                                  ConfirmPin(controllers: _pinController),
                                  const SizedBox(height: 35),
                                  _isLoading
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        )
                                      : LoginButton(
                                          title: 'Confirm OTP',
                                          onPressed: () => _handleVerifyOtp(phoneOrEmail),
                                        ),
                                ],
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

