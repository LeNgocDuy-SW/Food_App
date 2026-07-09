import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food_app/core/constants/app_colors.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  final List<Map<String, dynamic>> _bannerData = [
    {
      'title1': 'Ăn gì khó ?\nCó ',
      'titleHighlight': 'VNFood',
      'title2': ' lo!',
      'image': 'assets/image/banner.png',
      'backgroundColor': const Color(0xFFEB9C6C),
    },
    {
      'title1': 'Khuyến mãi khủng\nĐồng giá ',
      'titleHighlight': '25K',
      'title2': '!',
      'image': 'assets/image/food_banner.png',
      'backgroundColor': const Color(0xFFE57373),
    },
    {
      'title1': 'Hải sản tươi ngon\nGiao hàng ',
      'titleHighlight': '15 Phút',
      'title2': '!',
      'image': 'assets/image/cooking_burger.png',
      'backgroundColor': const Color(0xFF81C784),
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _bannerData.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 155,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _bannerData.length,
              itemBuilder: (context, index) {
                final item = _bannerData[index];
                return Container(
                  color: item['backgroundColor'],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                  height: 1.3,
                                ),
                                children: [
                                  TextSpan(text: item['title1']),
                                  TextSpan(
                                    text: item['titleHighlight'],
                                    style: const TextStyle(
                                      color: AppColors.primaryRed,
                                    ),
                                  ),
                                  TextSpan(text: item['title2']),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 6,
                                ),
                                backgroundColor: AppColors.primaryRed,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Mua Ngay',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Image.asset(
                        item['image'],
                        height: 217,
                        width: 155,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                );
              },
            ),
            // Indicator dots
            Positioned(
              bottom: 12,
              left: 24,
              child: Row(
                children: List.generate(_bannerData.length, (index) {
                  final isActive = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 6),
                    height: 6,
                    width: isActive ? 18 : 6,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primaryRed : Colors.white60,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
