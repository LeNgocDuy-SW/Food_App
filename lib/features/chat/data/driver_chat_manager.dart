import 'package:flutter/material.dart';

class DriverChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;

  DriverChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });
}

class DriverChatManager {
  static final DriverChatManager instance = DriverChatManager._internal();
  DriverChatManager._internal();

  final ValueNotifier<List<DriverChatMessage>> messagesNotifier =
      ValueNotifier<List<DriverChatMessage>>([
        DriverChatMessage(
          text: 'Tôi đang nhận món tại cửa hàng, sẽ giao tới ngay ạ!',
          isMe: false,
          time: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ]);

  List<DriverChatMessage> get messages => messagesNotifier.value;

  String get lastMessageText {
    if (messages.isEmpty) return 'Chưa có tin nhắn';
    return messages.last.text;
  }

  void sendMessage(String text) {
    final list = List<DriverChatMessage>.from(messages);
    list.add(DriverChatMessage(text: text, isMe: true, time: DateTime.now()));
    messagesNotifier.value = list;

    // Phản hồi tự động mô phỏng tài xế sau 3 giây rất thực tế
    Future.delayed(const Duration(seconds: 3), () {
      final updatedList = List<DriverChatMessage>.from(messagesNotifier.value);
      updatedList.add(
        DriverChatMessage(
          text: 'Dạ vâng, tôi đang trên đường giao tới bạn rồi nhé, khoảng 10 phút nữa tôi tới ạ!',
          isMe: false,
          time: DateTime.now(),
        ),
      );
      messagesNotifier.value = updatedList;
    });
  }
}
