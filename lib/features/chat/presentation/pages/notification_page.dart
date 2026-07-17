import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widget.dart';
import '../../data/driver_chat_manager.dart';
import 'package:food_app/core/router/app_router.dart';

class NotificationPage extends StatelessWidget {
  final bool showBackButton;

  const NotificationPage({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: BackgroundContainer(
        opacity: 0.15,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom AppBar
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
                        if (showBackButton)
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
                          'Thông báo',
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
                        Icons.notifications_active_outlined,
                        color: AppColors.primaryRed,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              // Notification List
              Expanded(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  children: [
                    _buildSectionTitle('Mới nhất'),
                    _buildNotificationItem(
                      context,
                      name: 'Duy đồ ăn',
                      action: 'đã bình luận về món ăn của bạn',
                      content:
                          '"Món này nhìn ngon quá, công thức thế nào vậy?"',
                      time: '5 phút trước',
                      isUnread: true,
                      isChat: false,
                      icon: Icons.comment,
                      iconColor: Colors.blue,
                    ),
                    ValueListenableBuilder<List<DriverChatMessage>>(
                      valueListenable: DriverChatManager.instance.messagesNotifier,
                      builder: (context, messages, child) {
                        final lastMsg = messages.isNotEmpty ? messages.last : null;
                        if (lastMsg == null) return const SizedBox.shrink();
                        
                        return _buildNotificationItem(
                          context,
                          name: 'Tài xế Nguyễn Văn Hùng',
                          action: 'đã gửi tin nhắn cho bạn',
                          content: '"${lastMsg.text}"',
                          time: 'Vừa xong',
                          isUnread: !lastMsg.isMe,
                          isChat: true,
                          isDriverChat: true,
                          icon: Icons.delivery_dining_rounded,
                          iconColor: Colors.blue,
                        );
                      },
                    ),
                    _buildNotificationItem(
                      context,
                      name: 'Lan Nguyễn',
                      action: 'đã gửi cho bạn một tin nhắn',
                      content: '"Cuối tuần này đi ăn phở cuốn không?"',
                      time: '15 phút trước',
                      isUnread: true,
                      isChat: true,
                      icon: Icons.chat_bubble,
                      iconColor: AppColors.primaryRed,
                    ),
                    _buildNotificationItem(
                      context,
                      name: 'Hệ thống',
                      action: 'Khuyến mãi đặc biệt',
                      content:
                          'Giảm 50% cho tất cả đơn hàng từ 200k. Đặt ngay kẻo lỡ!',
                      time: '1 giờ trước',
                      isUnread: true,
                      isChat: false,
                      isSystem: true,
                      icon: Icons.local_offer,
                      iconColor: Colors.orange,
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(color: Colors.black12, height: 1),
                    ),

                    _buildSectionTitle('Trước đó'),
                    _buildNotificationItem(
                      context,
                      name: 'Duy đồ ăn',
                      action: 'đã đăng một món mới',
                      content: 'Bún bò Huế chuẩn vị nhà làm',
                      time: 'Hôm qua, 14:30',
                      isUnread: false,
                      isChat: false,
                      icon: Icons.restaurant,
                      iconColor: Colors.green,
                    ),
                    _buildNotificationItem(
                      context,
                      name: 'Minh Trần',
                      action: 'đã thích đánh giá của bạn',
                      content: 'Đánh giá quán phở "Thìn"',
                      time: 'Hôm qua, 09:15',
                      isUnread: false,
                      isChat: false,
                      icon: Icons.favorite,
                      iconColor: Colors.redAccent,
                    ),
                    _buildNotificationItem(
                      context,
                      name: 'Duy đồ ăn',
                      action: 'đã gửi cho bạn một tin nhắn',
                      content: '"Ok chốt nhé! Hẹn gặp bạn lúc 7 giờ tối."',
                      time: '2 ngày trước',
                      isUnread: false,
                      isChat: true,
                      icon: Icons.chat_bubble,
                      iconColor: AppColors.primaryRed,
                    ),
                    _buildNotificationItem(
                      context,
                      name: 'Hệ thống',
                      action: 'Cập nhật ứng dụng',
                      content:
                          'Phiên bản mới đã sẵn sàng với nhiều tính năng hấp dẫn và mượt mà hơn.',
                      time: '3 ngày trước',
                      isUnread: false,
                      isChat: false,
                      isSystem: true,
                      icon: Icons.update,
                      iconColor: Colors.purple,
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
      padding: const EdgeInsets.only(top: 8, bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Colors.black54,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required String name,
    required String action,
    required String content,
    required String time,
    required bool isUnread,
    required bool isChat,
    bool isDriverChat = false,
    bool isSystem = false,
    required IconData icon,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () {
        if (isDriverChat) {
          context.push(AppRouter.driverChatDetail);
        } else if (isChat) {
          context.push(AppRouter.chatDetail);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? Colors.white : const Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isUnread
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
          border: Border.all(
            color: isUnread
                ? Colors.transparent
                : Colors.grey.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Avatar / Icon
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSystem
                        ? iconColor.withOpacity(0.1)
                        : Colors.transparent,
                    image: isSystem
                        ? null
                        : const DecorationImage(
                            image: AssetImage('assets/image/avatar.png'),
                            fit: BoxFit.cover,
                          ),
                    border: Border.all(
                      color: isSystem ? Colors.transparent : Colors.black12,
                      width: 1,
                    ),
                  ),
                  child: isSystem
                      ? Icon(icon, color: iconColor, size: 26)
                      : null,
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(icon, color: Colors.white, size: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                      children: [
                        TextSpan(
                          text: '$name ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: action,
                          style: const TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUnread ? Colors.black87 : Colors.black54,
                      fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isUnread) ...[
              const SizedBox(width: 8),
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
