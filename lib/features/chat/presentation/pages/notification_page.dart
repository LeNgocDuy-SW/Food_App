import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget.dart';
import 'chat_detail_page.dart';

class NotificationPage extends StatelessWidget {
  final bool showBackButton;

  const NotificationPage({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        opacity: 0.5,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (showBackButton)
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                                size: 28,
                              ),
                            ),
                          ),
                        const Text(
                          'Thông báo',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.notifications,
                      color: AppColors.primaryRed,
                      size: 28,
                    ),
                  ],
                ),
              ),
              // Notification List
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildSectionTitle('Mới'),
                    _buildNotificationItem(
                      context,
                      title: 'Duy đồ ăn đã đăng một món mới',
                      hasBadge: false,
                      isChat: false,
                    ),
                    _buildNotificationItem(
                      context,
                      title: 'Duy đồ ăn đã gửi cho bạn một tin nhắn',
                      hasBadge: true,
                      isChat: true,
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Trước đó'),
                    _buildNotificationItem(
                      context,
                      title: 'Duy đồ ăn đã gửi cho bạn một tin nhắn',
                      hasBadge: true,
                      isChat: true,
                    ),
                    _buildNotificationItem(
                      context,
                      title: 'Duy đồ ăn đã gửi cho bạn một tin nhắn',
                      hasBadge: true,
                      isChat: true,
                    ),
                    _buildNotificationItem(
                      context,
                      title: 'Duy đồ ăn đã gửi cho bạn một tin nhắn',
                      hasBadge: true,
                      isChat: true,
                    ),
                    _buildNotificationItem(
                      context,
                      title: 'Duy đồ ăn đã gửi cho bạn một tin nhắn',
                      hasBadge: true,
                      isChat: true,
                    ),
                    _buildNotificationItem(
                      context,
                      title: 'Duy đồ ăn đã gửi cho bạn một tin nhắn',
                      hasBadge: true,
                      isChat: true,
                    ),
                    _buildNotificationItem(
                      context,
                      title: 'Duy đồ ăn đã gửi cho bạn một tin nhắn',
                      hasBadge: false,
                      isChat: true,
                    ),
                    _buildNotificationItem(
                      context,
                      title: 'Duy đồ ăn đã gửi cho bạn một tin nhắn',
                      hasBadge: true,
                      isChat: true,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required String title,
    required bool hasBadge,
    required bool isChat,
  }) {
    return GestureDetector(
      onTap: () {
        if (isChat) {
          Navigator.push(context, createRoute(const ChatDetailPage()));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5EFEB),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: hasBadge ? AppColors.blueLight.withValues(alpha: 0.3) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // User Avatar with potential notification badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: AssetImage('assets/image/avatar.png'),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
                if (hasBadge)
                  Positioned(
                    top: -4,
                    left: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF22323),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_bubble,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Text Content
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  children: [
                    const TextSpan(
                      text: 'Duy đồ ăn ',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    TextSpan(
                      text: title.substring(10),
                      style: const TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
