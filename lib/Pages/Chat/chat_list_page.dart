import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Api/Services/peer_chat_repository.dart';
import 'package:home_care/Config/colors_coning.dart';
import 'package:home_care/Pages/Chat/chat_room_page.dart';

/// Lists all peer conversations (user ↔ provider) for the logged-in patient.
class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final _repo = PeerChatRepository();
  List<Conversation> _convs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await _repo.getMyConversations();
    res.when(
      onSuccess: (list) => setState(() => _convs = list),
      onError: (_) => setState(() => _convs = []),
    );
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text('Messages',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: kPrimary))
          : _convs.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: kPrimary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _convs.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (_, i) =>
                        _ConvCard(conv: _convs[i], onTap: () async {
                          await Get.to(() =>
                              ChatRoomPage(conversation: _convs[i]));
                          _load(); // refresh unread counts on return
                        }),
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.06),
                shape: BoxShape.circle),
            child: Icon(Icons.chat_bubble_outline_rounded,
                size: 48, color: kPrimary.withValues(alpha: 0.35)),
          ),
          const SizedBox(height: 16),
          const Text('No messages yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kTextDark)),
          const SizedBox(height: 8),
          const Text(
            'After your booking is accepted you can\nchat with your provider here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: kTextMedium),
          ),
        ],
      ),
    );
  }
}

// ── Conversation card ─────────────────────────────────────────────────────────

class _ConvCard extends StatelessWidget {
  final Conversation conv;
  final VoidCallback onTap;
  const _ConvCard({required this.conv, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = conv.unreadPatient;
    final initial = conv.otherPartyName.isNotEmpty
        ? conv.otherPartyName[0].toUpperCase()
        : 'P';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                    colors: [kPrimary, kPrimaryMid],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                boxShadow: [
                  BoxShadow(
                      color: kPrimary.withValues(alpha: 0.3),
                      blurRadius: 6)
                ],
              ),
              child: Center(
                child: Text(initial,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(conv.otherPartyName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: kTextDark)),
                        if (conv.lastMessageAt != null)
                          Text(
                            _formatTime(conv.lastMessageAt!),
                            style: const TextStyle(
                                fontSize: 11, color: kTextLight),
                          ),
                      ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    Expanded(
                      child: Text(
                        conv.lastMessage.isEmpty
                            ? 'Tap to start chatting'
                            : conv.lastMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: unread > 0
                              ? kTextDark
                              : kTextMedium,
                          fontWeight: unread > 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (unread > 0)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                            color: kPrimary,
                            shape: BoxShape.circle),
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.day == now.day &&
        dt.month == now.month &&
        dt.year == now.year) {
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m ${dt.hour < 12 ? 'AM' : 'PM'}';
    }
    return '${dt.day}/${dt.month}';
  }
}
