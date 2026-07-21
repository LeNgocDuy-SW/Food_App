import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/summer_animated_background.dart';
import '../widgets/login_textfield.dart';
import '../widgets/login_button.dart';
import '../widgets/login_with.dart';
import 'package:food_app/core/router/app_router.dart';
import 'package:food_app/features/food_catalog/presentation/pages/food_home_page.dart';
import 'package:food_app/core/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                      padding: const EdgeInsets.symmetric(horizontal: 56),
                      child: Form(
                        key: _formKey,
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
                                    context.push(AppRouter.signup);
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
                            LoginTextField(
                              phoneController: _phoneController,
                              passwordController: _passwordController,
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  context.push(AppRouter.forgot);
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
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (_) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                  final result = await AuthService.login(
                                    email: _phoneController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  );
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                  if (result['success']) {
                                    FoodHomePage.hasShownAd = false;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Login Success"),
                                      ),
                                    );
                                    context.go(AppRouter.taskbar);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(result['message']),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                            const SizedBox(height: 79),
                            const LoginWith(),
                          ],
                        ),
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
