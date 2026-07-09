import 'package:flutter/material.dart';
import 'package:food_app/core/constants/app_colors.dart';

class SignUpTextField extends StatefulWidget {
  final String hintText;
  final bool isPassword;

  const SignUpTextField({
    super.key,
    required this.hintText,
    this.isPassword = false,
  });

  @override
  State<SignUpTextField> createState() => _SignUpTextFieldState();
}

class _SignUpTextFieldState extends State<SignUpTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: widget.isPassword ? _obscureText : false,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        border: UnderlineInputBorder(borderRadius: BorderRadius.circular(20)),
        suffixIcon: widget.isPassword
            ? Padding(
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
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          key: ValueKey<bool>(_obscureText),
                          color: Colors.grey,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}
