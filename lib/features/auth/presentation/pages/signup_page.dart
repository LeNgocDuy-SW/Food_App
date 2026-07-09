import 'package:flutter/material.dart';
import 'package:food_app/features/auth/presentation/widgets/login_with.dart';
import '../../../../core/widget.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/summer_animated_background.dart';
import '../widgets/sign_up_textfield.dart';
import '../widgets/login_button.dart';
import 'login_page.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

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
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.chevron_left_outlined,
                              size: 35,
                              color: Colors.black,
                            ),
                          ),
                          // 2. Phần nội dung chính được căn giữa màn hình (cả ngang và dọc)
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
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Already have an account?',
                                        style: TextStyle(
                                          fontSize: AppSizes.TextSize16,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            createRoute(const LoginPage()),
                                          );
                                        },
                                        child: Text(
                                          "Sign in",
                                          style: TextStyle(
                                            fontSize: AppSizes.TextSize18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.blueLight,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 22),
                                  const SignUpTextField(hintText: 'Name:'),
                                  const SizedBox(height: 22),
                                  const SignUpTextField(
                                    hintText: 'Email/Phone:',
                                  ),
                                  const SizedBox(height: 22),
                                  const SignUpTextField(
                                    hintText: 'Password',
                                    isPassword: true,
                                  ),
                                  const SizedBox(height: 35),
                                  LoginButton(
                                    title: 'Sign Up',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        createRoute(const LoginPage()),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 79),
                                  const LoginWith(),
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
