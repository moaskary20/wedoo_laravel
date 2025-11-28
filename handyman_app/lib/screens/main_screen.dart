import 'package:flutter/material.dart';
import 'dart:async';
import 'category_grid_screen.dart';
import 'settings_screen.dart';
import 'my_orders_screen.dart';
import 'app_explanation_screen.dart';
import 'shops_exhibitions_screen.dart';
import 'conversations_screen.dart';
import 'craftsman_orders_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/language_service.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'package:handyman_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  Locale _currentLocale = LanguageService.defaultLocale;
  String _userType = 'customer';
  Timer? _chatPollingTimer;
  Timer? _orderPollingTimer;
  final Map<int, String> _lastMessageTimes = {};
  Set<int> _knownOrderIds = {};
  Set<int> _knownChatOrderIds = {};
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadCurrentLocale();
    _loadUserType().then((_) {
      // Start order polling only for craftsmen
      if (_userType == 'craftsman') {
        _startOrderPolling();
      }
    });
    _startChatPolling();
  }

  @override
  void dispose() {
    _chatPollingTimer?.cancel();
    _orderPollingTimer?.cancel();
    super.dispose();
  }

  void _startChatPolling() {
    // Check immediately
    _checkNewMessages();
    // Then check every 10 seconds
    _chatPollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkNewMessages();
    });
  }

  Future<void> _checkNewMessages() async {
    try {
      final response = await ApiService.get('/api/chat/list');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final chats = response.data['data'] as List;

        for (var chat in chats) {
          final chatId = chat['id'];
          final unreadCount = chat['unread_count'] ?? 0;
          final lastMessageAt = chat['last_message_at'];
          final lastMessage = chat['last_message'];

          if (unreadCount > 0 && lastMessageAt != null) {
            // Check if this is a new message we haven't notified about
            if (!_lastMessageTimes.containsKey(chatId) ||
                _lastMessageTimes[chatId] != lastMessageAt) {
              _lastMessageTimes[chatId] = lastMessageAt;

              // Determine sender name
              String senderName = 'مستخدم';
              if (_userType == 'craftsman') {
                senderName = chat['customer']?['name'] ?? 'عميل';
              } else {
                senderName = chat['craftsman']?['name'] ?? 'صنايعي';
              }

              // Show notification
              await NotificationService().showChatMessageNotification(
                chatId: chatId,
                senderName: senderName,
                message: lastMessage ?? 'رسالة جديدة',
              );
            }
          } else if (lastMessageAt != null) {
            // Update known message time even if read, to avoid notifying old messages
            _lastMessageTimes[chatId] = lastMessageAt;
          }
        }
      }
    } catch (e) {
      print('Error polling chats: $e');
    }
  }

  Future<void> _loadCurrentLocale() async {
    final locale = await LanguageService.getSavedLocale();
    if (mounted) {
      setState(() {
        _currentLocale = locale;
      });
    }
  }

  Future<void> _loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userType = prefs.getString('user_type') ?? 'customer';
      });
    }
  }

  void _startOrderPolling() {
    // Check immediately
    _checkForNewOrders();
    // Then check every 10 seconds
    _orderPollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkForNewOrders();
    });
  }

  Future<void> _checkForNewOrders() async {
    if (_userType != 'craftsman') return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final userId = prefs.getString('user_id');

      if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
        return;
      }

      final headers = Map<String, String>.from(ApiConfig.headers);
      headers['Authorization'] = 'Bearer $token';

      final uri = Uri.parse(
        ApiConfig.ordersList,
      ).replace(queryParameters: {'craftsman_id': userId});

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> raw = data['data'] ?? [];
          final newOrders = raw
              .map<Map<String, dynamic>>(
                (item) => Map<String, dynamic>.from(item),
              )
              .toList();

          // Check for new orders
          for (var order in newOrders) {
            final orderId = order['id'] as int?;
            if (orderId == null) continue;

            final status = (order['craftsman_status'] ?? order['status'] ?? '')
                .toString();

            // Show notification for new waiting_response, awaiting_assignment, or pending orders
            if (!_knownChatOrderIds.contains(orderId) &&
                (status == 'waiting_response' ||
                    status == 'awaiting_assignment' ||
                    status == 'pending')) {
              _knownChatOrderIds.add(orderId);

              print('=== 🎉 NEW ORDER DETECTED (Global) ===');
              print('Order ID: $orderId');
              print('Status: $status');
              print('Title: ${order['title']}');
              print('Customer: ${order['customer_name']}');

              // Show notification with sound
              try {
                await _notificationService.showNewOrderNotification(
                  orderId: orderId,
                  title: order['title'] ?? 'طلب جديد',
                  customerName: order['customer_name'] ?? 'عميل',
                  description: order['description'] ?? '',
                );
                print('✓ Global notification shown successfully');
              } catch (e) {
                print('✗ Error showing global notification: $e');
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error checking for new orders (global): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = _currentLocale.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(
          0xFFfec901,
        ), // خلفية صفراء زاهية مثل الصورة
        appBar: AppBar(
          title: Text(
            l10n.home,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          backgroundColor: const Color(0xFF1976D2), // أزرق داكن مثل الصورة
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Logo Section - مثل الصورة
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1976D2),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Text below logo
                const SizedBox(height: 20),
                Text(
                  l10n.yourServicesOnUs,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                // Help Button - زر المساعدة مثل الصورة
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      openSupportChat(context);
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[300],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.message,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.help,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Service Cards - بطاقات الخدمات مثل الصورة
                const SizedBox(height: 20),

                // First Card - صنايعي وي دو
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CategoryGridScreen(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Title with underline
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(bottom: 10),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFF1976D2),
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                l10n.handymanWedoo,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1976D2),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 15),
                            // Tools image representation
                            Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildToolIcon(Icons.build, 'مثقاب'),
                                  _buildToolIcon(Icons.straighten, 'متر'),
                                  _buildToolIcon(Icons.handyman, 'مطرقة'),
                                  _buildToolIcon(Icons.water_drop, 'صنبور'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Second Card - محلات و معارض
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const ShopsExhibitionsScreen(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Title with underline
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(bottom: 10),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFF1976D2),
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                l10n.shopsExhibitions,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1976D2),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 15),
                            // Materials image representation
                            Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildToolIcon(
                                    Icons.electrical_services,
                                    'أسلاك',
                                  ),
                                  _buildToolIcon(Icons.palette, 'دهان'),
                                  _buildToolIcon(Icons.plumbing, 'مواسير'),
                                  _buildToolIcon(
                                    Icons.home_repair_service,
                                    'أدوات',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Bottom Navigation Bar - شريط التنقل السفلي مثل الصورة
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = _currentLocale.languageCode == 'ar';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.blue,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Directionality(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: isRtl
                  ? [
                      // RTL: من اليمين إلى اليسار
                      _buildNavItem(context, Icons.home, l10n.home, 0),
                      _buildNavItem(
                        context,
                        Icons.description,
                        l10n.appExplanation,
                        1,
                      ),
                      _buildNavItem(
                        context,
                        Icons.receipt_long,
                        l10n.myOrders,
                        2,
                      ),
                      _buildNavItem(context, Icons.settings, l10n.settings, 3),
                    ]
                  : [
                      // LTR: من اليسار إلى اليمين
                      _buildNavItem(context, Icons.settings, l10n.settings, 3),
                      _buildNavItem(
                        context,
                        Icons.receipt_long,
                        l10n.myOrders,
                        2,
                      ),
                      _buildNavItem(
                        context,
                        Icons.description,
                        l10n.appExplanation,
                        1,
                      ),
                      _buildNavItem(context, Icons.home, l10n.home, 0),
                    ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _navigateToScreen(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFFfec901) : Colors.white,
            size: isActive ? 26 : 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFFfec901) : Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(int index) {
    switch (index) {
      case 0:
        // Already on home screen
        break;
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AppExplanationScreen()),
        );
        break;
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _userType == 'craftsman'
                ? const CraftsmanOrdersScreen()
                : const MyOrdersScreen(),
          ),
        );
        break;
      case 3:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
        break;
    }
  }

  // دالة لإنشاء أيقونات الأدوات
  Widget _buildToolIcon(IconData icon, String toolName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF1976D2)),
        ),
        const SizedBox(height: 4),
        Text(toolName, style: const TextStyle(fontSize: 8, color: Colors.grey)),
      ],
    );
  }
}
