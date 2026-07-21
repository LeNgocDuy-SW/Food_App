import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../widgets/welcom_button.dart';
import '../../../../core/summer_animated_background.dart';
import 'package:food_app/core/services/auth_service.dart';
import 'package:food_app/core/router/app_router.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final result = await AuthService.getCurrentUser();
    if (!mounted) return;

    if (result['success'] == true) {
      // Đã đăng nhập và phiên làm việc hợp lệ -> Vào thẳng trang chủ
      context.go(AppRouter.taskbar);
    } else {
      setState(() {
        _isCheckingSession = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SummerAnimatedBackground(
        child: SafeArea(
          child: _isCheckingSession
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(56.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Welcome to DuFood!",
                        style: TextStyle(
                          fontSize: AppSizes.TextSize48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const Text(
                        "Chào mừng đến với thế giới đồ ăn!",
                        style: TextStyle(
                          fontSize: AppSizes.TextSize20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 170),
                      const WelcomeButton(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

