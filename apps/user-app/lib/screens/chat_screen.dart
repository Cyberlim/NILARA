import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';

class ChatScreen extends StatefulWidget {
  final String ticketId;
  final String ticketSubject;
  final bool isClosed;

  const ChatScreen({
    super.key,
    required this.ticketId,
    required this.ticketSubject,
    this.isClosed = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _messages = [];
  bool _isLoading = true;
  IO.Socket? _socket;
  String? _authToken;
  Timer? _pollingTimer;

  String _formatDateDivider(String? dateString) {
    if (dateString == null) return '';
    final msgDate = DateTime.tryParse(dateString)?.toLocal();
    if (msgDate == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(msgDate.year, msgDate.month, msgDate.day);

    final diff = today.difference(msgDay).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';

    if (diff > 1 && diff < 7) {
      const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return weekdays[msgDate.weekday - 1];
    }

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[msgDate.month - 1]} ${msgDate.day}, ${msgDate.year}';
  }

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final token = await user.getIdToken();
    _authToken = token;

    await _loadHistory(token!);
    _connectSocket(token);

    // Silent background sync timer to guarantee 100% real-time consistency
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _silentSyncHistory();
    });
  }

  Future<void> _loadHistory(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/api/v1/tickets/${widget.ticketId}/messages'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _messages = data['messages'] ?? [];
            _isLoading = false;
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      print("Failed to load chat history: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _silentSyncHistory() async {
    if (!mounted || _authToken == null) return;
    try {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/api/v1/tickets/${widget.ticketId}/messages'),
        headers: {'Authorization': 'Bearer $_authToken'},
      );

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        if (data['success'] && data['messages'] is List) {
          final List<dynamic> serverMessages = data['messages'];
          bool hasChanges = serverMessages.length != _messages.length;
          if (!hasChanges) {
            for (int i = 0; i < serverMessages.length; i++) {
              if (serverMessages[i]['_id'] != _messages[i]['_id'] ||
                  serverMessages[i]['isRead'] != _messages[i]['isRead']) {
                hasChanges = true;
                break;
              }
            }
          }

          if (hasChanges) {
            final shouldScroll = serverMessages.length != _messages.length;
            setState(() {
              _messages = serverMessages;
            });
            if (shouldScroll) {
              _scrollToBottom();
            }
          }
        }
      }
    } catch (_) {}
  }

  void _connectSocket(String token) {
    _socket = IO.io(
      Constants.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .disableAutoConnect()
          .setAuth({'token': token})
          .setExtraHeaders({'authorization': 'Bearer $token'})
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Connected to chat socket!');
      // Subscribe to this specific ticket room for instant two-way messaging
      _socket!.emit('join_ticket', widget.ticketId);
      // Mark as read when connected
      _socket!.emit('mark_as_read', {'ticketId': widget.ticketId});
    });

    _socket!.onConnectError((err) {
      print('Socket connection error: $err');
    });

    _socket!.onError((err) {
      print('Socket error: $err');
    });

    _socket!.on('receive_message', (data) {
      if (data == null) return;
      final msgTicketId = (data['ticketId'] ?? '').toString();
      if (msgTicketId.isNotEmpty && msgTicketId != widget.ticketId.toString()) return;
      
      if (mounted) {
        setState(() {
          final newMsgId = (data['_id'] ?? '').toString();
          bool exists = _messages.any((m) => (m['_id'] ?? '').toString() == newMsgId);
          if (!exists) {
            _messages.add(data);
            _scrollToBottom();
          }
        });

        // Mark incoming messages as read if we're on this screen
        if (data['senderId'] == 'admin') {
          _socket!.emit('mark_as_read', {'ticketId': widget.ticketId});
        }
      }
    });

    _socket!.on('messages_read', (data) {
      if (!mounted || data == null) return;
      final tId = (data['ticketId'] ?? '').toString();
      if (tId.isNotEmpty && tId != widget.ticketId.toString()) return;

      setState(() {
        for (var m in _messages) {
          if (m['senderId'] != 'admin') {
            m['isRead'] = true;
          }
        }
      });
    });

    _socket!.onDisconnect((_) => print('Disconnected from chat socket'));
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

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _socket == null) return;

    if (!_socket!.connected) {
      _socket!.connect();
    }

    _messageController.clear();

    _socket!.emit('send_message', {
      'receiverId': 'admin', 
      'text': text,
      'ticketId': widget.ticketId
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    if (_socket != null) {
      _socket!.emit('leave_ticket', widget.ticketId);
      _socket!.disconnect();
      _socket!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.ticketSubject,
              style: GoogleFonts.outfit(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (widget.isClosed)
              Text(
                "Closed",
                style: GoogleFonts.outfit(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF168BDB)),
                  )
                : _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Send a message to start chatting!",
                          style: GoogleFonts.outfit(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['senderId'] != 'admin';

                      bool showDateDivider = false;
                      String dateText = '';
                      if (index == 0) {
                        showDateDivider = true;
                        dateText = _formatDateDivider(msg['createdAt']);
                      } else {
                        final prevMsg = _messages[index - 1];
                        final prevDateStr = prevMsg['createdAt'];
                        final currDateStr = msg['createdAt'];
                        if (prevDateStr != null && currDateStr != null) {
                          final prevDate = DateTime.tryParse(prevDateStr)?.toLocal();
                          final currDate = DateTime.tryParse(currDateStr)?.toLocal();
                          if (prevDate != null && currDate != null) {
                            if (prevDate.year != currDate.year || prevDate.month != currDate.month || prevDate.day != currDate.day) {
                              showDateDivider = true;
                              dateText = _formatDateDivider(currDateStr);
                            }
                          }
                        }
                      }

                      return Column(
                        children: [
                          if (showDateDivider)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  dateText,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? const Color(0xFF168BDB)
                                    : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                                  bottomRight: Radius.circular(isMe ? 4 : 16),
                                ),
                                border: isMe
                                    ? null
                                    : Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg['text'] ?? '',
                                    style: GoogleFonts.outfit(
                                      color:
                                          isMe ? Colors.white : Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatTime(msg['createdAt']),
                                        style: GoogleFonts.outfit(
                                          color: isMe
                                              ? Colors.white70
                                              : Colors.grey.shade500,
                                          fontSize: 10,
                                        ),
                                      ),
                                      if (isMe) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          msg['isRead'] == true
                                              ? Icons.done_all_rounded
                                              : Icons.check_rounded,
                                          size: 15,
                                          color: msg['isRead'] == true
                                              ? const Color(0xFF80D8FF)
                                              : Colors.white70,
                                        ),
                                      ]
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),

          // Input Area
          if (!widget.isClosed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          style: GoogleFonts.outfit(fontSize: 15),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            hintText: "Type a message...",
                            hintStyle: GoogleFonts.outfit(
                              color: Colors.grey.shade500,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          color: Color(0xFF168BDB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade200,
              width: double.infinity,
              child: Text(
                "This ticket is closed.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: Colors.grey.shade600),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString).toLocal();
      final hours = date.hour;
      final mins = date.minute.toString().padLeft(2, '0');
      final period = hours >= 12 ? 'PM' : 'AM';
      final formattedHours = hours % 12 == 0 ? 12 : hours % 12;
      return '$formattedHours:$mins $period';
    } catch (e) {
      return '';
    }
  }
}
