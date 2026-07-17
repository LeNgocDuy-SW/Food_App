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
        TextFormField(
          controller: widget.phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(
            fontSize: AppSizes.TextSize16,
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập số điện thoại';
            }
            final cleanValue = value.trim();
            final phoneRegex = RegExp(r'^[0-9]{9,10}$');
            if (!phoneRegex.hasMatch(cleanValue)) {
              return 'Số điện thoại không hợp lệ (9-10 chữ số)';
            }
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            errorStyle: const TextStyle(
              color: Colors.yellowAccent,
              fontWeight: FontWeight.bold,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 24, right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '+84',
                    style: TextStyle(
                      fontSize: AppSizes.TextSize16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 2,
                    height: 28,
                    color: const Color(0xFFD9D9D9),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
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
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 24, right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [const Icon(Icons.lock_outline)],
              ),
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
