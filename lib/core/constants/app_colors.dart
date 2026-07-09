import 'package:flutter/material.dart';

// Mã màu opacity cho màu đen
//100% = FF | 90% = E6 | 80% = CC | 70% = B3
//60% = 99 | 50% = 80 | 40% = 66 | 30% = 4D
class AppColors {
  AppColors._();
  static const Color primary = Color(0xFFFF5722);
  static const Color white = Colors.white; // Màu cho Text
  static const Color primaryRed = Color(0xFFF22323); // Màu cho nút Bấm
  static const Color black = Color(0xFF000000); // Màu cho các ô TextField
  static const Color blueLight = Color(0xFF07A7F8); // Màu cho Signin
  static const Color blackWithOpacity60 = Color(
    0x99000000,
  ); // Màu đen có độ mờ 60%
}
