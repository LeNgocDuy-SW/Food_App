import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:food_app/features/auth/presentation/widgets/login_with.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/summer_animated_background.dart';
import '../widgets/sign_up_textfield.dart';
import '../widgets/login_button.dart';
import 'package:food_app/core/router/app_router.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailPhoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailPhoneController.dispose();
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
                          // 2. Phần nội dung chính được căn giữa màn hình (cả ngang và dọc)
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
                                            context.push(AppRouter.login);
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
                                    SignUpTextField(
                                      hintText: 'Name:',
                                      controller: _nameController,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Vui lòng nhập tên';
                                        }
                                        if (value.trim().length < 2) {
                                          return 'Tên phải từ 2 ký tự trở lên';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 22),
                                    SignUpTextField(
                                      hintText: 'Email/Phone:',
                                      controller: _emailPhoneController,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Vui lòng nhập email hoặc số điện thoại';
                                        }
                                        final clean = value.trim();
                                        final emailRegex = RegExp(
                                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                                        final phoneRegex = RegExp(r'^[0-9]{9,11}$');
                                        if (!emailRegex.hasMatch(clean) &&
                                            !phoneRegex.hasMatch(clean)) {
                                          return 'Vui lòng nhập đúng định dạng email hoặc số điện thoại';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 22),
                                    SignUpTextField(
                                      hintText: 'Password',
                                      isPassword: true,
                                      controller: _passwordController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Vui lòng nhập mật khẩu';
                                        }
                                        if (value.length < 6) {
                                          return 'Mật khẩu phải từ 6 ký tự trở lên';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 35),
                                    LoginButton(
                                      title: 'Sign Up',
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          context.push(AppRouter.login);
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
