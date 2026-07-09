import 'dart:math' as math;
import 'package:flutter/material.dart';

class SummerAnimatedBackground extends StatefulWidget {
  final Widget child;
  const SummerAnimatedBackground({super.key, required this.child});

  @override
  State<SummerAnimatedBackground> createState() => _SummerAnimatedBackgroundState();
}

class _SummerAnimatedBackgroundState extends State<SummerAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<SummerFoodParticle> _particles;

  @override
  void initState() {
    super.initState();
    // Tạo 12 hạt đồ ăn mùa hè bay lơ lửng
    _particles = List.generate(12, (index) => SummerFoodParticle());
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Cập nhật tọa độ hạt dựa theo kích thước màn hình
        for (var particle in _particles) {
          particle.update(screenSize);
        }

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFFF0785A), // Màu cam hoàng hôn đậm đà hơn
                Color(0xFFFDB07E), // Màu đào ấm áp
              ],
            ),
          ),
          child: Stack(
            children: [
              // Vầng sáng mặt trời lớn ở góc trên trái tạo chiều sâu
              Positioned(
                top: -150,
                left: -150,
                child: Container(
                  width: 450,
                  height: 450,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.18),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Vẽ các icon đồ ăn mùa hè chuyển động động sinh động
              ..._particles.map((p) {
                return Positioned(
                  left: p.x,
                  top: p.y,
                  child: Transform.rotate(
                    angle: p.rotation,
                    child: Opacity(
                      opacity: p.opacity,
                      child: Text(
                        p.emoji,
                        style: TextStyle(
                          fontSize: p.size,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              
              // Nội dung chính
              Positioned.fill(child: widget.child),
            ],
          ),
        );
      },
    );
  }
}

class SummerFoodParticle {
  // Danh sách các icon đồ ăn, thức uống đặc trưng của mùa hè
  static const List<String> _summerFoodEmojis = [
    '🍉', // Dưa hấu giải nhiệt
    '🍦', // Kem mát lạnh
    '🍹', // Cocktail trái cây
    '🥥', // Quả dừa tươi
    '🍋', // Quả chanh vàng
    '🍍', // Quả dứa chín
    '🍧', // Bingsu đá bào
    '🥤', // Nước ngọt có ga
    '🍓', // Dâu tây
    '🍊', // Cam ngọt
  ];

  late String emoji;
  late double basePercentY;
  late double basePercentX;
  late double speed;
  late double size;
  late double opacity;
  late double swingWidth;
  late double swingSpeed;
  late double rotationSpeed;

  double x = 0;
  double y = 0;
  double rotation = 0;

  SummerFoodParticle() {
    reset(isInitial: true);
  }

  void reset({bool isInitial = false}) {
    final random = math.Random();
    emoji = _summerFoodEmojis[random.nextInt(_summerFoodEmojis.length)];
    basePercentY = isInitial ? random.nextDouble() : 1.1; 
    basePercentX = random.nextDouble();
    speed = 0.0003 + random.nextDouble() * 0.0007; // Bay lên siêu chậm rãi để dễ nhìn
    size = 28 + random.nextDouble() * 22;         // Kích thước rõ ràng hơn (28px - 50px)
    opacity = 0.12 + random.nextDouble() * 0.15;   // Rõ nét hơn nhưng vẫn giữ tính thẩm mỹ (12% - 27%)
    swingWidth = 12 + random.nextDouble() * 20;    // Đung đưa nhẹ
    swingSpeed = 0.6 + random.nextDouble() * 1.2;
    rotationSpeed = (random.nextBool() ? 1 : -1) * (0.005 + random.nextDouble() * 0.015);
  }

  void update(Size screenSize) {
    basePercentY -= speed; // Bay lên
    if (basePercentY < -0.1) {
      reset(isInitial: false); // Đã bay qua đỉnh màn hình -> reset
    }
    
    y = basePercentY * screenSize.height;
    
    // Đung đưa hình sin
    final double swing = math.sin(basePercentY * math.pi * 2 * swingSpeed) * swingWidth;
    x = (basePercentX * screenSize.width) + swing;
    
    // Tự động xoay tròn nhẹ
    rotation += rotationSpeed;
  }
}
