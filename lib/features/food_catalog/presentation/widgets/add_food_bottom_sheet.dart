import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/food_service.dart';
import '../../../../core/services/auth_service.dart';
import '../pages/food_home_page.dart';

enum ImageMode { device, url, preset }

class AddFoodBottomSheet extends StatefulWidget {
  final Function(String category, MealData newMeal) onFoodAdded;

  const AddFoodBottomSheet({super.key, required this.onFoodAdded});

  @override
  State<AddFoodBottomSheet> createState() => _AddFoodBottomSheetState();
}

class _AddFoodBottomSheetState extends State<AddFoodBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController(text: '10-15 phút');
  final _caloriesController = TextEditingController(text: '350 KCal');

  String _selectedCategory = 'Bánh mỳ';
  ImageMode _imageMode = ImageMode.device;

  // Trạng thái ảnh chọn từ thiết bị
  XFile? _pickedFile;
  Uint8List? _pickedBytes;
  String? _pickedFileName;

  // Trạng thái ảnh có sẵn
  String _selectedPresetImage = 'assets/image/pho_ga.png';

  bool _isHot = true;
  bool _isDiscount = false;
  bool _isLoading = false;

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

  String _currentUserName = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserName();
  }

  Future<void> _fetchCurrentUserName() async {
    try {
      final cached = await AuthService.getUserName();
      if (cached != null && cached.isNotEmpty && mounted) {
        setState(() {
          _currentUserName = cached;
        });
      }
      final res = await AuthService.getCurrentUser();
      if (res['success'] == true && res['data'] != null) {
        final name = (res['data']['full_name'] as String?)?.trim();
        final username = (res['data']['username'] as String?)?.trim();
        final realName = (name != null && name.isNotEmpty)
            ? name
            : ((username != null && username.isNotEmpty)
                ? username
                : 'Lê Ngọc Duy');
        if (mounted) {
          setState(() {
            _currentUserName = realName;
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  // Phương thức chọn ảnh từ thiết bị
  Future<void> _pickImageFromDevice() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _pickedFile = image;
          _pickedBytes = bytes;
          _pickedFileName = image.name;
        });
      }
    } catch (e) {
      debugPrint('[AddFoodBottomSheet] Lỗi chọn ảnh: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chọn ảnh từ thiết bị: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (_isLoading) return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String finalImageUrl = _selectedPresetImage;

      // 1. Xử lý ảnh tùy thuộc vào ImageMode đã chọn
      if (_imageMode == ImageMode.device) {
        if (_pickedBytes == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Vui lòng chọn hình ảnh từ thiết bị hoặc chuyển sang chế độ khác!',
                ),
                backgroundColor: Colors.orange,
              ),
            );
            setState(() {
              _isLoading = false;
            });
          }
          return;
        }

        // Tải ảnh bytes lên máy chủ (FastAPI endpoint)
        final uploadedUrl = await FoodService.uploadImageBytes(
          _pickedBytes!,
          _pickedFileName ?? 'food_image.png',
        );

        if (uploadedUrl == null || uploadedUrl.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Tải ảnh lên máy chủ thất bại! Vui lòng kiểm tra kết nối mạng hoặc dùng URL / Ảnh mẫu.',
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
            setState(() {
              _isLoading = false;
            });
          }
          return;
        }
        finalImageUrl = uploadedUrl;
      } else if (_imageMode == ImageMode.url) {
        final urlText = _imageUrlController.text.trim();
        if (urlText.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vui lòng nhập đường dẫn URL hình ảnh!'),
                backgroundColor: Colors.orange,
              ),
            );
            setState(() {
              _isLoading = false;
            });
          }
          return;
        }
        finalImageUrl = urlText;
      } else {
        finalImageUrl = _selectedPresetImage;
      }

      final name = _nameController.text.trim();
      String rawPrice = _priceController.text.trim().replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      if (rawPrice.isEmpty) rawPrice = '30000';

      final priceNum = double.tryParse(rawPrice) ?? 30000.0;
      final formattedPrice = '${_formatNumber(priceNum.toInt())}đ';

      final description = _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : "Món ăn ngon và hấp dẫn, chuẩn vị nhà làm.";

      final duration = _durationController.text.trim().isNotEmpty
          ? _durationController.text.trim()
          : "10-15 phút";

      final calories = _caloriesController.text.trim().isNotEmpty
          ? _caloriesController.text.trim()
          : "350 KCal";

      // Payload gửi lên Backend API
      final foodData = {
        "name": name,
        "price": formattedPrice,
        "price_num": priceNum,
        "duration": duration,
        "calories": calories,
        "rating": "5.0",
        "image": finalImageUrl,
        "description": description,
        "category": _selectedCategory,
        "is_popular": _isHot,
        "is_discount": _isDiscount,
      };

      // Gọi API để lưu vào CSDL
      try {
        await FoodService.addFood(foodData);
      } catch (e) {
        debugPrint('[AddFoodBottomSheet] Error saving food: $e');
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      String author = _currentUserName;
      if (author.isEmpty || author == 'Nguyễn Văn A') {
        final cached = await AuthService.getUserName();
        if (cached != null && cached.isNotEmpty) {
          author = cached;
        } else {
          author = 'Lê Ngọc Duy';
        }
      }

      final newMeal = MealData(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        image: finalImageUrl,
        price: formattedPrice,
        rating: '5.0',
        soldCount: 'Mới tạo',
        isHot: _isHot,
        description: description,
        duration: duration,
        calories: calories,
        authorName: author,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
              // Thanh gạch kéo tay trên cùng
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
                  prefixIcon: const Icon(
                    Icons.fastfood_outlined,
                    color: AppColors.primaryRed,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primaryRed,
                      width: 2,
                    ),
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
                  prefixIcon: const Icon(
                    Icons.attach_money_rounded,
                    color: AppColors.primaryRed,
                  ),
                  suffixText: "đ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primaryRed,
                      width: 2,
                    ),
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
                  prefixIcon: const Icon(
                    Icons.category_outlined,
                    color: AppColors.primaryRed,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primaryRed,
                      width: 2,
                    ),
                  ),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
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

              // Nhập Mô tả món ăn
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Mô tả chi tiết món ăn",
                  hintText:
                      "Ví dụ: Bánh mì nướng giòn rụm kèm pate thơm ngon...",
                  prefixIcon: const Icon(
                    Icons.description_outlined,
                    color: AppColors.primaryRed,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primaryRed,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Thời gian chế biến & Lượng Calo
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      decoration: InputDecoration(
                        labelText: "Thời gian",
                        hintText: "10-15 phút",
                        prefixIcon: const Icon(
                          Icons.timer_outlined,
                          color: AppColors.primaryRed,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.primaryRed,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _caloriesController,
                      decoration: InputDecoration(
                        labelText: "Lượng Calo",
                        hintText: "350 KCal",
                        prefixIcon: const Icon(
                          Icons.local_fire_department_outlined,
                          color: AppColors.primaryRed,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.primaryRed,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- PHẦN HÌNH ẢNH MÓN ĂN ---
              const Text(
                "Hình ảnh món ăn",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Thanh chuyển chế độ chọn ảnh (Tabs)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildModeTab(
                      mode: ImageMode.device,
                      icon: Icons.photo_library_rounded,
                      label: "Từ thiết bị",
                    ),
                    _buildModeTab(
                      mode: ImageMode.url,
                      icon: Icons.link_rounded,
                      label: "Điền URL",
                    ),
                    _buildModeTab(
                      mode: ImageMode.preset,
                      icon: Icons.grid_view_rounded,
                      label: "Ảnh mẫu",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Nội dung hiển thị theo từng mode chọn ảnh
              if (_imageMode == ImageMode.device) ...[
                if (_pickedBytes == null)
                  InkWell(
                    onTap: _pickImageFromDevice,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryRed.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryRed.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_a_photo_rounded,
                              color: AppColors.primaryRed,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Bấm để chọn hình ảnh từ thiết bị",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryRed,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Hỗ trợ JPG, PNG, WEBP, GIF",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _pickedBytes!,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.image_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _pickedFileName ?? "Đã chọn ảnh",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _pickImageFromDevice,
                              icon: const Icon(Icons.edit_rounded, size: 16),
                              label: const Text("Đổi"),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryRed,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _pickedBytes = null;
                                  _pickedFile = null;
                                  _pickedFileName = null;
                                });
                              },
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              tooltip: "Xóa ảnh",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ] else if (_imageMode == ImageMode.url) ...[
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    labelText: "URL Hình ảnh (https://...)",
                    hintText: "https://example.com/food.jpg",
                    prefixIcon: const Icon(
                      Icons.link_rounded,
                      color: AppColors.primaryRed,
                    ),
                    suffixIcon: _imageUrlController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _imageUrlController.clear();
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.primaryRed,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {});
                  },
                ),
                if (_imageUrlController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    "Xem trước ảnh từ URL:",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _imageUrlController.text.trim(),
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          color: Colors.grey[200],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_rounded,
                                color: Colors.grey,
                                size: 36,
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Không thể tải ảnh từ URL này",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ] else if (_imageMode == ImageMode.preset) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _presetImages.map((preset) {
                      final isSelected =
                          _selectedPresetImage == preset['path'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPresetImage = preset['path']!;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryRed
                                  : Colors.grey[300]!,
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
                                  errorBuilder: (ctx, err, stack) =>
                                      const Icon(Icons.image, size: 50),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                preset['label']!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.primaryRed
                                      : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
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
                subtitle: const Text(
                  "Món ăn sẽ xuất hiện ở mục Phổ Biến Hôm Nay",
                ),
                value: _isHot,
                onChanged: (val) {
                  setState(() {
                    _isHot = val;
                  });
                },
              ),
              const SizedBox(height: 8),

              // Switch Đang giảm giá (Discount)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.primaryRed,
                title: const Text(
                  "Đặt làm Món Giảm Giá (Discount)",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: const Text(
                  "Món ăn sẽ có thẻ ưu đãi giảm giá đặc biệt",
                ),
                value: _isDiscount,
                onChanged: (val) {
                  setState(() {
                    _isDiscount = val;
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
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Đang xử lý...",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : const Row(
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

  Widget _buildModeTab({
    required ImageMode mode,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _imageMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _imageMode = mode;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.primaryRed : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.primaryRed : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
