import 'package:flutter/material.dart';
import '../../../../core/widget.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/cart/data/cart_manager.dart';
import '../../../../features/cart/domain/entities/cart_item.dart';
import '../../../../features/cart/presentation/pages/cart_page.dart';

class FoodDetailPage extends StatefulWidget {
  final String title;
  final String image;
  final String price;
  final String rating;
  final String? prepTime;

  const FoodDetailPage({
    super.key,
    required this.title,
    required this.image,
    required this.price,
    required this.rating,
    this.prepTime,
  });

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  int _quantity = 1;
  final GlobalKey _cartKey = GlobalKey();
  final GlobalKey _imageKey = GlobalKey();

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

  void _runAddToCartAnimation() {
    final RenderBox? imageBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? cartBox = _cartKey.currentContext?.findRenderObject() as RenderBox?;
    
    if (imageBox == null || cartBox == null) {
      _addToCartDirectly();
      return;
    }
    
    final Offset imageOffset = imageBox.localToGlobal(Offset.zero);
    final Offset cartOffset = cartBox.localToGlobal(Offset.zero);
    final Size imageSize = imageBox.size;
    final Size cartSize = cartBox.size;
    
    // Center of the food image card
    final startOffset = Offset(
      imageOffset.dx + imageSize.width / 2 - 25,
      imageOffset.dy + imageSize.height / 2 - 25,
    );
    // Center of the cart icon button
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
    CartManager.instance.addItem(
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      body: BackgroundContainer(
        opacity: 0.5,
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar with Cart key passed
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: _BuildAppBar(cartKey: _cartKey),
              ),
              
              // Food Image Card (contained & non-overlapping) with Image key passed
              Expanded(
                flex: 4,
                child: Container(
                  key: _imageKey,
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: widget.image.startsWith('http')
                        ? Image.network(
                            widget.image,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 100),
                          )
                        : Image.asset(
                            widget.image,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),

              // Details section container
              Expanded(
                flex: 5,
                child: _BuildContainerMain(
                  title: widget.title,
                  image: widget.image,
                  price: widget.price,
                  rating: widget.rating,
                  prepTime: widget.prepTime,
                  quantity: _quantity,
                  onIncrement: _incrementQuantity,
                  onDecrement: _decrementQuantity,
                  onAddToCart: _runAddToCartAnimation,
                ),
              ),
            ],
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
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 37,
              height: 37,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
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
                  color: Colors.black,
                  size: 18,
                ),
              ),
            ),
          ),
          // Bouncing Cart button with global key
          CartIconButton(key: cartKey),
        ],
      ),
    );
  }
}

class _BuildContainerMain extends StatelessWidget {
  final String title;
  final String image;
  final String price;
  final String rating;
  final String? prepTime;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onAddToCart;

  const _BuildContainerMain({
    required this.title,
    required this.image,
    required this.price,
    required this.rating,
    this.prepTime,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onAddToCart,
  });

  int _parsePrice(String priceStr) {
    final clean = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 20000;
  }

  @override
  Widget build(BuildContext context) {
    final basePrice = _parsePrice(price);
    final totalPrice = basePrice * quantity;

    final formattedPrice =
        '${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';

    return Container(
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        color: Color(0xFFF5EFEB),
      ),
      child: Column(
        children: [
          // Quantity selector buttons
          Container(
            width: 150,
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: AppColors.primaryRed,
            ),
            child: _BuildButtonQuantity(
              quantity: quantity,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            ),
          ),
          const SizedBox(height: 16),
          
          // Title and Price row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formattedPrice,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Info row (rating, calories, delivery time)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BuildInfoFood(
                icon: Icons.star,
                text: rating,
                iconColor: Colors.amber,
              ),
              const _BuildInfoFood(
                icon: Icons.local_fire_department,
                text: '150 KCal',
                iconColor: Color(0xFFFF5722),
                textColor: Color(0x80000000),
                fontWeight: FontWeight.w400,
              ),
              _BuildInfoFood(
                icon: Icons.timelapse,
                text: prepTime ?? '5-10 phút',
                iconColor: Colors.red,
                textColor: const Color(0x80000000),
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Scrollable description text
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                'Đây là biểu tượng ẩm thực đường phố độc đáo, gói trọn nét tinh tế và niềm tự hào của con người Việt.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black.withValues(alpha: 0.6),
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Add to cart button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            onPressed: onAddToCart,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.shopping_cart, size: 22, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Thêm vào giỏ hàng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildInfoFood extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final Color textColor;
  final FontWeight fontWeight;

  const _BuildInfoFood({
    required this.icon,
    required this.text,
    required this.iconColor,
    this.textColor = Colors.black,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 30, color: iconColor),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: fontWeight,
            color: textColor,
          ),
        ),
      ],
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
          icon: const Icon(Icons.remove, color: Colors.white, size: 25),
          onPressed: onDecrement,
        ),
        Text(
          '$quantity',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.white, size: 25),
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

class _FlyingFoodWidgetState extends State<FlyingFoodWidget> with SingleTickerProviderStateMixin {
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
        
        // Quadratic Bezier Curve logic
        final double controlX = widget.startOffset.dx + (widget.endOffset.dx - widget.startOffset.dx) * 0.3 + 90;
        final double controlY = widget.startOffset.dy - 120;
        
        final double x = (1 - t) * (1 - t) * widget.startOffset.dx +
            2 * (1 - t) * t * controlX +
            t * t * widget.endOffset.dx;
        final double y = (1 - t) * (1 - t) * widget.startOffset.dy +
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
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
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
          child: widget.image.startsWith('http')
              ? Image.network(widget.image, fit: BoxFit.cover)
              : Image.asset(widget.image, fit: BoxFit.cover),
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

class _CartIconButtonState extends State<CartIconButton> with SingleTickerProviderStateMixin {
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
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.35, end: 0.9), weight: 35),
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
    return ValueListenableBuilder<List<CartItem>>(
      valueListenable: CartManager.instance.itemsNotifier,
      builder: (context, items, child) {
        final int count = items.fold<int>(0, (sum, item) => sum + item.quantity);
        
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
              Navigator.push(context, createRoute(const CartPage()));
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 37,
                  height: 37,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
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
                      color: AppColors.primaryRed,
                      size: 20,
                    ),
                  ),
                ),
                if (count > 0)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) => ScaleTransition(
                        scale: animation,
                        child: child,
                      ),
                      child: Container(
                        key: ValueKey<int>(count),
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryRed,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
