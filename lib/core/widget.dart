import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;
  final double opacity;
  const BackgroundContainer({
    super.key,
    required this.child,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(
          0xFFFAFAFA,
        ), // Nền trắng ngà mang lại cảm giác sạch sẽ, cao cấp
      ),
      child: Stack(
        children: [
          // Vệt sáng mờ màu cam (Primary) ở góc trên phải
          Positioned(
            top: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFF5722).withOpacity(0.07),
                    const Color(0xFFFF5722).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Vệt sáng mờ màu đỏ ở góc dưới trái
          Positioned(
            bottom: -100,
            left: -150,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF22323).withOpacity(0.05),
                    const Color(0xFFF22323).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Nội dung chính
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

Route createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOutCubic;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(opacity: animation, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
