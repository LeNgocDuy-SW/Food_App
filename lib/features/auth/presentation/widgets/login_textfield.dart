import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class LoginTextField extends StatefulWidget {
  final TextEditingController phoneController;
  final TextEditingController passwordController;

  const LoginTextField({
    super.key,
    required this.phoneController,
    required this.passwordController,
  });

  @override
  State<LoginTextField> createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Ô nhập Email hoặc Số điện thoại
        TextFormField(
          controller: widget.phoneController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(
            fontSize: AppSizes.TextSize16,
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập email hoặc số điện thoại';
            }
            final cleanValue = value.trim();
            final emailRegex = RegExp(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            );
            final phoneRegex = RegExp(r'^[0-9]{9,11}$');

            if (!emailRegex.hasMatch(cleanValue) &&
                !phoneRegex.hasMatch(cleanValue)) {
              return 'Vui lòng nhập đúng định dạng email hoặc số điện thoại';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Email hoặc Số điện thoại',
            filled: true,
            fillColor: AppColors.white,
            errorStyle: const TextStyle(
              color: Colors.yellowAccent,
              fontWeight: FontWeight.bold,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 20, right: 12),
              child: Icon(Icons.person_outline, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // 2. Ô nhập Mật khẩu
        TextFormField(
          controller: widget.passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập mật khẩu';
            }
            if (value.length < 6) {
              return 'Mật khẩu phải từ 6 ký tự trở lên';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Password',
            filled: true,
            fillColor: AppColors.white,
            errorStyle: const TextStyle(
              color: Colors.yellowAccent,
              fontWeight: FontWeight.bold,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 20, right: 12),
              child: Icon(Icons.lock_outline, color: Colors.grey),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        key: ValueKey<bool>(_obscurePassword),
                        color: Colors.grey,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
