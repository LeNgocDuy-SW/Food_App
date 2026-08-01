import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:food_app/features/order/presentation/pages/checkout_page.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget.dart';
import '../../domain/entities/cart_item.dart';
import '../../data/cart_manager.dart';
import 'package:provider/provider.dart';
import 'package:food_app/core/router/app_router.dart';
import 'package:food_app/core/widgets/app_image_widget.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Voucher? _appliedVoucher;

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
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: BackgroundContainer(
        opacity: 0.15,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Custom Header / AppBar consistent with the app
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
                          'Giỏ hàng',
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
                        Icons.shopping_bag_outlined,
                        color: AppColors.primaryRed,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Cart Items List
              Expanded(
                child: Consumer<CartManager>(
                  builder: (context, cartItems, child) {
                    final cartList = cartItems.items;
                    if (cartList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.shopping_cart_outlined,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Giỏ hàng của bạn đang trống',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                      itemCount: cartList.length,
                      itemBuilder: (context, index) {
                        final item = cartList[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildCartItemCard(context, item),
                        );
                      },
                    );
                  },
                ),
              ),
              // Bottom Summary Section
              _buildBottomSummary(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          // Food image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 84,
              height: 84,
              child: AppImageWidget(
                imagePath: item.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: SizedBox(
              height: 84,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Modern, subtle delete button instead of overlapping badge
                      GestureDetector(
                        onTap: () =>
                            context.read<CartManager>().removeItem(item),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.grey.shade600,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Subtotal Price for this item
                      Text(
                        _formatPrice(item.price * item.quantity),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryRed,
                        ),
                      ),

                      // Modern Rounded Quantity Selector (no solid color background, thin border instead)
                      Container(
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => context
                                  .read<CartManager>()
                                  .decrementQuantity(item),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                child: Icon(
                                  Icons.remove,
                                  color: Colors.grey.shade700,
                                  size: 14,
                                ),
                              ),
                            ),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context
                                  .read<CartManager>()
                                  .incrementQuantity(item),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.grey.shade700,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSummary(BuildContext context) {
    return Consumer<CartManager>(
      builder: (context, cartItems, child) {
        final cartItem = cartItems.items;
        final subtotal = cartItem.fold<int>(
          0,
          (sum, item) => sum + (item.price * item.quantity),
        );
        final deliveryFee = subtotal > 0 ? 10000 : 0;

        // Tính toán giảm giá theo mã giảm giá áp dụng
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

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            color: Colors.white.withOpacity(
              0.92,
            ), // Glassmorphism background consistent with details sheet
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Voucher / Coupon Entry Card (Đã được làm tương tác đầy đủ)
              _buildVoucherCard(),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tạm tính',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    _formatPrice(subtotal),
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
                children: [
                  Text(
                    'Phí giao hàng',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    _formatPrice(deliveryFee),
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
                children: [
                  Text(
                    'Giảm giá',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '-${_formatPrice(discount)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.black12, height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng thanh toán',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
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
              const SizedBox(height: 20),

              // Pay button with Summer sunset orange gradient
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
                    if (cartItem.isEmpty) return;
                    context.push(
                      AppRouter.checkout,
                      extra: _appliedVoucher,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.payments_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Tiến hành thanh toán',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoucherCard() {
    return GestureDetector(
      onTap: () => _showVoucherBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _appliedVoucher != null
                ? Colors.green.withOpacity(0.5)
                : Colors.grey.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    _appliedVoucher != null
                        ? Icons.check_circle_outline_rounded
                        : Icons.local_offer_outlined,
                    color: _appliedVoucher != null
                        ? Colors.green
                        : AppColors.primaryRed,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
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
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  _appliedVoucher != null
                      ? _appliedVoucher!.description
                      : 'Chọn hoặc nhập mã',
                  style: TextStyle(
                    fontSize: 12,
                    color: _appliedVoucher != null
                        ? Colors.green.shade700
                        : Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
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
                  size: 12,
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
}
