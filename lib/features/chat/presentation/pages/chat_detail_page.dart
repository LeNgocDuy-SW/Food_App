import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/widget.dart';

class ChatMessage {
  final String text;
  final bool isMe;
  final bool hasHeart;

  ChatMessage({required this.text, required this.isMe, this.hasHeart = false});
}

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({super.key});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Bạn đã chọn được món cho ngày hôm nay chưa?',
      isMe: false,
    ),
    ChatMessage(
      text: 'Tôi đang suy nghĩ... Bạn gợi ý cho tôi được không?',
      isMe: true,
    ),
    ChatMessage(
      text:
          'Hôm nay thời tiết khá nóng. Bạn có có thể ăn một số món mát mát một chút',
      isMe: false,
    ),
    ChatMessage(
      text: 'Như Salad chẳng hạn, hoặc thịt luộc với rau muống.',
      isMe: false,
    ),
    ChatMessage(
      text: 'Ồ, có lẽ đó là một ý kiến hay. Cảm ơn ý tưởng của bạn.',
      isMe: true,
      hasHeart: true,
    ),
    ChatMessage(
      text: 'Dạ, vâng ạ, không có gì ạ😊😊',
      isMe: false,
      hasHeart: true,
    ),
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isMe: true));
    });
    _controller.clear();
    _scrollToBottom();

    // Auto response
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              text:
                  'Dạ, quán luôn sẵn sàng phục vụ bạn ạ! Bạn cần thêm gì cứ nhắn mình nha ❤️',
              isMe: false,
            ),
          );
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        opacity: 0.5,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Chat AppBar
              _buildAppBar(context),
              // Message List
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Top Center Profile info
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: const AssetImage(
                          'assets/image/avatar.png',
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Duy đồ ăn',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Hôm nay 07:10',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Messages
                      ..._messages.map((msg) => _buildMessageBubble(msg)),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Input bar
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/image/avatar.png'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Duy đồ ăn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Đang hoạt động',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final avatarWidget = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: const DecorationImage(
          image: AssetImage('assets/image/avatar.png'),
          fit: BoxFit.cover,
        ),
        border: Border.all(color: Colors.white, width: 1),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: msg.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isMe) ...[avatarWidget, const SizedBox(width: 8)],
          Column(
            crossAxisAlignment: msg.isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: msg.isMe ? const Color(0xFFF5EFEB) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(msg.isMe ? 20 : 4),
                    bottomRight: Radius.circular(msg.isMe ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  msg.text,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
              if (msg.hasHeart)
                const Padding(
                  padding: EdgeInsets.only(top: 4, right: 8, left: 8),
                  child: Icon(
                    Icons.favorite,
                    color: Color(0xFFF22323),
                    size: 16,
                  ),
                ),
            ],
          ),
          if (msg.isMe) ...[const SizedBox(width: 8), avatarWidget],
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFF5EFEB),
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Media actions
          IconButton(
            icon: const Icon(
              Icons.add_circle,
              color: Color(0xFFF22323),
              size: 24,
            ),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.camera_alt,
              color: Color(0xFFF22323),
              size: 24,
            ),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.image, color: Color(0xFFF22323), size: 24),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          // Input text field
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _sendMessage(),
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Heart or Send action button
          IconButton(
            icon: const Icon(
              Icons.favorite,
              color: Color(0xFFF22323),
              size: 28,
            ),
            onPressed: _sendMessage,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
