import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/language_service.dart';
import '../config/api_config.dart';
import 'package:handyman_app/l10n/app_localizations.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  Locale _currentLocale = LanguageService.defaultLocale;
  
  // Backend configuration
  static const String _baseUrl = 'https://free-styel.store/api';
  static const String _conversationsEndpoint = '/conversations';
  static const String _messagesEndpoint = '/messages';
  static const String _sendMessageEndpoint = '/messages/send';
  
  @override
  void initState() {
    super.initState();
    _loadConversations();
    _loadCurrentLocale();
  }

  Future<void> _loadCurrentLocale() async {
    final locale = await LanguageService.getSavedLocale();
    if (mounted) {
      setState(() {
        _currentLocale = locale;
      });
    }
  }
  
  final List<Map<String, dynamic>> _conversations = [];

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
    final l10n = AppLocalizations.of(context)!;
    final isRtl = _currentLocale.languageCode == 'ar';
    
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFfec901),
        appBar: AppBar(
          title: Text(
            l10n.conversations,
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
      final headers = await _getAuthHeaders();
      if (headers == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await http
          .get(Uri.parse(ApiConfig.chatList), headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> chats = data['data'] ?? [];
          setState(() {
            _conversations
              ..clear()
              ..addAll(chats.map((chat) {
                final craftsman = chat['craftsman'] ?? {};
                final order = chat['order'] ?? {};
                final name = craftsman['name'] ?? order['title'] ?? 'صنايعي';
                return {
                  'id': craftsman['id']?.toString() ?? chat['id'].toString(),
                  'chat_id': chat['id'],
                  'name': name,
                  'service': order['title'] ?? craftsman['category_name'] ?? 'خدمة',
                  'lastMessage': chat['last_message'] ?? '',
                  'time': chat['last_message_at'] ?? '',
                  'unreadCount': chat['unread_count'] ?? 0,
                  'isOnline': true,
                  'avatar': null,
                  'isSupport': false,
                  'craftsman': craftsman,
                  'customer_id': chat['customer']?['id'],
                };
              }));
          });
        } else {
          print('Failed to load chats: ${data['message']}');
        }
      } else {
        print('Failed to load chats: ${response.statusCode}');
      }
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

// Helper function to open support chat from any screen
Future<void> openSupportChat(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final locale = await LanguageService.getSavedLocale();
  final isRtl = locale.languageCode == 'ar';
  
  // Create support conversation
  final supportConversation = {
    'id': 'support',
    'name': isRtl ? 'دعم فني' : 'Support Technique',
    'service': isRtl ? 'مساعدة' : 'Aide',
    'lastMessage': isRtl ? 'مرحباً، كيف يمكنني مساعدتك؟' : 'Bonjour, comment puis-je vous aider?',
    'time': DateTime.now().toString(),
    'unreadCount': 0,
    'isOnline': true,
    'avatar': null,
    'isSupport': true, // Flag to identify support chat
  };
  
  // Navigate to chat screen
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => _ChatScreen(
        conversation: supportConversation,
      ),
    ),
  );
}

Future<void> openCraftsmanChat(
  BuildContext context,
  Map<String, dynamic> craftsman,
) async {
  final locale = await LanguageService.getSavedLocale();
  final isRtl = locale.languageCode == 'ar';

  final conversation = {
    'id': craftsman['id']?.toString() ?? 'craftsman_${DateTime.now().millisecondsSinceEpoch}',
    'name': craftsman['name'] ?? (isRtl ? 'صنايعي' : 'Artisan'),
    'service': craftsman['specialization'] ?? (isRtl ? 'خدمة حرفية' : 'Service artisanale'),
    'lastMessage': isRtl ? 'ابدأ المحادثة الآن' : 'Commencez la discussion maintenant',
    'time': DateTime.now().toString(),
    'unreadCount': 0,
    'isOnline': true,
    'avatar': craftsman['avatar'],
    'isSupport': false,
    'chat_id': craftsman['chat_id'],
    'craftsman': craftsman,
  };

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => _ChatScreen(
        conversation: conversation,
      ),
    ),
  );
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
  List<Map<String, dynamic>> _messages = [];
  int? _chatId;
  bool _isLoadingMessages = false;

  @override
  void initState() {
    super.initState();
    _chatId = widget.conversation['chat_id'] as int?;
    _loadMessages(); // This will call _loadSupportMessages or _loadRegularMessages
    
    // Set up periodic refresh to get new messages from backend
    _startMessagePolling();
  }
  
  void _startMessagePolling() {
    // Poll for new messages every 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _refreshMessages();
        _startMessagePolling(); // Continue polling
      }
    });
  }
  
  Future<void> _refreshMessages() async {
    print('Refreshing messages...');
    print('Is support chat: ${widget.conversation['isSupport']}');
    print('Current chat_id: $_chatId');
    
    if (widget.conversation['isSupport'] == true) {
      await _loadSupportMessages(keepLastMessage: false); // Don't keep last message when refreshing
    } else {
      await _loadRegularMessages(keepOptimisticMessages: true);
    }
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
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                _refreshMessages();
              },
              tooltip: 'تحديث الرسائل',
            ),
          ],
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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    // Send to backend (the send methods will add the message to the UI)
    if (widget.conversation['isSupport'] == true) {
      // For support messages, add immediately
      setState(() {
        _messages.add({
          'id': DateTime.now().millisecondsSinceEpoch,
          'text': messageText,
          'isMe': true,
          'time': _getCurrentTime(),
          'type': 'text',
        });
      });
      _scrollToBottom();
      await _sendSupportMessage(messageText);
    } else {
      await _sendRegularMessage(messageText);
    }
  }

  Future<void> _sendSupportMessage(String message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '1';
      final headers = await _buildChatAuthHeaders();
      if (headers == null) {
        _showFallbackResponse();
        return;
      }
      
      print('Sending support message to backend: $message');
      print('User ID: $userId');
      print('Conversation ID: ${widget.conversation['id']}');
      print('API Endpoint: ${ApiConfig.chatSend}');
      
      // Send message to backend
      final response = await http.post(
        Uri.parse(ApiConfig.chatSend),
        headers: headers,
        body: jsonEncode({
          'user_id': userId,
          'message': message,
          'type': 'support',
          'conversation_id': widget.conversation['id'],
        }),
      ).timeout(const Duration(seconds: 30));

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('Message sent successfully to backend');
          print('Message ID: ${data['data']?['message']?['id']}');
          print('Chat ID: ${data['data']?['chat']?['id']}');
          
          // Update chat_id if available
          if (data['data']?['chat']?['id'] != null) {
            final newChatId = data['data']['chat']['id'];
            if (newChatId is int) {
              _chatId = newChatId;
            } else if (newChatId is String) {
              _chatId = int.tryParse(newChatId);
            }
            print('Updated chat_id to: $_chatId');
          }
          
          // Update the message with backend data if available
          final messageData = data['data']?['message'] ?? {};
          if (messageData.isNotEmpty && _messages.isNotEmpty) {
            setState(() {
              // Find and update the last message (the one we just sent)
              final lastIndex = _messages.length - 1;
              _messages[lastIndex] = {
                'id': messageData['id'] ?? _messages[lastIndex]['id'],
                'text': messageData['text'] ?? messageData['message'] ?? _messages[lastIndex]['text'],
                'isMe': true,
                'time': messageData['created_at'] ?? _messages[lastIndex]['time'],
                'type': messageData['message_type'] ?? 'text',
              };
            });
          }
          // Don't reload messages immediately to avoid clearing the sent message
          // The message is already in the list, and we'll get new messages on next load
          // Also wait for support response
          _waitForSupportResponse();
        } else {
          print('Backend returned success=false: ${data['message']}');
          _showErrorSnackBar(data['message'] ?? 'فشل إرسال الرسالة');
          _showFallbackResponse();
        }
      } else {
        print('Backend returned error status: ${response.statusCode}');
        try {
          final errorData = jsonDecode(response.body);
          _showErrorSnackBar(errorData['message'] ?? 'خطأ في إرسال الرسالة');
        } catch (e) {
          _showErrorSnackBar('خطأ في إرسال الرسالة: ${response.statusCode}');
        }
        _showFallbackResponse();
      }
    } catch (e) {
      print('Error sending support message: $e');
      // Show fallback response
      _showFallbackResponse();
    }
  }

  Future<void> _sendRegularMessage(String message) async {
    final optimisticMessage = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'text': message,
      'isMe': true,
      'time': _getCurrentTime(),
      'type': 'text',
      'isOptimistic': true, // Flag to identify optimistic messages
    };

    setState(() {
      _messages.add(optimisticMessage);
    });
    _scrollToBottom();

    try {
      final headers = await _buildChatAuthHeaders();
      if (headers == null) {
        _showErrorSnackBar('يرجى تسجيل الدخول لإرسال الرسائل');
        // Keep the message even if auth fails
        return;
      }

      final body = {
        'message': message,
        if (_chatId != null) 'chat_id': _chatId,
        if (_chatId == null)
          'craftsman_id': (widget.conversation['craftsman']?['id'] ?? widget.conversation['id']).toString(),
      };

      final response = await http
          .post(
            Uri.parse(ApiConfig.chatSend),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final messageData = data['data']?['message'] ?? {};
          setState(() {
            // Remove optimistic message and add the real one from backend
            _messages.removeWhere((msg) => msg['isOptimistic'] == true && msg['text'] == message);
            _chatId = data['data']?['chat']?['id'] as int? ?? _chatId;
            _messages.add({
              'id': messageData['id'] ?? optimisticMessage['id'],
              'text': messageData['text'] ?? messageData['message'] ?? message,
              'isMe': true,
              'time': messageData['created_at'] ?? _getCurrentTime(),
              'type': messageData['message_type'] ?? 'text',
            });
          });
          _scrollToBottom();
          return;
        }
      }

      // If sending failed, keep the optimistic message but mark it as failed
      _showErrorSnackBar('خطأ في إرسال الرسالة. سيتم إعادة المحاولة تلقائيًا');
      setState(() {
        // Keep the message but mark it as failed
        final index = _messages.indexWhere((msg) => msg['isOptimistic'] == true && msg['text'] == message);
        if (index != -1) {
          _messages[index]['isOptimistic'] = false;
          _messages[index]['failed'] = true;
        }
      });
    } catch (e) {
      print('Error sending chat message: $e');
      _showErrorSnackBar('خطأ في إرسال الرسالة. سيتم إعادة المحاولة تلقائيًا');
      // Keep the message even on error
      setState(() {
        final index = _messages.indexWhere((msg) => msg['isOptimistic'] == true && msg['text'] == message);
        if (index != -1) {
          _messages[index]['isOptimistic'] = false;
          _messages[index]['failed'] = true;
        }
      });
    }
  }

  void _waitForSupportResponse() {
    // Wait for support team response (polling or websocket)
    Future.delayed(const Duration(seconds: 2), () {
      final l10n = AppLocalizations.of(context);
      final isRtl = Localizations.localeOf(context).languageCode == 'ar';
      
      setState(() {
        _messages.add({
          'id': _messages.length + 1,
          'text': isRtl 
              ? 'شكراً لتواصلك معنا. سنقوم بالرد عليك في أقرب وقت ممكن.'
              : 'Merci de nous avoir contactés. Nous vous répondrons dans les plus brefs délais.',
          'isMe': false,
          'time': _getCurrentTime(),
          'type': 'text',
        });
      });
      _scrollToBottom();
    });
  }

  void _showFallbackResponse() {
    final l10n = AppLocalizations.of(context);
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';
    
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({
          'id': _messages.length + 1,
          'text': isRtl 
              ? 'تم استلام رسالتك. سنقوم بالرد عليك قريباً.'
              : 'Votre message a été reçu. Nous vous répondrons bientôt.',
          'isMe': false,
          'time': _getCurrentTime(),
          'type': 'text',
        });
      });
      _scrollToBottom();
    });
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoadingMessages = true;
    });
    // Check if this is a support chat
    if (widget.conversation['isSupport'] == true) {
      // Load support messages from backend
      await _loadSupportMessages();
    } else {
      // Load regular conversation messages
      await _loadRegularMessages();
    }
    if (mounted) {
      setState(() {
        _isLoadingMessages = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _loadSupportMessages({bool keepLastMessage = false}) async {
    try {
      // Try to load messages from backend
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '1';
      final headers = await _buildChatAuthHeaders() ?? ApiConfig.headers;
      
      // Save the last message if we need to keep it
      Map<String, dynamic>? lastMessage;
      if (keepLastMessage && _messages.isNotEmpty) {
        lastMessage = Map<String, dynamic>.from(_messages.last);
      }
      
      // Get chat_id if available
      final chatId = _chatId ?? widget.conversation['chat_id'];
      
      // API call to get support messages
      // Always use chat_id if available, but also pass type=support to ensure correct handling
      Uri uri;
      if (chatId != null) {
        uri = Uri.parse('${ApiConfig.chatMessages}?chat_id=$chatId&type=support');
      } else {
        uri = Uri.parse('${ApiConfig.chatMessages}?user_id=$userId&type=support');
      }
      
      print('Loading support messages from: $uri');
      print('Chat ID: $chatId');
      print('User ID: $userId');
      
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 30));
      
      print('Support messages response status: ${response.statusCode}');
      print('Support messages response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed response data: $data');
        
        if (data['success'] == true && data['data'] != null) {
          final messagesData = data['data'];
          final List<dynamic> messages = messagesData['messages'] ?? (messagesData is List ? messagesData : []);
          
          print('Messages array length: ${messages.length}');
          if (messages.isNotEmpty) {
            print('First message: ${messages.first}');
            print('Last message: ${messages.last}');
          }
          
          // Update chat_id if available
          if (messagesData['chat']?['id'] != null) {
            final newChatId = messagesData['chat']['id'];
            if (newChatId is int) {
              _chatId = newChatId;
            } else if (newChatId is String) {
              _chatId = int.tryParse(newChatId);
            }
            print('Updated chat_id to: $_chatId');
          }
          
          // Get existing message IDs to avoid duplicates
          final existingIds = _messages.map((m) => m['id']).toSet();
          print('Existing message IDs: $existingIds');
          print('New messages count: ${messages.length}');
          
          setState(() {
            // Clear and reload all messages to ensure we have the latest
            // This ensures admin replies are included
            final allMessages = <Map<String, dynamic>>[];
            
            // Add all messages from backend
            for (var msg in messages) {
              final msgSenderId = msg['sender_id']?.toString();
              final isMe = msgSenderId == userId || 
                          msg['is_me'] == true || 
                          msg['sender_type'] == 'user' ||
                          msg['sender_type'] == 'customer';
              
              allMessages.add({
                'id': msg['id'],
                'text': msg['message'] ?? msg['text'],
                'isMe': isMe,
                'time': msg['created_at'] ?? DateTime.now().toString(),
                'type': msg['message_type'] ?? 'text',
                'sender_id': msgSenderId, // Keep for debugging
              });
            }
            
            // If we need to keep the last message and it's not in the backend response, add it back
            if (keepLastMessage && lastMessage != null) {
              final lastMessageId = lastMessage['id'];
              final messageExists = allMessages.any((msg) => msg['id'] == lastMessageId);
              if (!messageExists) {
                allMessages.add(lastMessage);
              }
            }
            
            // Sort messages by time
            allMessages.sort((a, b) {
              try {
                final timeA = DateTime.parse(a['time'] ?? DateTime.now().toString());
                final timeB = DateTime.parse(b['time'] ?? DateTime.now().toString());
                return timeA.compareTo(timeB);
              } catch (e) {
                return 0;
              }
            });
            
            print('Loaded ${allMessages.length} messages total');
            print('Messages IDs: ${allMessages.map((m) => m['id']).toList()}');
            _messages = allMessages;
          });
          _scrollToBottom();
          return;
        } else {
          print('Response success is false or data is null');
          print('Response data: $data');
        }
      } else {
        print('Response status is not 200: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error loading support messages: $e');
      print('Stack trace: ${StackTrace.current}');
    }
    
    // Fallback: Add default support messages only if list is empty
    if (_messages.isEmpty) {
      final l10n = AppLocalizations.of(context);
      final isRtl = Localizations.localeOf(context).languageCode == 'ar';
      
      setState(() {
        _messages.addAll([
          {
            'id': 1,
            'text': isRtl ? 'مرحباً، كيف يمكنني مساعدتك؟' : 'Bonjour, comment puis-je vous aider?',
            'isMe': false,
            'time': DateTime.now().toString(),
            'type': 'text',
          },
        ]);
      });
    }
  }

  Future<void> _loadRegularMessages({bool keepOptimisticMessages = false}) async {
    try {
      final headers = await _buildChatAuthHeaders();
      if (headers == null) {
        return;
      }

      // Save optimistic messages if we need to keep them
      List<Map<String, dynamic>> optimisticMessages = [];
      if (keepOptimisticMessages) {
        optimisticMessages = _messages.where((msg) => msg['isOptimistic'] == true).toList();
      }

      final params = <String, String>{};
      if (_chatId != null) {
        params['chat_id'] = _chatId.toString();
      } else {
        final craftsman = widget.conversation['craftsman'];
        final craftsmanId = craftsman?['id'] ?? widget.conversation['id'];
        if (craftsmanId != null) {
          params['craftsman_id'] = craftsmanId.toString();
        }
      }

      final uri = Uri.parse(ApiConfig.chatMessages).replace(queryParameters: params);
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final chatData = data['data'];
          final List<dynamic> messages = chatData['messages'] ?? [];
          setState(() {
            _chatId = chatData['chat']?['id'] as int?;
            _messages.clear();
            _messages.addAll(messages.map((msg) => {
                  'id': msg['id'],
                  'text': msg['text'] ?? msg['message'],
                  'isMe': msg['is_me'] == true || msg['sender_type'] == 'user',
                  'time': msg['created_at'] ?? DateTime.now().toString(),
                  'type': msg['message_type'] ?? 'text',
                }));
            
            // Add back optimistic messages that are not in the backend response
            if (keepOptimisticMessages && optimisticMessages.isNotEmpty) {
              for (var optMsg in optimisticMessages) {
                final optText = optMsg['text'];
                final exists = _messages.any((msg) => msg['text'] == optText);
                if (!exists) {
                  _messages.add(optMsg);
                }
              }
            }
          });
          _scrollToBottom();
        } else {
          print('Failed to load chat messages: ${data['message']}');
        }
      } else {
        print('Failed to load chat messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading conversation messages: $e');
    }
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

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<Map<String, String>?> _buildChatAuthHeaders() async {
    return _getAuthHeaders();
  }
}

Future<Map<String, String>?> _getAuthHeaders() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('access_token');
  if (token == null || token.isEmpty) {
    return null;
  }
  final headers = Map<String, String>.from(ApiConfig.headers);
  headers['Authorization'] = 'Bearer $token';
  return headers;
}