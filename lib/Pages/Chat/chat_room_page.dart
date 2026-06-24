import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Api/Config/api_config.dart';
import 'package:home_care/Api/Services/peer_chat_repository.dart';
import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Config/colors_coning.dart';
import 'package:home_care/Pages/Call/video_call_page.dart';
import 'package:home_care/utils/token_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

/// Real-time peer chat room between patient and provider.
/// Messages are delivered via WebSocket and persisted via REST.
class ChatRoomPage extends StatefulWidget {
  final Conversation conversation;
  const ChatRoomPage({super.key, required this.conversation});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final _repo    = PeerChatRepository();
  final _client  = ApiClient();
  final _input   = TextEditingController();
  final _scroll  = ScrollController();
  bool _calling  = false;

  List<PeerMsg> _msgs = [];
  bool _loading = true;
  bool _sending = false;
  String _myUserId = '';

  // WebSocket for real-time delivery
  WebSocket? _ws;
  Timer? _wsReconnect;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _disposed = true;
    _ws?.close();
    _wsReconnect?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _myUserId = await TokenStorage.getUserId() ?? '';
    await _loadHistory();
    _connectWs();
    // Mark messages read when entering the room
    _repo.markRead(widget.conversation.id);
  }

  Future<void> _loadHistory() async {
    final res = await _repo.getMessages(widget.conversation.id);
    res.when(
      onSuccess: (msgs) =>
          setState(() { _msgs = msgs; _loading = false; }),
      onError: (_) => setState(() => _loading = false),
    );
    _scrollToBottom();
  }

  // ── WebSocket ───────────────────────────────────────────────────────────

  Future<void> _connectWs() async {
    if (_disposed) return;
    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) return;
      final wsBase = ApiConfig.baseUrl
          .replaceFirst('https://', 'wss://')
          .replaceFirst('http://', 'ws://')
          .replaceAll('/api', '');
      _ws = await WebSocket.connect(
              '$wsBase/api/ws?token=${Uri.encodeComponent(token)}')
          .timeout(const Duration(seconds: 10));
      if (_disposed) { _ws?.close(); return; }
      _ws!.listen(_onWsMsg,
          onDone: _scheduleReconnect,
          onError: (_) => _scheduleReconnect(),
          cancelOnError: false);
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _ws = null;
    _wsReconnect?.cancel();
    _wsReconnect = Timer(const Duration(seconds: 4), () {
      if (!_disposed) _connectWs();
    });
  }

  void _onWsMsg(dynamic raw) {
    try {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      if (msg['type'] != 'peer_chat') return;
      final rawP = msg['payload'];
      final p = rawP is String
          ? jsonDecode(rawP) as Map<String, dynamic>
          : Map<String, dynamic>.from(rawP as Map);
      if (p['conversation_id'] != widget.conversation.id) return;
      final incoming = PeerMsg(
        id: p['message_id'] ?? '',
        conversationId: p['conversation_id'] ?? '',
        senderId: p['sender_id'] ?? '',
        content: p['content'] ?? '',
        messageType: p['message_type'] ?? 'text',
        isRead: false,
        createdAt: p['created_at'] != null
            ? DateTime.tryParse(p['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
      if (mounted) {
        setState(() => _msgs.add(incoming));
        _scrollToBottom();
        _repo.markRead(widget.conversation.id);
      }
    } catch (_) {}
  }

  // ── Send ────────────────────────────────────────────────────────────────

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _sending) return;
    _input.clear();

    // Optimistic bubble
    final optimistic = PeerMsg(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      conversationId: widget.conversation.id,
      senderId: _myUserId,
      content: text,
      messageType: 'text',
      isRead: false,
      createdAt: DateTime.now(),
    );
    setState(() { _msgs.add(optimistic); _sending = true; });
    _scrollToBottom();

    final res = await _repo.sendMessage(
        convId: widget.conversation.id, content: text);
    res.when(
      onSuccess: (saved) {
        // Replace optimistic with persisted message
        if (mounted) {
          setState(() {
            final idx =
                _msgs.indexWhere((m) => m.id == optimistic.id);
            if (idx != -1) _msgs[idx] = saved;
          });
        }
      },
      onError: (_) {
        // Remove optimistic on failure
        if (mounted) {
          setState(() => _msgs.removeWhere((m) => m.id == optimistic.id));
          Get.snackbar('Error', 'Message failed. Please retry.',
              snackPosition: SnackPosition.BOTTOM);
        }
      },
    );
    if (mounted) setState(() => _sending = false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    });
  }

  // ── Media ────────────────────────────────────────────────────────────────

  Future<void> _pickFromCamera() async {
    final picked = await ImagePicker().pickImage(
        source: ImageSource.camera, imageQuality: 75, maxWidth: 1280);
    if (picked == null) return;
    await _sendMedia(File(picked.path), 'image');
  }

  Future<void> _pickFromGallery() async {
    final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 75, maxWidth: 1280);
    if (picked == null) return;
    await _sendMedia(File(picked.path), 'image');
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;
    final ext = path.split('.').last.toLowerCase();
    final type = ext == 'pdf' ? 'pdf' : 'file';
    await _sendMedia(File(path), type);
  }

  Future<void> _sendMedia(File file, String type) async {
    if (_sending) return;
    setState(() => _sending = true);

    // Optimistic placeholder
    final optimisticId = '${DateTime.now().microsecondsSinceEpoch}';
    final optimistic = PeerMsg(
      id: optimisticId,
      conversationId: widget.conversation.id,
      senderId: _myUserId,
      content: type == 'image' ? '' : file.path.split('/').last,
      messageType: type,
      fileUrl: type == 'image' ? file.path : '', // local path for preview
      fileName: file.path.split('/').last,
      isRead: false,
      createdAt: DateTime.now(),
    );
    setState(() => _msgs.add(optimistic));
    _scrollToBottom();

    // Upload
    final uploadRes = await _repo.uploadFile(file);
    if (!mounted) return;

    uploadRes.when(
      onSuccess: (meta) async {
        final fileUrl  = meta['file_url']  as String? ?? '';
        final fileName = meta['file_name'] as String? ?? '';
        final fileSize = meta['file_size'] as String? ?? '';

        // Send message with file URL
        final msgRes = await _repo.sendMessage(
          convId: widget.conversation.id,
          content: type == 'image' ? '' : fileName,
          messageType: type,
          fileUrl: fileUrl,
          fileName: fileName,
          fileSize: fileSize,
        );
        if (!mounted) return;
        msgRes.when(
          onSuccess: (saved) => setState(() {
            final idx = _msgs.indexWhere((m) => m.id == optimisticId);
            if (idx != -1) _msgs[idx] = saved;
          }),
          onError: (_) => setState(
              () => _msgs.removeWhere((m) => m.id == optimisticId)),
        );
      },
      onError: (err) {
        setState(() => _msgs.removeWhere((m) => m.id == optimisticId));
        Get.snackbar('Upload Failed', err,
            snackPosition: SnackPosition.BOTTOM);
      },
    );
    if (mounted) setState(() => _sending = false);
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildInputBar(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    final name = widget.conversation.otherPartyName;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';
    return AppBar(
      backgroundColor: kPrimary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Get.back(),
      ),
      titleSpacing: 0,
      title: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          child: Center(
            child: Text(initial,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              Text('Booking #${widget.conversation.bookingId.substring(0, 8)}',
                  style: const TextStyle(
                      color: Colors.white60, fontSize: 11)),
            ],
          ),
        ),
      ]),
      actions: [
        IconButton(
          tooltip: 'Video Call',
          icon: _calling
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.videocam_rounded, color: Colors.white),
          onPressed: _calling ? null : _startVideoCall,
        ),
      ],
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(bottom: Radius.circular(0))),
    );
  }

  Future<void> _startVideoCall() async {
    setState(() => _calling = true);
    try {
      final res = await _client.post('calls', {
        'booking_id': widget.conversation.bookingId,
        'callee_id':  widget.conversation.otherPartyId,
      }, requiresAuth: true);

      final data = (res['data'] as Map?)?.cast<String, dynamic>() ?? {};
      final callId = data['call_id'] as String? ?? '';
      if (callId.isEmpty) throw Exception('No call_id');

      if (!mounted) return;
      Get.to(() => VideoCallPage(
            callId:       callId,
            remoteUserId: widget.conversation.otherPartyId,
            remoteName:   widget.conversation.otherPartyName,
            bookingId:    widget.conversation.bookingId,
            isCaller:     true,
          ));
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceAll('Exception: ', '');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar('Call Failed', msg,
              backgroundColor: kError.withValues(alpha: 0.9),
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
        });
      }
    } finally {
      if (mounted) setState(() => _calling = false);
    }
  }

  Widget _buildMessageList() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: kPrimary));
    }
    if (_msgs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline_rounded,
                size: 56, color: kPrimary.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            const Text('No messages yet.\nSay hello! 👋',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: kTextMedium, fontSize: 14)),
          ],
        ),
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _msgs.length,
      itemBuilder: (_, i) {
        final msg  = _msgs[i];
        final isMine = msg.senderId == _myUserId;
        // Show date divider when the date changes
        final showDate = i == 0 ||
            !_sameDay(_msgs[i - 1].createdAt, msg.createdAt);
        return Column(
          children: [
            if (showDate) _DateDivider(msg.createdAt),
            _Bubble(msg: msg, isMine: isMine),
          ],
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Media buttons ───────────────────────────────────────────
          _MediaBtn(
              icon: Icons.camera_alt_rounded,
              color: kPrimary,
              onTap: _sending ? null : _pickFromCamera),
          _MediaBtn(
              icon: Icons.photo_library_rounded,
              color: kSuccess,
              onTap: _sending ? null : _pickFromGallery),
          _MediaBtn(
              icon: Icons.attach_file_rounded,
              color: kWarning,
              onTap: _sending ? null : _pickFile),
          const SizedBox(width: 4),

          // ── Text field ──────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FB),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: kBorder),
              ),
              child: TextField(
                controller: _input,
                onSubmitted: (_) => _send(),
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 14),
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  hintStyle: TextStyle(
                      color: Colors.grey.shade400, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // ── Send button ─────────────────────────────────────────────
          GestureDetector(
            onTap: _sending ? null : _send,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _sending
                      ? [Colors.grey.shade300, Colors.grey.shade400]
                      : [kPrimary, kPrimaryDark],
                ),
                boxShadow: _sending
                    ? []
                    : [
                        BoxShadow(
                            color: kPrimary.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3))
                      ],
              ),
              child: _sending
                  ? const Padding(
                      padding: EdgeInsets.all(11),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.day == b.day && a.month == b.month && a.year == b.year;
}

// ── Message bubble ────────────────────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  final PeerMsg msg;
  final bool isMine;
  const _Bubble({required this.msg, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        bottom: 4,
        left: isMine ? (msg.isImage ? 24 : 60) : 0,
        right: isMine ? 0 : (msg.isImage ? 24 : 60),
      ),
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: msg.isImage
            ? _ImageBubble(msg: msg, isMine: isMine)
            : msg.isFile
                ? _FileBubble(msg: msg, isMine: isMine)
                : _TextBubble(msg: msg, isMine: isMine),
      ),
    );
  }
}

// ── Text bubble ───────────────────────────────────────────────────────────────

class _TextBubble extends StatelessWidget {
  final PeerMsg msg;
  final bool isMine;
  const _TextBubble({required this.msg, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMine ? kPrimary : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMine ? 18 : 4),
          bottomRight: Radius.circular(isMine ? 4 : 18),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(msg.content,
              style: TextStyle(
                  color: isMine ? Colors.white : kTextDark,
                  fontSize: 14,
                  height: 1.4)),
          const SizedBox(height: 4),
          _Timestamp(msg: msg, isMine: isMine),
        ],
      ),
    );
  }
}

// ── Image bubble ──────────────────────────────────────────────────────────────

class _ImageBubble extends StatelessWidget {
  final PeerMsg msg;
  final bool isMine;
  const _ImageBubble({required this.msg, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final url = msg.fileUrl;
    final isLocal = url.startsWith('/') || url.startsWith('file:');

    Widget image;
    if (isLocal) {
      image = Image.file(File(url), fit: BoxFit.cover);
    } else {
      image = Image.network(url,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : const Center(
                  child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(color: kPrimary))));
    }

    return GestureDetector(
      onTap: () => _showFullImage(context, url, isLocal),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMine ? 16 : 4),
          bottomRight: Radius.circular(isMine ? 4 : 16),
        ),
        child: Stack(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                  minWidth: 120,
                  maxHeight: 240),
              child: image,
            ),
            Positioned(
              bottom: 6,
              right: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _Timestamp(msg: msg, isMine: isMine, light: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImage(BuildContext ctx, String url, bool isLocal) {
    Navigator.of(ctx).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text('Image'),
        ),
        body: Center(
          child: InteractiveViewer(
            child: isLocal
                ? Image.file(File(url))
                : Image.network(url),
          ),
        ),
      ),
    ));
  }
}

// ── File / PDF bubble ─────────────────────────────────────────────────────────

class _FileBubble extends StatelessWidget {
  final PeerMsg msg;
  final bool isMine;
  const _FileBubble({required this.msg, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final isPdf = msg.messageType == 'pdf';
    final icon = isPdf ? Icons.picture_as_pdf_rounded : Icons.insert_drive_file_rounded;
    final iconColor = isPdf ? kError : kPrimary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMine ? kPrimary : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMine ? 16 : 4),
          bottomRight: Radius.circular(isMine ? 4 : 16),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isMine
                    ? Colors.white.withValues(alpha: 0.2)
                    : iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon,
                  color: isMine ? Colors.white : iconColor, size: 24),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.fileName.isNotEmpty ? msg.fileName : 'File',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isMine ? Colors.white : kTextDark),
                  ),
                  if (msg.fileSize.isNotEmpty)
                    Text(msg.fileSize,
                        style: TextStyle(
                            fontSize: 11,
                            color: isMine
                                ? Colors.white60
                                : kTextLight)),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _openFile(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isMine
                    ? Colors.white.withValues(alpha: 0.2)
                    : kPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isMine
                        ? Colors.white.withValues(alpha: 0.4)
                        : kPrimary.withValues(alpha: 0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.download_rounded,
                    size: 14,
                    color: isMine ? Colors.white : kPrimary),
                const SizedBox(width: 5),
                Text('Open',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isMine ? Colors.white : kPrimary)),
              ]),
            ),
          ),
          const SizedBox(height: 6),
          _Timestamp(msg: msg, isMine: isMine),
        ],
      ),
    );
  }

  Future<void> _openFile(BuildContext context) async {
    final url = msg.fileUrl;
    if (url.isEmpty) return;
    // If remote URL, download to temp then open
    if (url.startsWith('http')) {
      try {
        final tmp = await getTemporaryDirectory();
        final name = msg.fileName.isNotEmpty
            ? msg.fileName
            : url.split('/').last;
        final dest = File('${tmp.path}/$name');
        if (!await dest.exists()) {
          final response = await http.get(Uri.parse(url));
          await dest.writeAsBytes(response.bodyBytes);
        }
        await OpenFile.open(dest.path);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open file')),
          );
        }
      }
    } else {
      await OpenFile.open(url);
    }
  }
}

// ── Timestamp widget ──────────────────────────────────────────────────────────

class _Timestamp extends StatelessWidget {
  final PeerMsg msg;
  final bool isMine;
  final bool light;
  const _Timestamp(
      {required this.msg, required this.isMine, this.light = false});

  @override
  Widget build(BuildContext context) {
    final dt = msg.createdAt;
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final timeStr = '$h:$m ${dt.hour < 12 ? 'AM' : 'PM'}';

    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(timeStr,
          style: TextStyle(
              fontSize: 10,
              color: light
                  ? Colors.white70
                  : isMine
                      ? Colors.white.withValues(alpha: 0.65)
                      : kTextLight)),
      if (isMine) ...[
        const SizedBox(width: 4),
        Icon(
          msg.isRead ? Icons.done_all_rounded : Icons.done_rounded,
          size: 12,
          color: light
              ? Colors.white70
              : msg.isRead
                  ? kAccent
                  : Colors.white.withValues(alpha: 0.6),
        ),
      ],
    ]);
  }
}

// ── Media icon button ─────────────────────────────────────────────────────────

class _MediaBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _MediaBtn({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(right: 2),
        decoration: BoxDecoration(
          color: onTap != null
              ? color.withValues(alpha: 0.1)
              : Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 18,
            color: onTap != null ? color : Colors.grey.shade400),
      ),
    );
  }
}

// ── Date divider ──────────────────────────────────────────────────────────────

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider(this.date);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      label = 'Today';
    } else if (date.day == now.day - 1 &&
        date.month == now.month &&
        date.year == now.year) {
      label = 'Yesterday';
    } else {
      label = '${date.day}/${date.month}/${date.year}';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        const Expanded(child: Divider(color: kBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11, color: kTextLight)),
        ),
        const Expanded(child: Divider(color: kBorder)),
      ]),
    );
  }
}
