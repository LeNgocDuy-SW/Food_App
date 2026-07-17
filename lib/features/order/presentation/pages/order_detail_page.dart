import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget.dart';
import '../../../../features/cart/data/cart_manager.dart';
import '../../data/order_manager.dart';
import 'package:provider/provider.dart';
import 'package:food_app/core/router/app_router.dart';

class OrderDetailPage extends StatelessWidget {
  final OrderHistoryItem order;

  const OrderDetailPage({super.key, required this.order});

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    final String hour = date.hour.toString().padLeft(2, '0');
    final String minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'BANK':
        return 'Chuyển khoản Ngân hàng';
      case 'MOMO':
        return 'Ví điện tử MoMo';
      case 'COD':
      default:
        return 'Tiền mặt khi nhận hàng (COD)';
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đã giao':
        return Colors.green;
      case 'Đang giao':
        return Colors.blue;
      case 'Đang chuẩn bị':
      default:
        return Colors.amber.shade700;
    }
  }

  void _reorder(BuildContext context) {
    for (var item in order.items) {
      context.read<CartManager>().addItem(item);
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã thêm lại các món vào giỏ hàng!'),
        duration: Duration(seconds: 2),
      ),
    );
    context.push(AppRouter.cart);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    final int subtotal = order.items.fold<int>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final int deliveryFee = 10000;
    final int discount = (subtotal + deliveryFee - order.totalPrice).clamp(
      0,
      999999,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: BackgroundContainer(
        opacity: 0.15,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Custom AppBar consistent with other pages
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
                          'Chi tiết đơn hàng',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable details content
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  children: [
                    // Card 1: Order Code & State Timeline
                    _buildStatusTimelineCard(statusColor),
                    const SizedBox(height: 16),

                    // Card 2: Delivery Location Address
                    _buildDeliveryAddressCard(),
                    const SizedBox(height: 16),

                    // Card 3: Food Items List
                    _buildFoodItemsCard(),
                    const SizedBox(height: 16),

                    // Card 4: Payment Details & Invoice receipt summary
                    _buildReceiptBreakdownCard(subtotal, deliveryFee, discount),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Floating bottom reorder action button
              _buildBottomActionBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTimelineCard(Color statusColor) {
    // Determine active steps based on order status
    bool step1 = true; // Đã đặt đơn
    bool step2 = true; // Đang chuẩn bị
    bool step3 =
        order.status == 'Đang giao' || order.status == 'Đã giao'; // Đang giao
    bool step4 = order.status == 'Đã giao'; // Đã giao

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderId,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Thời gian đặt: ${_formatDate(order.orderDate)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          // Timeline indicator
          Row(
            children: [
              _buildTimelineNode(
                Icons.assignment_turned_in_rounded,
                'Đặt đơn',
                step1,
                true,
              ),
              _buildTimelineConnector(step2),
              _buildTimelineNode(Icons.cookie_rounded, 'Chuẩn bị', step2, true),
              _buildTimelineConnector(step3),
              _buildTimelineNode(
                Icons.delivery_dining_rounded,
                'Đang giao',
                step3,
                true,
              ),
              _buildTimelineConnector(step4),
              _buildTimelineNode(
                Icons.check_circle_rounded,
                'Đã giao',
                step4,
                false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineNode(
    IconData icon,
    String label,
    bool isActive,
    bool hasConnector,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? Colors.green.withOpacity(0.3)
                    : Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.green : Colors.grey.shade400,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.green : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineConnector(bool isActive) {
    return Container(
      width: 20,
      height: 2,
      margin: const EdgeInsets.only(
        bottom: 22,
      ), // Align vertically centered with node icons
      color: isActive ? Colors.green : Colors.grey.shade200,
    );
  }

  Widget _buildDeliveryAddressCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primaryRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Địa chỉ nhận hàng',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order.address,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          if (order.note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.edit_note_rounded,
                    color: AppColors.primaryRed,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Ghi chú: ${order.note}',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFoodItemsCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.restaurant_rounded, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Sản phẩm đã chọn',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5, color: Colors.black12),
          const SizedBox(height: 12),

          Column(
            children: order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 48,
                        height: 48,
                        color: Colors.grey.shade100,
                        child: item.image.startsWith('http')
                            ? Image.network(
                                item.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.broken_image,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                              )
                            : Image.asset(item.image, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Số lượng: ${item.quantity}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatPrice(item.price * item.quantity),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptBreakdownCard(
    int subtotal,
    int deliveryFee,
    int discount,
  ) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getPaymentMethodIcon(order.paymentMethod),
                  color: Colors.blue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thanh toán qua',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getPaymentMethodText(order.paymentMethod),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.5, color: Colors.black12),
          const SizedBox(height: 16),

          _buildReceiptRow(
            'Tạm tính',
            _formatPrice(subtotal),
            textColor: Colors.black54,
          ),
          const SizedBox(height: 10),
          _buildReceiptRow(
            'Phí giao hàng',
            _formatPrice(deliveryFee),
            textColor: Colors.black54,
          ),
          const SizedBox(height: 10),
          _buildReceiptRow(
            'Giảm giá ưu đãi',
            '-${_formatPrice(discount)}',
            textColor: Colors.green,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5, color: Colors.black12),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng thanh toán',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                _formatPrice(order.totalPrice),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    required Color textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    final bool isActive = order.status != 'Đã giao';

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
          gradient: LinearGradient(
            colors: isActive
                ? [
                    const Color(0xFF00B0FF),
                    const Color(0xFF00E676),
                  ] // Cyan to Green for tracking active order
                : [
                    const Color(0xFFFF5722), // Summer Orange
                    const Color(0xFFF22323), // Primary Red
                  ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (isActive ? Colors.green : AppColors.primaryRed)
                  .withOpacity(0.3),
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
            if (isActive) {
              context.push(
                AppRouter.orderTracking,
                extra: order,
              );
            } else {
              _reorder(context);
            }
          },
          icon: Icon(
            isActive ? Icons.navigation_rounded : Icons.replay_rounded,
            color: Colors.white,
            size: 20,
          ),
          label: Text(
            isActive ? 'Theo dõi hành trình' : 'Đặt lại đơn này',
            style: const TextStyle(
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
