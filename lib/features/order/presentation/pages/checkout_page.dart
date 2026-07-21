import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget.dart';
import '../../../../features/cart/data/cart_manager.dart';
import '../../../../features/cart/domain/entities/cart_item.dart';
import '../../data/order_manager.dart';
import 'package:provider/provider.dart';
import 'package:food_app/core/router/app_router.dart';
import 'package:food_app/core/services/order_service.dart';
import 'package:food_app/core/services/payment_service.dart';

class Voucher {
  final String code;
  final String description;
  final double discountPercent;
  final int maxDiscount;
  final int minOrder;

  Voucher({
    required this.code,
    required this.description,
    required this.discountPercent,
    required this.maxDiscount,
    this.minOrder = 0,
  });
}

class CheckoutPage extends StatefulWidget {
  final Voucher? initialVoucher;
  const CheckoutPage({super.key, this.initialVoucher});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedPaymentMethod = 'COD'; // 'BANK', 'MOMO', 'COD'
  Voucher? _appliedVoucher;
  String _deliveryAddress =
      'Số 11 , ngách 21/50/7 Yên Xá, Tân Triều, Thanh Trì, Hà Nội';
  String _deliveryNote = '';

  @override
  void initState() {
    super.initState();
    _appliedVoucher = widget.initialVoucher;
  }

  final List<Voucher> _availableVouchers = [
    Voucher(
      code: 'GIAMGIA50',
      description: 'Giảm 50% tối đa 50k ngày hè',
      discountPercent: 0.50,
      maxDiscount: 50000,
    ),
    Voucher(
      code: 'SUMMERFREE',
      description: 'Giảm 20% tối đa 30k giải nhiệt',
      discountPercent: 0.20,
      maxDiscount: 30000,
      minOrder: 80000,
    ),
    Voucher(
      code: 'FREESHIP',
      description: 'Miễn phí giao hàng (tối đa 10k)',
      discountPercent: 1.0,
      maxDiscount: 10000,
    ),
  ];

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = context.read<CartManager>().items;
    final subtotal = cartItems.fold<int>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final deliveryFee = subtotal > 0 ? 10000 : 0;

    // Tính toán giảm giá dựa trên mã giảm giá được áp dụng
    int discount = 0;
    if (_appliedVoucher != null) {
      if (_appliedVoucher!.code == 'FREESHIP') {
        discount = deliveryFee;
      } else {
        discount = (subtotal * _appliedVoucher!.discountPercent).round();
        if (discount > _appliedVoucher!.maxDiscount) {
          discount = _appliedVoucher!.maxDiscount;
        }
      }
    }

    final total = (subtotal + deliveryFee - discount).clamp(0, 99999999);

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
                          'Thanh toán',
                          style: TextStyle(
                            fontSize: 26,
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
                        color: AppColors.primaryRed.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        color: AppColors.primaryRed,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Checkout Form List
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                  children: [
                    // Card 1: Delivery Address
                    _buildAddressCard(),
                    const SizedBox(height: 16),
                    // Card 2: Restaurant & Dynamic Items
                    _buildOrderDetailsCard(cartItems),
                    const SizedBox(height: 16),
                    // Card 3: Payment Method
                    _buildPaymentMethodCard(),
                    const SizedBox(height: 16),
                    // Card 3.5: Voucher Selection Card
                    _buildVoucherCard(),
                    const SizedBox(height: 16),
                    // Card 4: Detailed Receipt break-down
                    _buildReceiptCard(
                      subtotal,
                      deliveryFee,
                      discount,
                      total,
                      cartItems.length,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Bottom Checkout Bar with dynamic total price
              _buildBottomBar(context, total, cartItems.isEmpty),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.primaryRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Địa chỉ giao hàng',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _deliveryAddress,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _showAddressDialog,
                child: const Text(
                  'Thay đổi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blueLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5, color: Colors.black12),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _showNoteDialog,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.edit_note_rounded,
                        color: AppColors.primaryRed,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _deliveryNote.isNotEmpty
                              ? 'Ghi chú: $_deliveryNote'
                              : 'Thêm ghi chú giao hàng...',
                          style: TextStyle(
                            fontSize: 13,
                            color: _deliveryNote.isNotEmpty
                                ? Colors.black87
                                : AppColors.primaryRed,
                            fontWeight: _deliveryNote.isNotEmpty
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_deliveryNote.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _deliveryNote = '';
                      });
                    },
                    child: Icon(
                      Icons.cancel_rounded,
                      color: Colors.grey.shade400,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard(List<CartItem> cartItems) {
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
          // Shop header
          Row(
            children: const [
              Icon(Icons.restaurant_rounded, color: Colors.green, size: 22),
              SizedBox(width: 8),
              Text(
                'Vào Bếp Cùng Cô Ba',
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

          // Dynamic items matching cart exactly
          cartItems.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Không có món ăn nào.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                )
              : Column(
                  children: cartItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCartItemRow(
                        image: item.image,
                        title: item.name,
                        quantity: item.quantity,
                        price: _formatPrice(item.price * item.quantity),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildCartItemRow({
    required String image,
    required String title,
    required int quantity,
    required String price,
  }) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 48,
            height: 48,
            color: Colors.grey.shade100,
            child: image.startsWith('http')
                ? Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      size: 20,
                      color: Colors.grey,
                    ),
                  )
                : Image.asset(image, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Số lượng: $quantity',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
        Text(
          price,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryRed,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard() {
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
          // Header
          Row(
            children: const [
              Icon(Icons.payment_rounded, color: AppColors.blueLight, size: 22),
              SizedBox(width: 8),
              Text(
                'Phương thức thanh toán',
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
          const SizedBox(height: 4),
          // Options
          _buildPaymentOptionRow(
            id: 'BANK',
            title: 'Thanh toán ngân hàng (Internet Banking)',
            icon: Icons.account_balance_rounded,
            iconColor: Colors.blue.shade700,
          ),
          _buildPaymentOptionRow(
            id: 'MOMO',
            title: 'Ví điện tử MoMo',
            icon: Icons.wallet_rounded,
            iconColor: const Color(0xFFA50064), // MoMo pink color
          ),
          _buildPaymentOptionRow(
            id: 'COD',
            title: 'Tiền mặt khi nhận hàng (COD)',
            icon: Icons.payments_rounded,
            iconColor: Colors.green.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptionRow({
    required String id,
    required String title,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = _selectedPaymentMethod == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryRed
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard(
    int subtotal,
    int deliveryFee,
    int discount,
    int total,
    int itemCount,
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
        children: [
          _buildReceiptRow(
            'Tạm tính ($itemCount món)',
            _formatPrice(subtotal),
            isBold: false,
          ),
          const SizedBox(height: 10),
          _buildReceiptRow(
            'Phí giao hàng',
            _formatPrice(deliveryFee),
            isBold: false,
          ),
          const SizedBox(height: 10),
          _buildReceiptRow(
            'Giảm giá ưu đãi',
            '-${_formatPrice(discount)}',
            isBold: false,
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                _formatPrice(total),
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
    required bool isBold,
    Color? textColor,
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
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: textColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, int total, bool isCartEmpty) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(
          0.92,
        ), // Glassmorphism style consistent with other sheets
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tổng thanh toán',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatPrice(total),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryRed,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: isCartEmpty
                    ? [Colors.grey.shade400, Colors.grey.shade500]
                    : [
                        const Color(0xFFFF5722), // Summer Orange
                        const Color(0xFFF22323), // Primary Red
                      ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: isCartEmpty
                  ? []
                  : [
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
                minimumSize: const Size(160, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              onPressed: isCartEmpty
                  ? null
                  : () async {
                      final int currentTotal = total;
                      final String currentMethod = _selectedPaymentMethod;
                      final itemsCopy = List<CartItem>.from(
                        context.read<CartManager>().items,
                      );

                      // Gửi đơn hàng lên Backend API
                      final orderItemsJson = itemsCopy.map((item) => {
                        'food_name': item.name,
                        'food_image': item.image,
                        'price': '${item.price}đ',
                        'quantity': item.quantity,
                      }).toList();

                      final result = await OrderService.createOrder(
                        totalPrice: currentTotal,
                        paymentMethod: currentMethod,
                        shippingAddress: _deliveryAddress,
                        items: orderItemsJson,
                        note: _deliveryNote,
                      );

                      String orderId = '#FOOD-${(100000 + math.Random().nextInt(900000))}';
                      String? qrUrl;
                      String? txCode;

                      if (result['success'] == true && result['data'] != null) {
                        orderId = '#${result['data']['order_code']}';
                        final int backendOrderId = result['data']['id'];

                        final paymentRes = await PaymentService.createPaymentQr(
                          orderId: backendOrderId,
                          paymentMethod: currentMethod,
                          amount: currentTotal,
                        );

                        if (paymentRes['success'] == true && paymentRes['data'] != null) {
                          qrUrl = paymentRes['data']['qr_url'];
                          txCode = paymentRes['data']['transaction_code'];
                        }
                      }

                      // Cập nhật vào OrderManager và làm trống giỏ hàng
                      OrderManager.instance.addOrder(
                        OrderHistoryItem(
                          orderId: orderId,
                          orderDate: DateTime.now(),
                          items: itemsCopy,
                          totalPrice: currentTotal,
                          paymentMethod: currentMethod,
                          address: _deliveryAddress,
                          note: _deliveryNote,
                          status: 'Đang chuẩn bị',
                        ),
                      );

                      if (!mounted) return;
                      context.read<CartManager>().clear();

                      context.push(
                        AppRouter.paymentSuccess,
                        extra: {
                          'totalPrice': currentTotal,
                          'paymentMethod': currentMethod,
                          'orderId': orderId,
                          'qrUrl': qrUrl,
                          'txCode': txCode,
                        },
                      );
                    },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Đặt hàng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherCard() {
    return GestureDetector(
      onTap: () => _showVoucherBottomSheet(context),
      child: Container(
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
          border: Border.all(
            color: _appliedVoucher != null
                ? Colors.green.withOpacity(0.5)
                : Colors.grey.withOpacity(0.06),
            width: _appliedVoucher != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _appliedVoucher != null
                          ? Colors.green.withOpacity(0.1)
                          : AppColors.primaryRed.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _appliedVoucher != null
                          ? Icons.check_circle_outline_rounded
                          : Icons.local_offer_outlined,
                      color: _appliedVoucher != null
                          ? Colors.green
                          : AppColors.primaryRed,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _appliedVoucher != null
                              ? 'Đã áp dụng: ${_appliedVoucher!.code}'
                              : 'Ưu đãi & Voucher',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _appliedVoucher != null
                              ? _appliedVoucher!.description
                              : 'Chọn hoặc nhập mã giảm giá',
                          style: TextStyle(
                            fontSize: 12,
                            color: _appliedVoucher != null
                                ? Colors.green.shade700
                                : Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                if (_appliedVoucher != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _appliedVoucher = null;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showVoucherBottomSheet(BuildContext context) {
    final TextEditingController localController = TextEditingController();
    String? localError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ưu đãi & Voucher',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: localController,
                            decoration: InputDecoration(
                              hintText: 'Nhập mã giảm giá (VD: GIAMGIA50)...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              errorText: localError,
                            ),
                            style: const TextStyle(fontSize: 14),
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            minimumSize: const Size(90, 48),
                            elevation: 0,
                          ),
                          onPressed: () {
                            final code = localController.text
                                .trim()
                                .toUpperCase();
                            if (code.isEmpty) return;

                            Voucher? foundVoucher;
                            if (code == 'GIAMGIA50') {
                              foundVoucher = Voucher(
                                code: 'GIAMGIA50',
                                description: 'Giảm 50% tối đa 50k ngày hè',
                                discountPercent: 0.50,
                                maxDiscount: 50000,
                              );
                            } else {
                              final idx = _availableVouchers.indexWhere(
                                (element) => element.code == code,
                              );
                              if (idx >= 0) {
                                foundVoucher = _availableVouchers[idx];
                              }
                            }

                            if (foundVoucher != null) {
                              setState(() {
                                _appliedVoucher = foundVoucher;
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Đã áp dụng mã ${foundVoucher.code}!',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else {
                              setModalState(() {
                                localError = 'Mã giảm giá không hợp lệ';
                              });
                            }
                          },
                          child: const Text(
                            'Áp dụng',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Ưu đãi có sẵn cho bạn',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _availableVouchers.length,
                        itemBuilder: (context, index) {
                          final v = _availableVouchers[index];
                          final isApplied = _appliedVoucher?.code == v.code;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isApplied
                                    ? Colors.green
                                    : Colors.grey.withOpacity(0.12),
                                width: isApplied ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  '🎫',
                                  style: TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        v.code,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.primaryRed,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        v.description,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isApplied
                                        ? Colors.green
                                        : Colors.grey.shade100,
                                    foregroundColor: isApplied
                                        ? Colors.white
                                        : Colors.black87,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    minimumSize: const Size(70, 36),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _appliedVoucher = v;
                                    });
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(
                                      context,
                                    ).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Đã áp dụng mã ${v.code}!',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    isApplied ? 'Đã áp' : 'Dùng',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddressDialog() {
    final TextEditingController addressCtrl = TextEditingController(
      text: _deliveryAddress,
    );
    final List<String> presetAddresses = [
      'Số 11 , ngách 21/50/7 Yên Xá, Tân Triều, Thanh Trì, Hà Nội (Nhà riêng)',
      'Tòa nhà Keangnam, Phạm Hùng, Mễ Trì, Nam Từ Liêm, Hà Nội (Văn phòng)',
      'Đại học Bách Khoa Hà Nội, 1 Đại Cồ Việt, Hai Bà Trưng, Hà Nội (Trường học)',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Thay đổi địa chỉ giao hàng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: addressCtrl,
                maxLines: 2,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Nhập địa chỉ mới...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Địa chỉ đã lưu:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              ...presetAddresses
                  .map(
                    (addr) => GestureDetector(
                      onTap: () {
                        addressCtrl.text = addr;
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(8),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          addr,
                          style: const TextStyle(fontSize: 11),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (addressCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    _deliveryAddress = addressCtrl.text.trim();
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Xác nhận',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showNoteDialog() {
    final TextEditingController noteCtrl = TextEditingController(
      text: _deliveryNote,
    );
    final List<String> presetNotes = [
      'Giao hàng không gọi điện (nhắn tin)',
      'Nhiều rau, ít sốt',
      'Để ở quầy lễ tân',
      'Gặp bảo vệ tòa nhà',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Thêm ghi chú giao hàng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: noteCtrl,
                maxLines: 2,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Nhập ghi chú giao hàng...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Gợi ý:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: presetNotes
                    .map(
                      (note) => GestureDetector(
                        onTap: () {
                          noteCtrl.text = note;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            note,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                setState(() {
                  _deliveryNote = noteCtrl.text.trim();
                });
                Navigator.pop(context);
              },
              child: const Text('Lưu', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
