import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/viewmodels/artisan_view_model.dart';

/// =============================================================
/// MAIN SCREEN
/// =============================================================
class Mesmessages extends StatefulWidget {
  const Mesmessages({super.key});

  @override
  State<Mesmessages> createState() => _MesmessagesState();
}

class _MesmessagesState extends State<Mesmessages> {
  int? _openUserId;
  String? _openUserName;
  String? _openUserPhoto;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       context.read<ArtisanViewModel>().loadProfile();  
      context.read<ArtisanViewModel>().fetchConversations();
    });
  }

  void _openConversation(int userId, String userName, String? photo) {
    setState(() {
      _openUserId = userId;
      _openUserName = userName;
      _openUserPhoto = photo;
    });
    context.read<ArtisanViewModel>().getConversation(userId);
  }

  void _backToInbox() {
    setState(() {
      _openUserId = null;
      _openUserName = null;
      _openUserPhoto = null;
    });
    context.read<ArtisanViewModel>().fetchConversations();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _openUserId == null,
      onPopInvoked: (didPop) {
        if (!didPop && _openUserId != null) _backToInbox();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AtlasAppBar(
          inConversation: _openUserId != null,
          conversationName: _openUserName,
          conversationPhoto: _openUserPhoto,
          onBack: _backToInbox,
        ),
        body: _openUserId != null
            ? ConversationBody(
                userId: _openUserId!,
                userName: _openUserName ?? '',
              )
            : MessagesBody(onTapConversation: _openConversation),
      ),
    );
  }
}

/// =============================================================
/// CUSTOM APP BAR
/// =============================================================
class AtlasAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool inConversation;
  final String? conversationName;
  final String? conversationPhoto;
  final VoidCallback? onBack;

  const AtlasAppBar({
    super.key,
    this.inConversation = false,
    this.conversationName,
    this.conversationPhoto,
    this.onBack,
  });

  @override
  Size get preferredSize => Size.fromHeight(inConversation ? 140 : 120);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5601A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ───── Top Row (same for both) ─────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Atlas Fix Logo (always visible)
                  Row(
                    children: [
                      const Text(
                        'Atlas',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Fix',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF5601A),
                          ),
                        ),
                      ),
                    ],
                  ),

                  /// Right icons (same for both)
                  Row(
                    children: const [
                      _AppBarIconBtn(icon: Icons.calendar_today_outlined),
                      SizedBox(width: 10),
                      _AppBarIconBtn(icon: Icons.notifications_outlined),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              /// ───── Bottom Row: Search OR Conversation Info ─────
              if (!inConversation)
                /// Search Bar
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 14),
                      Icon(Icons.search, color: Color(0xFFBBBBBB), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Quelle service recherchez-vous ?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFBBBBBB),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFF1A1A1A),
                          child: Icon(
                            Icons.tune,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                /// Conversation Info Row
                Row(
                  children: [
                    /// Back Button
                    GestureDetector(
                      onTap: onBack,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// Avatar with online dot
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundImage: conversationPhoto != null
                              ? NetworkImage(conversationPhoto!)
                              : null,
                          backgroundColor: Colors.white24,
                          child: conversationPhoto == null
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 22,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 1,
                          right: 1,
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 10),

                    /// Name + Online
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conversationName ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Online',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// Call + Video + More
                    const _AppBarIconBtn(icon: Icons.phone_outlined),
                    const SizedBox(width: 8),
                    const _AppBarIconBtn(icon: Icons.videocam_outlined),
                    const SizedBox(width: 8),
                    const _AppBarIconBtn(icon: Icons.more_vert),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBarIconBtn extends StatelessWidget {
  final IconData icon;
  const _AppBarIconBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

/// =============================================================
/// MESSAGES BODY (INBOX)
/// =============================================================
class MessagesBody extends StatelessWidget {
  final Function(int userId, String userName, String? photo) onTapConversation;

  const MessagesBody({super.key, required this.onTapConversation});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 40.0 : 16.0;

    return Consumer<ArtisanViewModel>(
      builder: (context, vm, _) {
        return RefreshIndicator(
          color: const Color(0xFFF5601A),
          onRefresh: () => vm.fetchConversations(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              28,
              horizontalPadding,
              MediaQuery.of(context).padding.bottom + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Messages",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Icon(Icons.chat_bubble_outline, color: Color(0xFFF5601A)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "Vos conversations avec les clients.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF494949),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                if (vm.loadingMessages)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: Color(0xFFF5601A),
                      ),
                    ),
                  )
                else if (vm.error != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            vm.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => vm.fetchConversations(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF5601A),
                            ),
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (vm.conversations.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(60),
                      child: Column(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Color(0xFFBBBBBB),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Aucun message pour l'instant",
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vm.conversations.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final conv = vm.conversations[index];
                      final otherUser =
                          conv['user'] as Map<String, dynamic>? ?? {};
                      final name = otherUser['name']?.toString() ?? 'Inconnu';
                      final lastMessage =
                          conv['last_message']?.toString() ?? '';
                      final unreadCount =
                          (conv['unread_count'] as num?)?.toInt() ?? 0;
                      final date = conv['date']?.toString();
                      final userId = (otherUser['id'] as num?)?.toInt() ?? 0;
                      final photo =
                          otherUser['profile_photo']?.toString() ??
                          'https://i.pravatar.cc/100?u=$userId';

                      return MessageItem(
                        name: name,
                        message: lastMessage,
                        time: _formatDate(date),
                        imageUrl: photo,
                        unread: unreadCount,
                        onTap: () => onTapConversation(userId, name, photo),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return date.toString();
    } catch (_) {
      return dateStr;
    }
  }
}

/// =============================================================
/// CONVERSATION BODY
/// =============================================================
class ConversationBody extends StatefulWidget {
  final int userId;
  final String userName;

  const ConversationBody({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<ConversationBody> createState() => _ConversationBodyState();
}

class _ConversationBodyState extends State<ConversationBody> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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

  Future<void> _sendMessage(ArtisanViewModel vm) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await vm.sendMessage(receiverId: widget.userId, message: text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ArtisanViewModel>(
      builder: (context, vm, _) {
        if (vm.loadingMessages && vm.messages.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFF5601A)),
          );
        }

        _scrollToBottom();

      return Column(
  children: [
    /// ───── Messages List ─────
    Expanded(
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        itemCount: vm.messages.length,
        itemBuilder: (context, index) {
          final msg = vm.messages[index];
         final isMe = (msg['sender_id'] as num?)?.toInt() == vm.artisanId;

          final showTime =
              index == 0 ||
              _isDifferentMinute(
                vm.messages[index - 1]['created_at']?.toString(),
                msg['created_at']?.toString(),
              );

          return Column(
            children: [
              if (showTime)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _formatTime(msg['created_at']?.toString() ?? ''),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ),
              _MessageBubble(
                message: msg['message']?.toString() ?? '',
                isMe: isMe,
              ),
            ],
          );
        },
      ),
    ),

    /// ───── Input Box ─────
    Container(
      // ✅ bottom padding accounts for the bottom nav bar (64px) + safe area
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      color: Colors.white,
      child: Row(
        children: [
          /// + Button
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 22),
          ),

          const SizedBox(width: 8),

          /// Text Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Écrivez votre message...',
                  hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(vm),
              ),
            ),
          ),

          const SizedBox(width: 8),

          /// Mic / Send Button
          GestureDetector(
            onTap: () => _sendMessage(vm),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFF5601A),
                shape: BoxShape.circle,
              ),
              child: vm.loadingMessages
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                         strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    ),
  ],
);
      },
    );
  }

  bool _isDifferentMinute(String? a, String? b) {
    if (a == null || b == null) return true;
    try {
      final da = DateTime.parse(a);
      final db = DateTime.parse(b);
      return da.hour != db.hour || da.minute != db.minute;
    } catch (_) {
      return false;
    }
  }

  String _formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final h = date.hour.toString().padLeft(2, '0');
      final m = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      final h12 = date.hour > 12 ? date.hour - 12 : date.hour;
      return '$h12:$m $period';
    } catch (_) {
      return dateStr;
    }
  }
}

/// =============================================================
/// MESSAGE ITEM WIDGET
/// =============================================================
class MessageItem extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final String imageUrl;
  final int unread;
  final bool online;
  final VoidCallback? onTap;

  const MessageItem({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    required this.imageUrl,
    this.unread = 0,
    this.online = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage(imageUrl),
                  onBackgroundImageError: (_, _) {},
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                if (online)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                if (unread > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5601A),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unread.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: unread > 0
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: unread > 0
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFF8E8E93),
                      fontWeight: unread > 0
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8E8E93)),
            ),
          ],
        ),
      ),
    );
  }
}

/// =============================================================
/// MESSAGE BUBBLE
/// 
/// 

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.70,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFFFE5D8) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
        ),
      ),
    );
  }
}
