import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:flutter/services.dart';

class ConfirmPin extends StatelessWidget {
  final List<TextEditingController> controllers;
  const ConfirmPin({super.key, required this.controllers});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          controllers.length,
          (index) => ContainerConfirm(
            child: TextField(
              controller: controllers[index],
              onChanged: (value) {
                if (value.length == 1 && index < controllers.length - 1) {
                  FocusScope.of(context).nextFocus();
                }
                if (value.isEmpty && index > 0) {
                  FocusScope.of(context).previousFocus();
                }
              },
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
              ),
            ),
          ),
        ),
        // children: [
        //   ContainerConfirm(),
        //   SizedBox(width: 34),
        //   ContainerConfirm(),
        //   SizedBox(width: 34),
        //   ContainerConfirm(),
        //   SizedBox(width: 34),
        //   ContainerConfirm(),
        // ],
      ),
    );
  }
}

class ContainerConfirm extends StatelessWidget {
  final Widget child;
  const ContainerConfirm({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.white,
      ),
      child: child,
    );
  }
}
