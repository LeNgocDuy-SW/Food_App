import 'package:flutter/material.dart';
import 'package:food_app/features/auth/presentation/widgets/login_with.dart';
import '../../../../core/widget.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/summer_animated_background.dart';
import '../widgets/sign_up_textfield.dart';
import '../widgets/login_button.dart';
import 'login_page.dart';
import '../widgets/confirm_pin.dart';
import 'change_password.dart';

class ConfirmPassWordPage extends StatefulWidget {
  const ConfirmPassWordPage({super.key});

  @override
  State<ConfirmPassWordPage> createState() => _ConfirmPassWordPageState();
}

class _ConfirmPassWordPageState extends State<ConfirmPassWordPage> {
  final List<TextEditingController> _pinController = List.generate(
    4,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (var controller in _pinController) {
      controller.dispose();
    }
    super.dispose();
  }

  String getFullPin() {
    return _pinController.map((c) => c.text).join();
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
                                    'Forgot Password',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Enter the pin code sent to your mobile phone',
                                          style: TextStyle(
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
                                  LoginButton(
                                    title: 'Confirm',
                                    onPressed: () {
                                      String pin = getFullPin();
                                      print(pin);
                                      Navigator.push(
                                        context,
                                        createRoute(const ChangePasswordPage()),
                                      );
                                    },
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
