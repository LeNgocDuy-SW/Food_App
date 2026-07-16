import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widget.dart';
import '../../../../core/summer_animated_background.dart';
import '../widgets/login_textfield.dart';
import '../widgets/login_button.dart';
import '../widgets/login_with.dart';
import 'forgot_page.dart';
import 'signup_page.dart';
import 'package:food_app/features/food_catalog/presentation/widgets/taskbar_widget.dart';
import 'package:food_app/features/food_catalog/presentation/pages/food_home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
                      padding: const EdgeInsets.symmetric(horizontal: 56),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: AppSizes.TextSize32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          Row(
                            children: [
                              const Text(
                                "Don’t have an account?",
                                style: TextStyle(
                                  fontSize: AppSizes.TextSize16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.white,
                                ),
                              ),
                              const SizedBox(width: 18),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    createRoute(const SignupPage()),
                                  );
                                },
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: AppSizes.TextSize18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.blueLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const LoginTextField(),
                          const SizedBox(height: 16),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  createRoute(const ForgotPage()),
                                );
                              },
                              child: const Text(
                                'Forgot Password?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          LoginButton(
                            title: 'Login',
                            onPressed: () {
                              FoodHomePage.hasShownAd = false; // Reset banner show state for the new session
                              Navigator.pushReplacement(
                                context,
                                createRoute(const TaskBarWidget()),
                              );
                            },
                          ),
                          const SizedBox(height: 79),
                          const LoginWith(),
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
