import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class LoginTextField extends StatefulWidget {
  const LoginTextField({super.key});

  @override
  State<LoginTextField> createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.phone,
            style: TextStyle(
              fontSize: AppSizes.TextSize16,
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
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
                    Container(width: 2, height: 28, color: Color(0xFFD9D9D9)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          TextField(
            obscureText: _obscurePassword,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'Password',
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
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
      ),
    );
  }
}
