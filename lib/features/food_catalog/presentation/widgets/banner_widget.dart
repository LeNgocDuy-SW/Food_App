import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:food_app/core/constants/app_colors.dart';

class SummerSunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width * 0.35;

    final sunPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, sunPaint);

    final rayPaint = Paint()
      ..color = const Color(0xFFFFCA28).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      double angle = i * math.pi / 4;
      double startX = center.dx + (radius + 6) * math.cos(angle);
      double startY = center.dy + (radius + 6) * math.sin(angle);
      double endX = center.dx + (radius + 16) * math.cos(angle);
      double endY = center.dy + (radius + 16) * math.sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SwimRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;
    final strokeWidth = size.width * 0.22;

    // 1. Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(center + const Offset(2, 4), radius, shadowPaint);

    // 2. Base white ring
    final basePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, basePaint);

    // 3. Summer red stripes
    final stripePaint = Paint()
      ..color = const Color(0xFFFF5252)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final double sweep = math.pi / 4;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 8,
      sweep,
      false,
      stripePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3 * math.pi / 8,
      sweep,
      false,
      stripePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      7 * math.pi / 8,
      sweep,
      false,
      stripePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      11 * math.pi / 8,
      sweep,
      false,
      stripePaint,
    );

    // 4. Yellow safety rope
    final ropePaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(center, radius + strokeWidth / 2 + 1.5, ropePaint);

    // 5. Glossy highlight
    final glossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 2),
      1.2 * math.pi,
      0.35 * math.pi,
      false,
      glossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StarfishPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFFFF8A65)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final double radiusOuter = size.width * 0.45;
    final double radiusInner = size.width * 0.18;

    for (int i = 0; i < 5; i++) {
      double angleOuter = i * 2 * math.pi / 5 - math.pi / 2;
      double angleInner = (i + 0.5) * 2 * math.pi / 5 - math.pi / 2;

      if (i == 0) {
        path.moveTo(
          center.dx + radiusOuter * math.cos(angleOuter),
          center.dy + radiusOuter * math.sin(angleOuter),
        );
      } else {
        path.lineTo(
          center.dx + radiusOuter * math.cos(angleOuter),
          center.dy + radiusOuter * math.sin(angleOuter),
        );
      }
      path.lineTo(
        center.dx + radiusInner * math.cos(angleInner),
        center.dy + radiusInner * math.sin(angleInner),
      );
    }
    path.close();

    canvas.drawPath(path.shift(const Offset(1.5, 2.5)), shadowPaint);
    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 1.8, dotPaint);
    for (int i = 0; i < 5; i++) {
      double angle = i * 2 * math.pi / 5 - math.pi / 2;
      canvas.drawCircle(
        Offset(
          center.dx + radiusInner * 1.1 * math.cos(angle),
          center.dy + radiusInner * 1.1 * math.sin(angle),
        ),
        1.2,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  final List<Map<String, dynamic>> _bannerData = [
    {
      'title1': 'Giải nhiệt mùa hè\nGiảm ngay ',
      'titleHighlight': '30%',
      'title2': ' Kem & Trà sữa!',
      'image': 'assets/image/cooking_burger.png',
      'gradient': const LinearGradient(
        colors: [Color(0xFF00B0FF), Color(0xFF00E5FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'textColor': Colors.white,
      'highlightColor': Color(0xFFFFD54F),
    },
    {
      'title1': 'Khuyến mãi hè sang\nĐồng giá ',
      'titleHighlight': '25K',
      'title2': ' toàn menu!',
      'image': 'assets/image/food_banner.png',
      'gradient': const LinearGradient(
        colors: [Color(0xFFFFB300), Color(0xFFFFE082)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'textColor': Color(0xFF37474F),
      'highlightColor': Color(0xFFD84315),
    },
    {
      'title1': 'Hải sản tươi mát\nGiao nhanh ',
      'titleHighlight': '15 Phút',
      'title2': '!',
      'image': 'assets/image/banner.png',
      'gradient': const LinearGradient(
        colors: [Color(0xFFFF5722), Color(0xFFFF8A65)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'textColor': Colors.white,
      'highlightColor': Color(0xFFFFD54F),
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _bannerData.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 155,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _bannerData.length,
              itemBuilder: (context, index) {
                final item = _bannerData[index];
                return Container(
                  decoration: BoxDecoration(
                    gradient: item['gradient'] as Gradient,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: item['textColor'] as Color,
                                  height: 1.3,
                                ),
                                children: [
                                  TextSpan(text: item['title1']),
                                  TextSpan(
                                    text: item['titleHighlight'],
                                    style: TextStyle(
                                      color: item['highlightColor'] as Color,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(text: item['title2']),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 6,
                                ),
                                backgroundColor: AppColors.primaryRed,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Mua Ngay',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Image.asset(
                        item['image'],
                        height: 217,
                        width: 155,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                );
              },
            ),
            // Floating Summer Sun decoration (Top Right)
            Positioned(
              right: -15,
              top: -15,
              child: IgnorePointer(
                child: CustomPaint(
                  size: const Size(75, 75),
                  painter: SummerSunPainter(),
                ),
              ),
            ),
            // Floating Swim Ring decoration (Bottom/Center overlap)
            Positioned(
              right: 120,
              bottom: -15,
              child: IgnorePointer(
                child: CustomPaint(
                  size: const Size(65, 65),
                  painter: SwimRingPainter(),
                ),
              ),
            ),
            // Floating Starfish decoration (Top Left)
            Positioned(
              left: -10,
              top: -10,
              child: IgnorePointer(
                child: CustomPaint(
                  size: const Size(45, 45),
                  painter: StarfishPainter(),
                ),
              ),
            ),
            // Indicator dots
            Positioned(
              bottom: 12,
              left: 24,
              child: Row(
                children: List.generate(_bannerData.length, (index) {
                  final isActive = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 6),
                    height: 6,
                    width: isActive ? 18 : 6,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primaryRed : Colors.white60,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
