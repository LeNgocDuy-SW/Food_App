import 'package:flutter/material.dart';
import '../../../../core/widget.dart';
import '../../../food_catalog/presentation/widgets/food_card_widget.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../../features/chat/presentation/pages/notification_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        opacity: 0.5,
        child: Column(
          children: [
            // Orange Header block
            _buildHeader(context),
            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Đơn hàng của bạn card
                    _buildOrderSection(),
                    const SizedBox(height: 20),
                    // Tiện ích của tôi card
                    _buildUtilitySection(),
                    const SizedBox(height: 20),
                    // Hỗ trợ card
                    _buildSupportSection(),
                    const SizedBox(height: 24),
                    // Có thể bạn cũng thích header
                    _buildSectionHeader('Có thể bạn cũng thích'),
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
      color: const Color(0xFFEB9C6C),
      padding: EdgeInsets.fromLTRB(20, statusBarHeight + 16, 20, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              image: const DecorationImage(
                image: AssetImage('assets/image/avatar.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // User Stats & Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(height: 4),
                Text(
                  'lengocduy25',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '11 Đang theo dõi   9 Người theo dõi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Actions: settings, cart, chat
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context, createRoute(const SettingsPage()));
                },
                child: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, createRoute(const CartPage()));
                },
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, createRoute(const NotificationPage(showBackButton: true)));
                },
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Đơn hàng của bạn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Xem tất cả',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOrderItem(Icons.account_balance_wallet_outlined, 'Chờ thanh toán'),
              _buildOrderItem(Icons.inventory_2_outlined, 'Chờ vận chuyển'),
              _buildOrderItem(Icons.local_shipping_outlined, 'Chờ nhận'),
              _buildOrderItem(Icons.star_outline, 'Chờ đánh giá'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.black87),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
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
        color: const Color(0xFFF5EFEB), // Light peach matching style
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tiện ích của tôi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOrderItem(Icons.credit_card, 'Ví của tôi'),
              _buildOrderItem(Icons.account_balance_wallet_outlined, 'SPayLater'),
              _buildOrderItem(Icons.monetization_on_outlined, 'Thưởng'),
              _buildOrderItem(Icons.local_offer_outlined, 'Voucher'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFEB),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              'Hỗ trợ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.help_outline, color: Colors.black87),
            title: const Text(
              'Trung tâm trợ giúp',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            onTap: () {},
          ),
          const Divider(height: 1, thickness: 0.5, color: Colors.black12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.headset_mic_outlined, color: Colors.black87),
            title: const Text(
              'Chăm sóc khách hàng',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
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
        Container(
          width: 60,
          height: 1,
          color: Colors.black38,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          width: 60,
          height: 1,
          color: Colors.black38,
        ),
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
