import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget.dart';
import '../../data/order_manager.dart';
import 'package:food_app/core/router/app_router.dart';

class OrderTrackingPage extends StatefulWidget {
  final OrderHistoryItem order;

  const OrderTrackingPage({super.key, required this.order});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage>
    with TickerProviderStateMixin {
  late String _currentStatus;
  int _remainingSeconds = 1500; // 25 minutes
  Timer? _countdownTimer;
  Timer? _statusSimulationTimer;

  // Motorbike animation along path
  late AnimationController _driverMovementController;
  late Animation<double> _driverPositionAnimation;

  // Confetti particles for successful delivery
  final List<_ConfettiParticle> _particles = [];
  late AnimationController _confettiController;

  // Sound player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Dynamic status logs calculated based on current status
  List<String> get _statusLogs {
    final logs = <String>[];
    logs.add('Đơn hàng đã được ghi nhận hệ thống.');
    logs.add('Nhà hàng đã nhận đơn và bắt đầu chuẩn bị món.');
    if (_currentStatus == 'Đang giao' || _currentStatus == 'Đã giao') {
      logs.insert(
        0,
        'Tài xế Nguyễn Văn Hùng đã nhận đơn hàng và đang di chuyển.',
      );
    }
    if (_currentStatus == 'Đã giao') {
      logs.insert(0, 'Giao hàng thành công! Hãy thưởng thức món ngon nhé.');
    }
    return logs;
  }

  int getCalculatedRemainingSeconds() {
    final elapsedReal = DateTime.now()
        .difference(widget.order.orderDate)
        .inSeconds;
    if (elapsedReal < 0) return 1500;
    if (elapsedReal < 12) {
      // 12 real seconds to subtract 360 mock seconds (from 1500 down to 1140)
      return 1500 - (elapsedReal * 30);
    } else if (elapsedReal < 28) {
      // 16 real seconds to subtract 1140 mock seconds (from 1140 down to 0)
      final elapsedInStage2 = elapsedReal - 12;
      return 1140 - (elapsedInStage2 * 1140 ~/ 16);
    } else {
      return 0;
    }
  }

  Timer? _backendSyncTimer;

  @override
  void initState() {
    super.initState();

    // Đồng bộ ngay từ Backend API
    OrderManager.instance.fetchOrdersFromBackend();
    _backendSyncTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        OrderManager.instance.fetchOrdersFromBackend();
      }
    });

    // Find initial order state from manager
    final currentOrder = OrderManager.instance.orders.firstWhere(
      (o) => o.orderId == widget.order.orderId,
      orElse: () => widget.order,
    );
    _currentStatus = currentOrder.status;
    _remainingSeconds = getCalculatedRemainingSeconds();

    // Register active order listener
    OrderManager.instance.ordersNotifier.addListener(_onOrdersChanged);

    // 1. Countdown timer updates remaining seconds reactively every second
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds = getCalculatedRemainingSeconds();
        });
      }
    });

    // 2. Motorbike driver position animation
    _driverMovementController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
    _driverPositionAnimation = Tween<double>(begin: 0.05, end: 0.9).animate(
      CurvedAnimation(
        parent: _driverMovementController,
        curve: Curves.easeInOut,
      ),
    );

    // 3. Confetti controller
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Initialize animation state based on current status
    if (_currentStatus == 'Đang giao') {
      final elapsedReal = DateTime.now()
          .difference(widget.order.orderDate)
          .inSeconds;
      final elapsedInStage2 = elapsedReal - 12;
      final double initialProgress = elapsedInStage2 > 0
          ? (elapsedInStage2 / 16.0)
          : 0.05;
      _driverMovementController.value = initialProgress.clamp(0.05, 0.9);
      _driverMovementController.forward();
    } else if (_currentStatus == 'Đã giao') {
      _driverMovementController.value = 1.0;
      _generateConfetti();
      _confettiController.repeat();
    }
  }

  @override
  void dispose() {
    _backendSyncTimer?.cancel();
    OrderManager.instance.ordersNotifier.removeListener(_onOrdersChanged);
    _countdownTimer?.cancel();
    _driverMovementController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onOrdersChanged() {
    if (!mounted) return;

    final updatedOrder = OrderManager.instance.orders.firstWhere(
      (o) => o.orderId == widget.order.orderId,
      orElse: () => widget.order,
    );

    if (updatedOrder.status != _currentStatus) {
      final oldStatus = _currentStatus;
      setState(() {
        _currentStatus = updatedOrder.status;
      });

      if (_currentStatus == 'Đang giao' && oldStatus == 'Đang chuẩn bị') {
        _driverMovementController.reset();
        _driverMovementController.forward();
        _playSystemSound();
        HapticFeedback.mediumImpact();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '🏍️ Tài xế Nguyễn Văn Hùng đã nhận đơn và đang giao!',
            ),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
      } else if (_currentStatus == 'Đã giao') {
        _driverMovementController.value = 1.0;
        _generateConfetti();
        _confettiController.repeat();
        _playSuccessSound();
        HapticFeedback.vibrate();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '🎉 Đơn hàng đã được giao thành công! Chúc bạn ngon miệng!',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _playSystemSound() {
    try {
      _audioPlayer.play(AssetSource('audio/kaching.mp3'));
    } catch (_) {}
  }

  void _playSuccessSound() {
    try {
      _audioPlayer.play(AssetSource('audio/kaching.mp3'));
    } catch (_) {}
  }

  void _generateConfetti() {
    final random = math.Random();
    _particles.clear();
    final List<String> summerEmojis = [
      '🍉',
      '🍦',
      '☀️',
      '🍋',
      '🌴',
      '🌸',
      '🍍',
    ];

    for (int i = 0; i < 40; i++) {
      _particles.add(
        _ConfettiParticle(
          x: random.nextDouble() * 400,
          y: -random.nextDouble() * 200,
          emoji: summerEmojis[random.nextInt(summerEmojis.length)],
          speedY: 2 + random.nextDouble() * 4,
          speedX: -1.5 + random.nextDouble() * 3,
          rotation: random.nextDouble() * math.pi * 2,
          rotationSpeed: -0.05 + random.nextDouble() * 0.1,
          size: 14 + random.nextDouble() * 12,
        ),
      );
    }
  }

  String _formatTimer(int seconds) {
    if (seconds <= 0) return '00:00';
    final int min = seconds ~/ 60;
    final int sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  void _showCallOverlay() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue,
              child: Text('👨🏻', style: TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tài xế Nguyễn Văn Hùng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Đang kết nối cuộc gọi thoại...',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () => context.pop(),
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.call_end, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = _currentStatus == 'Đã giao'
        ? Colors.green
        : _currentStatus == 'Đang giao'
        ? Colors.blue
        : Colors.amber.shade700;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          BackgroundContainer(
            opacity: 0.15,
            child: SafeArea(
              child: Column(
                children: [
                  // Custom AppBar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(right: 16),
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
                            const Text(
                              'Theo dõi đơn hàng',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        // Pulsing status dot
                        _buildPulsingStatusDot(statusColor),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      children: [
                        // Card 1: Estimated Delivery Time count down
                        _buildTimerCard(statusColor),
                        const SizedBox(height: 16),

                        // Card 2: Interactive animated minimal map
                        _buildMapCard(statusColor),
                        const SizedBox(height: 16),

                        // Card 3: Driver Details Info
                        _buildDriverCard(),
                        const SizedBox(height: 16),

                        // Card 4: Detailed Live Order Status log list
                        _buildLogsCard(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confetti particles overlay
          if (_currentStatus == 'Đã giao')
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _confettiController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ConfettiPainter(particles: _particles),
                    child: Container(),
                  );
                },
              ),
            ),

          // Bottom back home bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomActionBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingStatusDot(Color statusColor) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _buildTimerCard(Color statusColor) {
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
          Text(
            _currentStatus == 'Đã giao'
                ? 'ĐƠN HÀNG ĐÃ ĐƯỢC GIAO THÀNH CÔNG!'
                : 'THỜI GIAN GIAO HÀNG DỰ KIẾN',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentStatus == 'Đã giao'
                ? 'Chúc bạn ngon miệng! 🍉'
                : _formatTimer(_remainingSeconds),
            style: TextStyle(
              fontSize: _currentStatus == 'Đã giao' ? 22 : 40,
              fontWeight: FontWeight.w900,
              color: statusColor,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Tình trạng: $_currentStatus',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '• Mã đơn: ${widget.order.orderId}',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard(Color statusColor) {
    return Container(
      height: 200,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);

            // Normalized path points (0.0 to 1.0)
            final List<Offset> points = const [
              Offset(0.15, 0.72),
              Offset(0.32, 0.38),
              Offset(0.48, 0.58),
              Offset(0.68, 0.32),
              Offset(0.85, 0.52),
            ];

            Offset getPositionOnPath(double t) {
              if (t <= 0)
                return Offset(
                  points.first.dx * size.width,
                  points.first.dy * size.height,
                );
              if (t >= 1)
                return Offset(
                  points.last.dx * size.width,
                  points.last.dy * size.height,
                );

              double segmentLength = 1.0 / (points.length - 1);
              int index = (t / segmentLength).floor();
              if (index >= points.length - 1) {
                return Offset(
                  points.last.dx * size.width,
                  points.last.dy * size.height,
                );
              }

              double localT = (t - index * segmentLength) / segmentLength;
              Offset p0 = points[index];
              Offset p1 = points[index + 1];

              double x = p0.dx + (p1.dx - p0.dx) * localT;
              double y = p0.dy + (p1.dy - p0.dy) * localT;

              return Offset(x * size.width, y * size.height);
            }

            double getAngleOnPath(double t) {
              if (t >= 0.98) t = 0.98;
              Offset pos1 = getPositionOnPath(t);
              Offset pos2 = getPositionOnPath(t + 0.02);
              return math.atan2(pos2.dy - pos1.dy, pos2.dx - pos1.dx);
            }

            return Stack(
              children: [
                // Real Clean Voyager Street Map Tile Background (Hanoi Region)
                Image.network(
                  'https://basemaps.cartocdn.com/rastertiles/voyager/15/25996/14197.png',
                  headers: const {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'},
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: const Color(0xFFE8F5E9),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.teal),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/15/14197/25996',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFE8F5E9),
                        child: const Center(
                          child: Icon(
                            Icons.map_outlined,
                            color: Colors.teal,
                            size: 40,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Real Location Badge Tag
                Positioned(
                  top: 10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.my_location_rounded, color: Colors.lightGreenAccent, size: 14),
                        SizedBox(width: 6),
                        Text(
                          '🗺️ Bản đồ thực tế: Yên Xá, Thanh Trì, Hà Nội',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Subtle transparent overlay for map branding blending
                Container(color: Colors.white.withOpacity(0.12)),

                // GPS Route Line Painter
                CustomPaint(
                  size: size,
                  painter: _RoutePainter(
                    points: points,
                    routeColor: statusColor,
                    progress: _currentStatus == 'Đang chuẩn bị'
                        ? 0.0
                        : _driverPositionAnimation.value,
                  ),
                ),

                // Restaurant Pin
                Positioned(
                  left: points.first.dx * size.width - 20,
                  top: points.first.dy * size.height - 40,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.store_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Nhà hàng',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // User Home Pin
                Positioned(
                  left: points.last.dx * size.width - 20,
                  top: points.last.dy * size.height - 40,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryRed,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Bạn',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Driver motorcycle moving along path with dynamic rotation
                AnimatedBuilder(
                  animation: _driverPositionAnimation,
                  builder: (context, child) {
                    double t = _currentStatus == 'Đang chuẩn bị'
                        ? 0.0
                        : _driverPositionAnimation.value;
                    Offset pos = getPositionOnPath(t);
                    double angle = getAngleOnPath(t);

                    return Positioned(
                      left: pos.dx - 18,
                      top: pos.dy - 18,
                      child: Transform.rotate(
                        angle: angle,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            '🏍️',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDriverCard() {
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
            children: [
              // Mock driver avatar
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFFFCC80),
                child: Text('👨🏻', style: TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Nguyễn Văn Hùng',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.star, color: Colors.amber, size: 10),
                              SizedBox(width: 2),
                              Text(
                                '4.9',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tài xế công nghệ • Honda Wave • 29V1-678.90',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5, color: Colors.black12),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.08),
                    foregroundColor: Colors.blue.shade700,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(0, 40),
                  ),
                  onPressed: _showCallOverlay,
                  icon: const Icon(Icons.call_rounded, size: 16),
                  label: const Text(
                    'Gọi điện',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed.withOpacity(0.08),
                    foregroundColor: AppColors.primaryRed,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(0, 40),
                  ),
                  onPressed: () {
                    context.push(AppRouter.driverChatDetail);
                  },
                  icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                  label: const Text(
                    'Nhắn tin',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogsCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.checklist_rounded, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Nhật ký hành trình',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Column(
            children: List.generate(_statusLogs.length, (index) {
              final log = _statusLogs[index];
              final isLatest = index == 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: isLatest
                                ? Colors.green
                                : Colors.grey.shade300,
                            shape: BoxShape.circle,
                            boxShadow: isLatest
                                ? [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.4),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                        if (index < _statusLogs.length - 1)
                          Container(
                            width: 1.5,
                            height: 24,
                            color: Colors.grey.shade200,
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        log,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isLatest
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isLatest
                              ? Colors.black87
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92), // Glassmorphism layout
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Container(
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
        child: ElevatedButton(
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
            context.go(AppRouter.taskbar);
          },
          child: const Text(
            'Quay lại Trang chủ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  final List<Offset> points;
  final Color routeColor;
  final double progress;

  _RoutePainter({
    required this.points,
    required this.routeColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    // Draw the background route path (semi-transparent grey)
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final bgPath = Path();
    bgPath.moveTo(points[0].dx * size.width, points[0].dy * size.height);
    for (int i = 1; i < points.length; i++) {
      bgPath.lineTo(points[i].dx * size.width, points[i].dy * size.height);
    }
    canvas.drawPath(bgPath, bgPaint);

    // Draw the active completed route path (solid color)
    if (progress > 0) {
      final activePaint = Paint()
        ..color = routeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;

      final activePath = Path();
      activePath.moveTo(points[0].dx * size.width, points[0].dy * size.height);

      for (double t = 0.0; t <= progress; t += 0.01) {
        Offset pos = _getPosition(t, size);
        activePath.lineTo(pos.dx, pos.dy);
      }
      Offset finalPos = _getPosition(progress, size);
      activePath.lineTo(finalPos.dx, finalPos.dy);

      canvas.drawPath(activePath, activePaint);
    }
  }

  Offset _getPosition(double t, Size size) {
    double segmentLength = 1.0 / (points.length - 1);
    int index = (t / segmentLength).floor();
    if (index >= points.length - 1) {
      return Offset(points.last.dx * size.width, points.last.dy * size.height);
    }
    double localT = (t - index * segmentLength) / segmentLength;
    Offset p0 = points[index];
    Offset p1 = points[index + 1];
    return Offset(
      (p0.dx + (p1.dx - p0.dx) * localT) * size.width,
      (p0.dy + (p1.dy - p0.dy) * localT) * size.height,
    );
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.routeColor != routeColor;
  }
}

class _ConfettiParticle {
  double x;
  double y;
  final String emoji;
  final double speedY;
  final double speedX;
  double rotation;
  final double rotationSpeed;
  final double size;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.emoji,
    required this.speedY,
    required this.speedX,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
  });

  void update() {
    y += speedY;
    x += speedX;
    rotation += rotationSpeed;
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;

  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var p in particles) {
      // Update particle positions
      p.update();

      // If particle falls off the screen, reset to top
      if (p.y > size.height) {
        p.y = -20;
        p.x = math.Random().nextDouble() * size.width;
      }

      canvas.save();
      // Translate to particle center and rotate
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      textPainter.text = TextSpan(
        text: p.emoji,
        style: TextStyle(fontSize: p.size),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-p.size / 2, -p.size / 2));

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
