import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  
  // Backend configuration
  static const String _baseUrl = 'https://free-styel.store/api';
  static const String _conversationsEndpoint = '/conversations';
  static const String _messagesEndpoint = '/messages';
  static const String _sendMessageEndpoint = '/messages/send';
  
  @override
  void initState() {
    super.initState();
    _loadConversations();
  }
  
  final List<Map<String, dynamic>> _conversations = [
    {
      'id': 1,
      'name': 'عز الدين فرج',
      'service': 'صيانة كهربائية',
      'lastMessage': 'سأكون متاحاً غداً في الساعة 10 صباحاً',
      'time': '10:30 ص',
      'unreadCount': 2,
      'isOnline': true,
      'avatar': 'assets/images/craftsman1.jpg',
    },
    {
      'id': 2,
      'name': 'محمد محمود',
      'service': 'سباكة',
      'lastMessage': 'تم إصلاح المشكلة بنجاح',
      'time': '9:15 ص',
      'unreadCount': 0,
      'isOnline': false,
      'avatar': 'assets/images/craftsman2.jpg',
    },
    {
      'id': 3,
      'name': 'محمود محمد مهدى',
      'service': 'دهان',
      'lastMessage': 'هل يمكن تأجيل الموعد لليوم التالي؟',
      'time': 'أمس',
      'unreadCount': 1,
      'isOnline': true,
      'avatar': 'assets/images/craftsman3.jpg',
    },
    {
      'id': 4,
      'name': 'محمد حسن محمد',
      'service': 'نجارة',
      'lastMessage': 'شكراً لك على الخدمة الممتازة',
      'time': 'أمس',
      'unreadCount': 0,
      'isOnline': false,
      'avatar': 'assets/images/craftsman4.jpg',
    },
  ];

  final List<Map<String, dynamic>> _messages = [
    {
      'id': 1,
      'text': 'مرحباً، أريد صيانة كهربائية',
      'isMe': true,
      'time': '10:00 ص',
      'type': 'text',
    },
    {
      'id': 2,
      'text': 'مرحباً، سأكون متاحاً غداً في الساعة 10 صباحاً',
      'isMe': false,
      'time': '10:05 ص',
      'type': 'text',
    },
    {
      'id': 3,
      'text': 'ممتاز، ما هو السعر المتوقع؟',
      'isMe': true,
      'time': '10:10 ص',
      'type': 'text',
    },
    {
      'id': 4,
      'text': 'السعر يتراوح بين 50-100 دينار حسب المشكلة',
      'isMe': false,
      'time': '10:15 ص',
      'type': 'text',
    },
    {
      'id': 5,
      'text': 'سأكون متاحاً غداً في الساعة 10 صباحاً',
      'isMe': false,
      'time': '10:30 ص',
      'type': 'text',
    },
  ];

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    return '${hour > 12 ? hour - 12 : hour}:$minute ${hour >= 12 ? 'م' : 'ص'}';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFfec901),
        appBar: AppBar(
          title: const Text(
            'المحادثات',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.blue,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            : ListView.builder(
                itemCount: _conversations.length,
                itemBuilder: (context, index) {
                  final conversation = _conversations[index];
                  return _buildConversationCard(conversation);
                },
              ),
      ),
    );
  }

  Widget _buildConversationCard(Map<String, dynamic> conversation) {
    return GestureDetector(
      onTap: () => _openChat(conversation),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[300],
                child: const Icon(
                  Icons.person,
                  color: Colors.grey,
                  size: 30,
                ),
              ),
              if (conversation['isOnline'])
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      conversation['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      conversation['time'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  conversation['service'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  conversation['lastMessage'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Unread count
          if (conversation['unreadCount'] > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Text(
                conversation['unreadCount'].toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
        ),
      ),
    );
  }

  Widget _buildChatInterface() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Message input
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Send button
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openChat(Map<String, dynamic> conversation) {
    // Navigate to chat screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ChatScreen(
          conversation: conversation,
        ),
      ),
    );
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // For development - simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate loading conversations from admin panel
      print('Loading conversations from admin panel...');
      
      // TODO: Uncomment when backend is ready
      /*
      // Real API call to get conversations
      final response = await http.get(
        Uri.parse('$_baseUrl$_conversationsEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await _getUserToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _conversations.clear();
            _conversations.addAll(data['conversations'] ?? []);
          });
        }
      }
      */

    } catch (e) {
      print('Error loading conversations: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    try {
      // For development - simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate sending message to admin panel
      print('Sending message to admin panel: $message');
      
      // TODO: Uncomment when backend is ready
      /*
      // Real API call to send message
      final response = await http.post(
        Uri.parse('$_baseUrl$_sendMessageEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await _getUserToken()}',
        },
        body: jsonEncode({
          'conversation_id': _selectedConversationId,
          'message': message,
          'sender_type': 'customer', // or 'craftsman'
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Message sent successfully
          _scrollToBottom();
        }
      }
      */

      // Simulate successful message sending
      _scrollToBottom();
      _showSuccessSnackBar('تم إرسال الرسالة وحفظها في الـ admin panel');

    } catch (e) {
      _showErrorSnackBar('خطأ في إرسال الرسالة');
      print('Error sending message: $e');
    }
  }

  Future<void> _loadMessages(int conversationId) async {
    try {
      // For development - simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate loading messages from admin panel
      print('Loading messages for conversation $conversationId from admin panel');
      
      // TODO: Uncomment when backend is ready
      /*
      // Real API call to get messages
      final response = await http.get(
        Uri.parse('$_baseUrl$_messagesEndpoint?conversation_id=$conversationId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await _getUserToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _messages.clear();
            _messages.addAll(data['messages'] ?? []);
          });
        }
      }
      */

    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  Future<void> _markAsRead(int conversationId) async {
    try {
      // For development - simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Simulate marking conversation as read in admin panel
      print('Marking conversation $conversationId as read in admin panel');
      
      // TODO: Uncomment when backend is ready
      /*
      // Real API call to mark as read
      final response = await http.put(
        Uri.parse('$_baseUrl$_conversationsEndpoint/$conversationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await _getUserToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Conversation marked as read
        }
      }
      */

    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Future<void> _deleteConversation(int conversationId) async {
    try {
      // For development - simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate deleting conversation from admin panel
      print('Deleting conversation $conversationId from admin panel');
      
      // TODO: Uncomment when backend is ready
      /*
      // Real API call to delete conversation
      final response = await http.delete(
        Uri.parse('$_baseUrl$_conversationsEndpoint/$conversationId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await _getUserToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _conversations.removeWhere((conv) => conv['id'] == conversationId);
          });
          _showSuccessSnackBar('تم حذف المحادثة');
        }
      }
      */

      // Remove from local list
      setState(() {
        _conversations.removeWhere((conv) => conv['id'] == conversationId);
      });
      _showSuccessSnackBar('تم حذف المحادثة من الـ admin panel');

    } catch (e) {
      _showErrorSnackBar('خطأ في حذف المحادثة');
      print('Error deleting conversation: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<String> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _ChatScreen extends StatefulWidget {
  final Map<String, dynamic> conversation;

  const _ChatScreen({required this.conversation});

  @override
  State<_ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<_ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFfec901),
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.conversation['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                widget.conversation['service'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.blue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            // Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
            
            // Message Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Message input
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالتك...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Send button
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
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
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    return Align(
      alignment: message['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message['isMe'] ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message['text'],
          style: TextStyle(
            color: message['isMe'] ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'id': _messages.length + 1,
        'text': _messageController.text.trim(),
        'isMe': true,
        'time': _getCurrentTime(),
        'type': 'text',
      });
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate craftsman response
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({
          'id': _messages.length + 1,
          'text': 'شكراً لك! سأقوم بالرد عليك قريباً.',
          'isMe': false,
          'time': _getCurrentTime(),
          'type': 'text',
        });
      });
      _scrollToBottom();
    });
  }

  void _loadMessages() {
    // Add some initial messages
    setState(() {
      _messages.addAll([
        {
          'id': 1,
          'text': 'مرحباً، أريد ${widget.conversation['service']}',
          'isMe': true,
          'time': '10:00 ص',
          'type': 'text',
        },
        {
          'id': 2,
          'text': 'مرحباً، سأكون متاحاً غداً في الساعة 10 صباحاً',
          'isMe': false,
          'time': '10:05 ص',
          'type': 'text',
        },
        {
          'id': 3,
          'text': 'ممتاز، ما هو السعر المتوقع؟',
          'isMe': true,
          'time': '10:10 ص',
          'type': 'text',
        },
        {
          'id': 4,
          'text': 'السعر يتراوح بين 50-100 دينار حسب المشكلة',
          'isMe': false,
          'time': '10:15 ص',
          'type': 'text',
        },
      ]);
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    return '${hour > 12 ? hour - 12 : hour}:$minute ${hour >= 12 ? 'م' : 'ص'}';
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}