import 'package:flutter/material.dart';
import 'package:my_app/view/client/Home/navbottom.dart';
import 'package:provider/provider.dart';
import 'package:my_app/viewmodels/client_view_model.dart';

class SendMessage extends StatefulWidget {
  final int initialUserId;
  final String initialUserName;
  final String? initialUserPhoto;

  const SendMessage({
    super.key,
    required this.initialUserId,
    required this.initialUserName,
    this.initialUserPhoto,
  });

  @override
  State<SendMessage> createState() => _SendMessageState();
}

class _SendMessageState extends State<SendMessage> {
  late int _openUserId;
  late String _openUserName;
  String? _openUserPhoto;

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _openUserId = widget.initialUserId;
    _openUserName = widget.initialUserName;
    _openUserPhoto = widget.initialUserPhoto;

    /// 🔥 AUTO LOAD CONVERSATION
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ClientViewModel>().getConversation(_openUserId);
      _scrollToBottom();
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

  Future<void> _sendMessage(ClientViewModel vm) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    await vm.sendMessage(receiverId: _openUserId, message: text);

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      /// SAME APP BAR
      appBar: AtlasAppBar(
        inConversation: true,
        conversationName: _openUserName,
        conversationPhoto: _openUserPhoto,
      ),

      body: Consumer<ClientViewModel>(
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

                    final isMe =
                        (msg['sender_id'] as num?)?.toInt() == vm.user?.id;

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

                        /// SAME MESSAGE BUBBLE
                        _MessageBubble(
                          message: msg['message']?.toString() ?? '',
                          isMe: isMe,
                        ),
                      ],
                    );
                  },
                ),
              ),

              /// ───── SAME INPUT BOX ─────
              Container(
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
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 22,
                      ),
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

                    /// Send Button
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
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 20,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    
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

/// CUSTOM APP BAR
/// =============================================================
class AtlasAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool inConversation;
  final String? conversationName;
  final String? conversationPhoto;

  const AtlasAppBar({
    super.key,
    this.inConversation = false,
    this.conversationName,
    this.conversationPhoto,
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
                      onTap: () {

                        Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeShellC()),
    );

                      },
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

/// ==========
/// MESSAGE BUBBLE
/// =============================================================
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
            BoxShadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 2)),
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
