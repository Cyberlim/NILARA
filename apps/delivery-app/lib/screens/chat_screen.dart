import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:http/http.dart' as http;
import '../services/user_service.dart';

class ChatScreen extends StatefulWidget {
  final String ticketId;
  final String ticketSubject;
  final String? ticketCategory;
  final bool isClosed;

  const ChatScreen({
    super.key,
    required this.ticketId,
    required this.ticketSubject,
    this.ticketCategory,
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
  socket_io.Socket? _socket;

  static const String _socketUrl = 'http://localhost:5000';
  static const String _apiUrl = 'http://localhost:5000/api/v1';

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

  String _formatTime(String? dateString) {
    if (dateString == null) return '';
    final date = DateTime.tryParse(dateString)?.toLocal();
    if (date == null) return '';
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final token = await UserService().getFreshToken();
    if (token == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    await _loadHistory(token);
    _connectSocket(token);
  }

  Future<void> _loadHistory(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/tickets/${widget.ticketId}/messages'),
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
      debugPrint("Failed to load chat history: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _connectSocket(String token) {
    _socket = socket_io.io(
      _socketUrl,
      socket_io.OptionBuilder()
          .disableAutoConnect()
          .setAuth({'token': token})
          .setExtraHeaders({'authorization': 'Bearer $token'})
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint('Connected to delivery partner chat socket');
      _socket!.emit('mark_as_read', {'senderId': 'admin', 'ticketId': widget.ticketId});
    });

    _socket!.onConnectError((err) {
      debugPrint('Socket connection error: $err');
    });

    _socket!.on('receive_message', (data) {
      if (data['ticketId'] != null && data['ticketId'] != widget.ticketId) return;

      if (mounted) {
        setState(() {
          bool exists = _messages.any((m) => m['_id'] == data['_id']);
          if (!exists) {
            _messages.add(data);
            _scrollToBottom();
          }
        });

        if (data['senderId'] == 'admin') {
          _socket!.emit('mark_as_read', {'senderId': 'admin', 'ticketId': widget.ticketId});
        }
      }
    });

    _socket!.onDisconnect((_) => debugPrint('Disconnected from chat socket'));
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reconnecting to support desk...', style: GoogleFonts.outfit(color: Colors.white)),
            backgroundColor: Colors.orange,
          ),
        );
      }
      _socket!.connect();
      return;
    }

    _messageController.clear();

    _socket!.emit('send_message', {
      'receiverId': 'admin',
      'text': text,
      'ticketId': widget.ticketId,
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.ticketSubject,
                    style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.isClosed ? Colors.grey : const Color(0xFF1E9C1C),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.isClosed ? "Ticket Closed" : "Support Agent Online",
                  style: GoogleFonts.outfit(
                    color: widget.isClosed ? Colors.grey : const Color(0xFF1E9C1C),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E9C1C)))
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.support_agent, size: 36, color: Color(0xFF1E9C1C)),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              "Support Session Started",
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "A Nilara support executive will reply shortly.",
                              style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message['senderId'] != 'admin';

                          bool showDateDivider = false;
                          String currentDate = _formatDateDivider(message['createdAt']);
                          if (index == 0) {
                            showDateDivider = true;
                          } else {
                            final prevDate = _formatDateDivider(_messages[index - 1]['createdAt']);
                            if (currentDate != prevDate) {
                              showDateDivider = true;
                            }
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (showDateDivider) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                                  child: Row(
                                    children: [
                                      Expanded(child: Divider(color: Colors.grey.shade300)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                        child: Text(
                                          currentDate,
                                          style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(child: Divider(color: Colors.grey.shade300)),
                                    ],
                                  ),
                                ),
                              ],
                              Align(
                                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isMe ? const Color(0xFF1E9C1C) : Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                                    ),
                                    border: isMe ? null : Border.all(color: Colors.grey.shade200),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message['text'] ?? '',
                                        style: GoogleFonts.outfit(
                                          color: isMe ? Colors.white : const Color(0xFF0F172A),
                                          fontSize: 14,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatTime(message['createdAt']),
                                        style: GoogleFonts.outfit(
                                          color: isMe ? Colors.white70 : Colors.grey.shade400,
                                          fontSize: 10,
                                        ),
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

          // Closed Notice or Input Field
          if (widget.isClosed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade100,
              child: Center(
                child: Text(
                  "This support ticket has been closed by the support desk.",
                  style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          style: GoogleFonts.outfit(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "Type your message...",
                            hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 14),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _sendMessage,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E9C1C),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
