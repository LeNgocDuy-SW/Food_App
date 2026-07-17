import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widget.dart';
import '../../../food_catalog/presentation/widgets/food_card_widget.dart';
import '../../../order/data/order_manager.dart';
import 'package:food_app/core/router/app_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Crisp clean gray-white background
      body: BackgroundContainer(
        opacity: 0.08,
        child: Column(
          children: [
            // Premium Sunset Header Block
            _buildHeader(context),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Đơn hàng của bạn Card
                    _buildOrderSection(context),
                    const SizedBox(height: 20),
                    
                    // Tiện ích của tôi Card
                    _buildUtilitySection(),
                    const SizedBox(height: 20),
                    
                    // Hỗ trợ Card
                    _buildSupportSection(),
                    const SizedBox(height: 28),
                    
                    // Gợi ý dành cho bạn Section
                    _buildSectionHeader('Gợi ý hôm nay 🍉'),
                    const SizedBox(height: 16),
                    
                    // Food Cards row
                    _buildFoodCardsGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF8A65), // Warm Sunset Orange
            Color(0xFFFF5722), // Coral Sunset Red
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF5722),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, statusBarHeight + 16, 20, 24),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/image/avatar.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              
              // Name & Member status tag
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    const Text(
                      'lengocduy25',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Thành viên Vàng 🌟',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Top Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeaderIconButton(
                    context,
                    Icons.settings_rounded,
                    () => context.push(AppRouter.settings),
                  ),
                  const SizedBox(width: 8),
                  _buildHeaderIconButton(
                    context,
                    Icons.shopping_cart_rounded,
                    () => context.push(AppRouter.cart),
                  ),
                  const SizedBox(width: 8),
                  _buildHeaderIconButton(
                    context,
                    Icons.notifications_rounded,
                    () => context.push(AppRouter.notifications, extra: true),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Glassmorphic statistics bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeaderStatItem('Ví điện tử', '320.000đ', Icons.account_balance_wallet_rounded),
                Container(width: 1, height: 26, color: Colors.white24),
                _buildHeaderStatItem('Xu tích lũy', '1.500 Xu', Icons.monetization_on_rounded),
                Container(width: 1, height: 26, color: Colors.white24),
                _buildHeaderStatItem('Kho Voucher', '4 Mã', Icons.local_offer_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildHeaderStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 13),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10.5, color: Colors.white70, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13.5, color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildOrderSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.06),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header of Order Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Đơn hàng của bạn',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Dẫn sang lịch sử đơn hàng
                },
                child: Row(
                  children: const [
                    Text(
                      'Lịch sử đơn',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Real-time tracking overlay card if active order exists
          ValueListenableBuilder<List<OrderHistoryItem>>(
            valueListenable: OrderManager.instance.ordersNotifier,
            builder: (context, orders, child) {
              final activeOrders = orders.where((o) => o.status != 'Đã giao').toList();
              if (activeOrders.isEmpty) return const SizedBox.shrink();
              
              final activeOrder = activeOrders.first;
              Color statusColor = activeOrder.status == 'Đang giao' ? Colors.blue : Colors.amber.shade700;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor.withOpacity(0.2), width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        activeOrder.status == 'Đang giao'
                            ? Icons.delivery_dining_rounded
                            : Icons.restaurant_rounded,
                        color: statusColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                activeOrder.status == 'Đang giao' ? 'Đang giao hàng' : 'Đang chuẩn bị',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activeOrder.status == 'Đang giao'
                                ? 'Tài xế Nguyễn Văn Hùng đang tới'
                                : 'Nhà hàng đang chế biến món ăn',
                            style: const TextStyle(fontSize: 11.5, color: Colors.black54, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(0, 32),
                      ),
                      onPressed: () {
                        context.push(AppRouter.orderTracking, extra: activeOrder);
                      },
                      child: const Text(
                        'Theo dõi',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Order stage items row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOrderItem(
                Icons.wallet_rounded,
                'Chờ thanh toán',
                Colors.amber.shade50,
                Colors.amber.shade800,
              ),
              _buildOrderItem(
                Icons.inventory_2_rounded,
                'Chờ lấy hàng',
                Colors.blue.shade50,
                Colors.blue.shade800,
              ),
              _buildOrderItem(
                Icons.local_shipping_rounded,
                'Đang giao',
                Colors.purple.shade50,
                Colors.purple.shade800,
              ),
              _buildOrderItem(
                Icons.rate_review_rounded,
                'Đánh giá',
                Colors.green.shade50,
                Colors.green.shade800,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(IconData icon, String label, Color bgColor, Color iconColor) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilitySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.06),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tiện ích của tôi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOrderItem(
                Icons.credit_card_rounded,
                'Ví liên kết',
                Colors.orange.shade50,
                Colors.orange.shade800,
              ),
              _buildOrderItem(
                Icons.account_balance_wallet_rounded,
                'SPayLater',
                Colors.teal.shade50,
                Colors.teal.shade800,
              ),
              _buildOrderItem(
                Icons.card_giftcard_rounded,
                'Quà tặng',
                Colors.red.shade50,
                Colors.red.shade800,
              ),
              _buildOrderItem(
                Icons.local_offer_rounded,
                'Mã giảm giá',
                Colors.pink.shade50,
                Colors.pink.shade800,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.06),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              'Hỗ trợ khách hàng',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.help_outline_rounded, color: Colors.blue.shade700),
            title: const Text(
              'Trung tâm trợ giúp',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: Colors.grey,
            ),
            onTap: () {},
          ),
          const Divider(height: 1, thickness: 0.5, color: Colors.black12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.headset_mic_rounded, color: Colors.green.shade700),
            title: const Text(
              'Chăm sóc trực tuyến 24/7',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: Colors.grey,
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 48, height: 1.2, color: Colors.grey.shade300),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Container(width: 48, height: 1.2, color: Colors.grey.shade300),
      ],
    );
  }

  Widget _buildFoodCardsGrid() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          FoodCardWidget(
            title: 'Hamburger Bò',
            image: 'assets/image/banner.png',
            price: '45.000đ',
            rating: '4.8',
          ),
          const SizedBox(width: 16),
          FoodCardWidget(
            title: 'Phở Gà Ta',
            image: 'assets/image/hamberger.png',
            price: '55.000đ',
            rating: '4.9',
          ),
          const SizedBox(width: 16),
          FoodCardWidget(
            title: 'Bánh Mỳ Đặc Biệt',
            image: 'assets/image/pho_ga.png',
            price: '25.000đ',
            rating: '4.7',
          ),
        ],
      ),
    );
  }
}
