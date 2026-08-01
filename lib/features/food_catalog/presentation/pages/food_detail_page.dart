import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widget.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/favorite_manager.dart';
import '../../../../features/cart/data/cart_manager.dart';
import '../../../../features/cart/domain/entities/cart_item.dart';
import 'package:provider/provider.dart';
import 'package:food_app/core/router/app_router.dart';
import 'package:food_app/core/widgets/app_image_widget.dart';
import 'package:food_app/core/services/auth_service.dart';

class ReviewItem {
  final String id;
  final String userName;
  final String avatarUrl;
  final double rating;
  final String date;
  final String comment;

  ReviewItem({
    required this.id,
    required this.userName,
    required this.avatarUrl,
    required this.rating,
    required this.date,
    required this.comment,
  });
}

class FoodDetailPage extends StatefulWidget {
  final String title;
  final String image;
  final String price;
  final String rating;
  final String? prepTime;
  final String? calories;
  final String? description;
  final String? authorName;

  const FoodDetailPage({
    super.key,
    required this.title,
    required this.image,
    required this.price,
    required this.rating,
    this.prepTime,
    this.calories,
    this.description,
    this.authorName,
  });

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  int _quantity = 1;
  int _userRating = 5;
  final GlobalKey _cartKey = GlobalKey();
  final GlobalKey _imageKey = GlobalKey();
  final TextEditingController _reviewController = TextEditingController();

  final List<ReviewItem> _reviews = [
    ReviewItem(
      id: 'rev1',
      userName: 'Trần Thị Mai',
      avatarUrl: '',
      rating: 5.0,
      date: 'Vừa xong',
      comment:
          'Món ăn rất tươi ngon, nóng hổi và đúng như mô tả! Giao hàng siêu nhanh.',
    ),
    ReviewItem(
      id: 'rev2',
      userName: 'Lê Hoàng Nam',
      avatarUrl: '',
      rating: 5.0,
      date: '2 giờ trước',
      comment:
          'Hương vị đậm đà chuẩn vị nhà làm, nước sốt thơm phức. Sẽ ủng hộ dài dài!',
    ),
    ReviewItem(
      id: 'rev3',
      userName: 'Phạm Minh Anh',
      avatarUrl: '',
      rating: 4.5,
      date: 'Hôm qua',
      comment: 'Đóng gói rất chỉn chu, giao hàng tận nơi vẫn nóng hổi.',
    ),
  ];

  String _authorNameDisplay = '';

  @override
  void initState() {
    super.initState();
    _initAuthorName();
  }

  Future<void> _initAuthorName() async {
    if (widget.authorName != null && widget.authorName!.trim().isNotEmpty) {
      setState(() {
        _authorNameDisplay = widget.authorName!.trim();
      });
      return;
    }
    final cached = await AuthService.getUserName();
    if (cached != null && cached.isNotEmpty) {
      if (mounted) {
        setState(() {
          _authorNameDisplay = cached;
        });
      }
    }
    final res = await AuthService.getCurrentUser();
    if (res['success'] == true && res['data'] != null) {
      final name = (res['data']['full_name'] as String?)?.trim();
      final username = (res['data']['username'] as String?)?.trim();
      final realName = (name != null && name.isNotEmpty)
          ? name
          : ((username != null && username.isNotEmpty)
                ? username
                : 'Tài Khoản User');
      if (mounted) {
        setState(() {
          _authorNameDisplay = realName;
        });
      }
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  int _parsePrice(String priceStr) {
    final clean = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 20000;
  }

  void _submitReview() {
    final text = _reviewController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung đánh giá của bạn!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _reviews.insert(
        0,
        ReviewItem(
          id: 'user_rev_${DateTime.now().millisecondsSinceEpoch}',
          userName: 'Bạn (Người dùng)',
          avatarUrl: '',
          rating: _userRating.toDouble(),
          date: 'Vừa xong',
          comment: text,
        ),
      );
      _reviewController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Cảm ơn bạn đã gửi đánh giá & ý kiến đóng góp!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _runAddToCartAnimation() {
    final RenderBox? imageBox =
        _imageKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? cartBox =
        _cartKey.currentContext?.findRenderObject() as RenderBox?;

    if (imageBox == null || cartBox == null) {
      _addToCartDirectly();
      return;
    }

    final Offset imageOffset = imageBox.localToGlobal(Offset.zero);
    final Offset cartOffset = cartBox.localToGlobal(Offset.zero);
    final Size imageSize = imageBox.size;
    final Size cartSize = cartBox.size;

    final startOffset = Offset(
      imageOffset.dx + imageSize.width / 2 - 25,
      imageOffset.dy + imageSize.height / 2 - 25,
    );
    final endOffset = Offset(
      cartOffset.dx + cartSize.width / 2 - 18,
      cartOffset.dy + cartSize.height / 2 - 18,
    );

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => FlyingFoodWidget(
        startOffset: startOffset,
        endOffset: endOffset,
        image: widget.image,
        onFinished: () {
          overlayEntry.remove();
          _addToCartDirectly();
        },
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  void _addToCartDirectly() {
    context.read<CartManager>().addItem(
      CartItem(
        name: widget.title,
        price: _parsePrice(widget.price),
        quantity: _quantity,
        image: widget.image,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final basePrice = _parsePrice(widget.price);
    final totalPrice = basePrice * _quantity;
    final formattedPrice =
        '${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';

    final authorText =
        (widget.authorName != null &&
            widget.authorName!.trim().isNotEmpty &&
            widget.authorName != 'Nguyễn Văn A')
        ? widget.authorName!.trim()
        : (_authorNameDisplay.isNotEmpty ? _authorNameDisplay : 'Lê Ngọc Duy');

    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      // Sticky bottom bar for Add to Cart button
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 10, 20, bottomPadding + 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: const LinearGradient(
              colors: [Color(0xFFFF5722), Color(0xFFF22323)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryRed.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            onPressed: _runAddToCartAnimation,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.shopping_cart_rounded,
                  size: 20,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Text(
                  'Thêm vào giỏ hàng',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: BackgroundContainer(
        opacity: 0.15,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: _BuildAppBar(cartKey: _cartKey),
                ),

                // 2. Food Image Card with floating heart
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      key: _imageKey,
                      height: 240,
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: AppImageWidget(
                          imagePath: widget.image,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Floating Heart Button
                    Positioned(
                      bottom: 0,
                      right: 42,
                      child: ValueListenableBuilder<List<FavoriteMeal>>(
                        valueListenable:
                            FavoriteManager.instance.favoritesNotifier,
                        builder: (context, favorites, child) {
                          final isFav = FavoriteManager.instance.isFavorite(
                            widget.title,
                          );
                          return GestureDetector(
                            onTap: () {
                              final category =
                                  widget.title.contains('Bánh Mì') ||
                                      widget.title.contains('Bánh mỳ')
                                  ? 'Bánh mỳ'
                                  : 'Phở & Bún';
                              FavoriteManager.instance.toggleFavorite(
                                FavoriteMeal(
                                  title: widget.title,
                                  image: widget.image,
                                  price: widget.price,
                                  rating: widget.rating,
                                  category: category,
                                ),
                              );
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    !isFav
                                        ? 'Đã thêm "${widget.title}" vào yêu thích.'
                                        : 'Đã xóa "${widget.title}" khỏi yêu thích.',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: AppColors.primaryRed,
                                size: 24,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 3. Main Floating Content Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    color: Colors.white.withValues(alpha: 0.95),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quantity selector
                      Center(
                        child: Container(
                          width: 130,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.primaryRed,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryRed.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: _BuildButtonQuantity(
                            quantity: _quantity,
                            onIncrement: _incrementQuantity,
                            onDecrement: _decrementQuantity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title & Price Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: const [
                                    Text('🌴', style: TextStyle(fontSize: 13)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Món ngon giải nhiệt ngày hè!',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            formattedPrice,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 👤 Thẻ Người Đăng Sản Phẩm (Hiển thị tên User thật ngắn gọn & sang trọng)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryRed.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFF7043),
                                    AppColors.primaryRed,
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          authorText,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.blue,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Tài khoản người đăng • Đã xác minh ✓',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Info Cards (Rating, Calories, PrepTime)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _BuildInfoFood(
                            icon: Icons.star_rounded,
                            text: widget.rating,
                            iconColor: Colors.amber.shade700,
                            bgColor: Colors.amber.withValues(alpha: 0.12),
                          ),
                          _BuildInfoFood(
                            icon: Icons.local_fire_department_rounded,
                            text: widget.calories ?? '350 KCal',
                            iconColor: const Color(0xFFFF5722),
                            bgColor: const Color(
                              0xFFFF5722,
                            ).withValues(alpha: 0.12),
                          ),
                          _BuildInfoFood(
                            icon: Icons.access_time_filled_rounded,
                            text: widget.prepTime ?? '10-15 phút',
                            iconColor: Colors.blue.shade700,
                            bgColor: Colors.blue.withValues(alpha: 0.12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 1. Phần Mô Tả Sản Phẩm
                      const Text(
                        'Mô tả món ăn',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        (widget.description != null &&
                                widget.description!.trim().isNotEmpty)
                            ? widget.description!
                            : 'Đây là biểu tượng ẩm thực độc đáo, được chế biến từ các nguyên liệu tươi ngon chọn lọc theo công thức truyền thống, mang đến cho bạn hương vị đậm đà và trải nghiệm ẩm thực tuyệt vời.',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 18),

                      // 2. Khu Vực Đánh Giá & Ý Kiến Đóng Góp (Reviews & Ratings)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Đánh giá & Nhận xét',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.rating} (${_reviews.length} đánh giá)',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Khung Viết Đánh Giá của Người Dùng
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Đánh giá của bạn:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Thanh chọn sao tương tác
                            Row(
                              children: List.generate(5, (index) {
                                final starIndex = index + 1;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _userRating = starIndex;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Icon(
                                      starIndex <= _userRating
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      color: Colors.amber,
                                      size: 26,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 10),
                            // Ô nhập văn bản nhận xét
                            TextField(
                              controller: _reviewController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText:
                                    'Viết cảm nhận hoặc đóng góp ý kiến của bạn...',
                                hintStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.all(10),
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryRed,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryRed,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: _submitReview,
                                icon: const Icon(
                                  Icons.send_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Gửi nhận xét',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Danh sách các Nhận xét của khách hàng (Cuộn không bao giờ bị che)
                      Column(
                        children: _reviews.map((rev) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppColors.primaryRed
                                          .withValues(alpha: 0.15),
                                      child: Text(
                                        rev.userName
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryRed,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        rev.userName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      rev.date,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: List.generate(5, (sIdx) {
                                    return Icon(
                                      sIdx < rev.rating.toInt()
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      color: Colors.amber,
                                      size: 14,
                                    );
                                  }),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  rev.comment,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.grey.shade800,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BuildAppBar extends StatelessWidget {
  final GlobalKey cartKey;
  const _BuildAppBar({required this.cartKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black87,
                  size: 18,
                ),
              ),
            ),
          ),
          CartIconButton(key: cartKey),
        ],
      ),
    );
  }
}

class _BuildInfoFood extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final Color bgColor;
  final Color textColor;

  const _BuildInfoFood({
    required this.icon,
    required this.text,
    required this.iconColor,
    required this.bgColor,
    this.textColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildButtonQuantity extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _BuildButtonQuantity({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.remove, color: Colors.white, size: 20),
          onPressed: onDecrement,
        ),
        Text(
          '$quantity',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.add, color: Colors.white, size: 20),
          onPressed: onIncrement,
        ),
      ],
    );
  }
}

// PREMIUM flying widget overlay with Bezier Curve path
class FlyingFoodWidget extends StatefulWidget {
  final Offset startOffset;
  final Offset endOffset;
  final String image;
  final VoidCallback onFinished;

  const FlyingFoodWidget({
    super.key,
    required this.startOffset,
    required this.endOffset,
    required this.image,
    required this.onFinished,
  });

  @override
  State<FlyingFoodWidget> createState() => _FlyingFoodWidgetState();
}

class _FlyingFoodWidgetState extends State<FlyingFoodWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInCubic,
    );
    _controller.forward().then((_) {
      widget.onFinished();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double t = _animation.value;

        final double controlX =
            widget.startOffset.dx +
            (widget.endOffset.dx - widget.startOffset.dx) * 0.3 +
            90;
        final double controlY = widget.startOffset.dy - 120;

        final double x =
            (1 - t) * (1 - t) * widget.startOffset.dx +
            2 * (1 - t) * t * controlX +
            t * t * widget.endOffset.dx;
        final double y =
            (1 - t) * (1 - t) * widget.startOffset.dy +
            2 * (1 - t) * t * controlY +
            t * t * widget.endOffset.dy;

        final double scale = 1.0 - (t * 0.65);
        final double opacity = 1.0 - (t * 0.15);

        return Positioned(
          left: x,
          top: y,
          child: Material(
            color: Colors.transparent,
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(scale: scale, child: child),
            ),
          ),
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: AppColors.primaryRed, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: AppImageWidget(imagePath: widget.image, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

// Bouncing Cart Icon Button with Badge
class CartIconButton extends StatefulWidget {
  const CartIconButton({super.key});

  @override
  State<CartIconButton> createState() => _CartIconButtonState();
}

class _CartIconButtonState extends State<CartIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.35),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.35, end: 0.9),
        weight: 35,
      ),
      TweenSequenceItem(tween: Tween<double>(begin: 0.9, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerBounce() {
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartManager>(
      builder: (context, carts, child) {
        final cart = carts.items;
        final int count = cart.fold<int>(0, (sum, item) => sum + item.quantity);

        if (count > _lastCount) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _triggerBounce();
            }
          });
        }
        _lastCount = count;

        return ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTap: () {
              context.push(AppRouter.cart);
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                ),
                if (count > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
