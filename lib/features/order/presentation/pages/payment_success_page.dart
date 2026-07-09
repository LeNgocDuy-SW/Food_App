import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget.dart';
import '../../data/order_manager.dart';
import 'order_tracking_page.dart';

class PaymentSuccessPage extends StatefulWidget {
  final int totalPrice;
  final String paymentMethod;
  final String orderId;

  const PaymentSuccessPage({
    super.key,
    required this.totalPrice,
    required this.paymentMethod,
    required this.orderId,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late List<ConfettiParticle> _particles;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(40, (index) => ConfettiParticle());
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Rung phản hồi và phát âm thanh khi giao dịch thành công
    _triggerSuccessFeedback();
  }

  Future<void> _triggerSuccessFeedback() async {
    // Phát âm thanh tiền xu rơi "Kaching"
    try {
      await _audioPlayer.play(AssetSource('audio/kaching.mp3'));
    } catch (e) {
      debugPrint("Lỗi phát âm thanh: $e");
    }

    // Rung đúp phản hồi xúc giác
    await HapticFeedback.vibrate();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.vibrate();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'BANK':
        return 'Ngân hàng (Banking)';
      case 'MOMO':
        return 'Ví MoMo';
      case 'COD':
      default:
        return 'Tiền mặt (COD)';
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'BANK':
        return Icons.account_balance_rounded;
      case 'MOMO':
        return Icons.wallet_rounded;
      case 'COD':
      default:
        return Icons.payments_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: BackgroundContainer(
        opacity: 0.15,
        child: Stack(
          children: [
            // Lớp vẽ Pháo hoa giấy (Confetti) lấp lánh rơi xuống
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return CustomPaint(
                  size: screenSize,
                  painter: ConfettiPainter(_particles),
                );
              },
            ),

            // Nội dung chính
            SafeArea(
              child: Column(
                children: [
                  // Custom AppBar
                  _buildAppBar(context),

                  // Detail Success Card
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      children: [
                        const SizedBox(height: 10),

                        // Hiệu ứng checkmark chuyển động nổi bật
                        const SuccessCheckmarkAnimation(),

                        const SizedBox(height: 24),
                        const Text(
                          'Thanh toán thành công!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.green,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Đơn hàng của bạn đã được tiếp nhận và xử lý.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Box 1: Số tiền thanh toán
                        _buildAmountPaidBox(),
                        const SizedBox(height: 16),

                        // Box 2: Thông tin mã đơn hàng
                        _buildOrderDetailsBox(),
                        const SizedBox(height: 24),

                        // Box 3: Trạng thái nấu ăn (progress bar)
                        _buildPreparingCard(),
                        const SizedBox(height: 32),

                        // Bottom Actions
                        _buildActionButtons(context),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Kết quả giao dịch',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountPaidBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.06), width: 1),
      ),
      child: Column(
        children: [
          const Text(
            'SỐ TIỀN ĐÃ THANH TOÁN',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _formatPrice(widget.totalPrice),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryRed,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.5, color: Colors.black12),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Phương thức',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Icon(
                    _getPaymentMethodIcon(widget.paymentMethod),
                    color: Colors.black54,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getPaymentMethodText(widget.paymentMethod),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.06), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mã đơn hàng',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                widget.orderId,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Thời gian đặt',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Vừa xong, Hôm nay',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreparingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.06), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('🍳', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Món ngon đang được chuẩn bị',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Tiến độ chuẩn bị
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Đang nấu món ăn... Dự kiến giao: 25 phút',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/image/cooking_burger.png',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Theo dõi đơn hàng với Sunset Orange Gradient
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF5722), // Summer Orange
                Color(0xFFF22323), // Primary Red
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryRed.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            onPressed: () {
              final orderItem = OrderManager.instance.orders.firstWhere(
                (element) => element.orderId == widget.orderId,
                orElse: () => OrderHistoryItem(
                  orderId: widget.orderId,
                  orderDate: DateTime.now(),
                  items: const [],
                  totalPrice: widget.totalPrice,
                  paymentMethod: widget.paymentMethod,
                  address: '',
                ),
              );
              Navigator.push(
                context,
                createRoute(OrderTrackingPage(order: orderItem)),
              );
            },
            icon: const Icon(
              Icons.location_on_rounded,
              color: Colors.white,
              size: 20,
            ),
            label: const Text(
              'Theo dõi đơn hàng',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Outlined Back to Home Button
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.primaryRed, width: 1.5),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 0,
          ),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: const Text(
            'Quay lại Trang chủ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryRed,
            ),
          ),
        ),
      ],
    );
  }
}

// Lớp vẽ Hiệu ứng checkmark động với 2 vòng lan tỏa (Ripple)
class SuccessCheckmarkAnimation extends StatefulWidget {
  const SuccessCheckmarkAnimation({super.key});

  @override
  State<SuccessCheckmarkAnimation> createState() =>
      _SuccessCheckmarkAnimationState();
}

class _SuccessCheckmarkAnimationState extends State<SuccessCheckmarkAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _scaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.0, end: 1.25),
            weight: 60,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.25, end: 0.9),
            weight: 20,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.9, end: 1.0),
            weight: 20,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
          ),
        );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ripple 1
              Transform.scale(
                scale: 1.0 + _rippleAnimation.value * 0.5,
                child: Opacity(
                  opacity: (1.0 - _rippleAnimation.value) * 0.4,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green, width: 4),
                    ),
                  ),
                ),
              ),
              // Ripple 2
              Transform.scale(
                scale: 1.0 + _rippleAnimation.value * 0.8,
                child: Opacity(
                  opacity: (1.0 - _rippleAnimation.value) * 0.2,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                  ),
                ),
              ),
              // Checkmark Circle Icon
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Custom Painter cho pháo hoa giấy rơi tự do
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      p.update(size);

      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.width / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.width,
            height: p.height,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Thực thể hạt Pháo hoa giấy
class ConfettiParticle {
  late double x;
  late double y;
  late double speedY;
  late double speedX;
  late double rotation;
  late double rotationSpeed;
  late Color color;
  late bool isCircle;
  late double width;
  late double height;

  static const colors = [
    Colors.redAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
    Colors.amberAccent,
    Colors.cyanAccent,
  ];

  ConfettiParticle() {
    reset(isInitial: true);
  }

  void reset({bool isInitial = false}) {
    final random = math.Random();
    x = random.nextDouble(); // Tỷ lệ chiều rộng
    y = isInitial
        ? (-random.nextDouble() * 300)
        : -20; // Rải rác lúc đầu hoặc xuất phát từ trên
    speedY = 120 + random.nextDouble() * 150; // Tốc độ rơi Y
    speedX = -40 + random.nextDouble() * 80; // Lắc lư nhẹ X
    rotation = random.nextDouble() * math.pi * 2;
    rotationSpeed = -3 + random.nextDouble() * 6;
    color = colors[random.nextInt(colors.length)];
    isCircle = random.nextBool();
    width = 6 + random.nextDouble() * 8;
    height = 10 + random.nextDouble() * 8;
  }

  void update(Size sizeBound) {
    y += speedY * 0.016; // Tương đương ~60fps step
    x += speedX * 0.016;
    rotation += rotationSpeed * 0.016;

    // Nếu rơi quá đáy màn hình -> reset bay lại từ đỉnh
    if (y > sizeBound.height) {
      reset(isInitial: false);
      x = math.Random().nextDouble() * sizeBound.width;
    }

    // Tự động cuốn lại từ cạnh trái/phải nếu trôi đi quá xa
    if (x < 0) x = sizeBound.width;
    if (x > sizeBound.width) x = 0;
  }
}
