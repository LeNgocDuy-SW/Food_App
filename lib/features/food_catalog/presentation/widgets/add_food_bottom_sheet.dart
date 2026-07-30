import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../pages/food_home_page.dart';

class AddFoodBottomSheet extends StatefulWidget {
  final Function(String category, MealData newMeal) onFoodAdded;

  const AddFoodBottomSheet({
    super.key,
    required this.onFoodAdded,
  });

  @override
  State<AddFoodBottomSheet> createState() => _AddFoodBottomSheetState();
}

class _AddFoodBottomSheetState extends State<AddFoodBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedCategory = 'Bánh mỳ';
  String _selectedPresetImage = 'assets/image/pho_ga.png';
  bool _isHot = true;
  bool _isCustomImage = false;

  final List<String> _categories = [
    'Bánh mỳ',
    'Phở gà',
    'Hamberger',
    'Bún bò Huế',
    'Thịt bò',
    'Hải sản',
    'Gà rán',
    'Trà sữa',
  ];

  final List<Map<String, String>> _presetImages = [
    {'label': 'Phở Gà', 'path': 'assets/image/pho_ga.png'},
    {'label': 'Hamburger', 'path': 'assets/image/hamberger.png'},
    {'label': 'Món Rán', 'path': 'assets/image/cooking_burger.png'},
    {'label': 'Banner Món', 'path': 'assets/image/food_banner.png'},
    {'label': 'Banner 2', 'path': 'assets/image/banner.png'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      String rawPrice = _priceController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
      if (rawPrice.isEmpty) rawPrice = '30000';
      
      // Format price with dots (e.g., 35.000đ)
      final priceNum = int.tryParse(rawPrice) ?? 30000;
      final formattedPrice = '${_formatNumber(priceNum)}đ';

      final image = _isCustomImage && _imageUrlController.text.trim().isNotEmpty
          ? _imageUrlController.text.trim()
          : _selectedPresetImage;

      final newMeal = MealData(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        image: image,
        price: formattedPrice,
        rating: '5.0',
        soldCount: 'Mới tạo',
        isHot: _isHot,
      );

      widget.onFoodAdded(_selectedCategory, newMeal);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Đã thêm món "$name" thành công!',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: bottomPadding + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh gạch chỉ tay trên cùng
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Tiêu đề
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      color: AppColors.primaryRed,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Thêm Món Ăn Mới",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Nhập Tên món
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Tên món ăn",
                  hintText: "Ví dụ: Bánh mỳ pate nướng giòn",
                  prefixIcon: const Icon(Icons.fastfood_outlined, color: AppColors.primaryRed),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên món ăn';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nhập Giá tiền
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Giá tiền (VNĐ)",
                  hintText: "Ví dụ: 35000",
                  prefixIcon: const Icon(Icons.attach_money_rounded, color: AppColors.primaryRed),
                  suffixText: "đ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập giá tiền';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Chọn Danh mục
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: "Danh mục món",
                  prefixIcon: const Icon(Icons.category_outlined, color: AppColors.primaryRed),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
                  ),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategory = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Chọn hình ảnh
              const Text(
                "Hình ảnh minh họa",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ..._presetImages.map((preset) {
                      final isSelected = !_isCustomImage && _selectedPresetImage == preset['path'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCustomImage = false;
                            _selectedPresetImage = preset['path']!;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryRed : Colors.grey[300]!,
                              width: isSelected ? 2.5 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  preset['path']!,
                                  width: 55,
                                  height: 55,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => const Icon(Icons.image, size: 50),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                preset['label']!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? AppColors.primaryRed : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isCustomImage = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _isCustomImage ? AppColors.primaryRed : Colors.grey[300]!,
                            width: _isCustomImage ? 2.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.link_rounded,
                              color: _isCustomImage ? AppColors.primaryRed : Colors.grey[600],
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Tự nhập URL",
                              style: TextStyle(
                                fontSize: 11,
                                color: _isCustomImage ? AppColors.primaryRed : Colors.grey[700],
                                fontWeight: _isCustomImage ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_isCustomImage) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    labelText: "URL Hình ảnh (https://...)",
                    prefixIcon: const Icon(Icons.image_outlined, color: AppColors.primaryRed),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Switch Món Hot / Phổ biến
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primaryRed,
                title: const Text(
                  "Đặt làm Món Phổ Biến (HOT)",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: const Text("Món ăn sẽ xuất hiện ở mục Phổ Biến Hôm Nay"),
                value: _isHot,
                onChanged: (val) {
                  setState(() {
                    _isHot = val;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Nút Thêm Món
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primaryRed.withValues(alpha: 0.4),
                  ),
                  onPressed: _submitForm,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, size: 24),
                      SizedBox(width: 8),
                      Text(
                        "Thêm Món Ăn Mới",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
