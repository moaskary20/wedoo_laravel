import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:handyman_app/l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../config/api_config.dart';
import 'conversations_screen.dart';
import '../services/notification_service.dart';

class CraftsmanOrdersScreen extends StatefulWidget {
  const CraftsmanOrdersScreen({super.key});

  @override
  State<CraftsmanOrdersScreen> createState() => _CraftsmanOrdersScreenState();
}

class _CraftsmanOrdersScreenState extends State<CraftsmanOrdersScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _orders = [];
  Set<int> _knownOrderIds = {};
  Timer? _pollingTimer;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _fetchOrders().then((_) {
      // After initial load, check for pending orders and show notifications
      if (mounted) {
        // First, mark all current orders as known to prevent duplicate notifications
        _knownOrderIds = _orders
            .where((o) => o['id'] != null)
            .map((o) => o['id'] as int)
            .toSet();
        print('Initial known order IDs: ${_knownOrderIds.length}');
        
        // Check for pending orders and show notifications for them
        _checkPendingOrdersForNotification();
      }
    });
    // Start polling immediately
    _startPolling();
    // Also check immediately after a short delay
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _checkForNewOrders();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    try {
      await _notificationService.initialize();
      print('✓ Notification service initialized');
      
      // Handle notification actions - use the same instance
      final notifications = FlutterLocalNotificationsPlugin();
      await notifications.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          ),
        ),
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('Notification action received: ${response.actionId}, payload: ${response.payload}');
          _handleNotificationAction(response);
        },
      );
      print('✓ Notification handler registered');
    } catch (e) {
      print('✗ Error initializing notifications: $e');
    }
  }

  void _handleNotificationAction(NotificationResponse response) {
    print('=== Handling notification action ===');
    print('Action ID: ${response.actionId}');
    print('Payload: ${response.payload}');
    
    if (response.payload == null) {
      print('No payload, refreshing orders');
      _fetchOrders();
      return;
    }
    
    // Extract order ID from payload (format: "order_123")
    final payload = response.payload!;
    if (!payload.startsWith('order_')) {
      print('Invalid payload format: $payload');
      _fetchOrders();
      return;
    }
    
    final orderIdStr = payload.replaceFirst('order_', '');
    final orderId = int.tryParse(orderIdStr);
    if (orderId == null) {
      print('Invalid order ID: $orderIdStr');
      _fetchOrders();
      return;
    }

    print('Processing action for order ID: $orderId');

    switch (response.actionId) {
      case 'accept':
        print('Accept action triggered');
        _respondToOrder(orderId, true);
        break;
      case 'reject':
        print('Reject action triggered');
        _respondToOrder(orderId, false);
        break;
      case 'chat':
        print('Chat action triggered');
        // Find the order in the current list
        final order = _orders.firstWhere(
          (o) => o['id'] == orderId,
          orElse: () => {},
        );
        if (order.isNotEmpty) {
          _openChatWithCustomer(order);
        } else {
          // If order not found, refresh and try again
          print('Order not found in list, refreshing...');
          _fetchOrders().then((_) {
            final refreshedOrder = _orders.firstWhere(
              (o) => o['id'] == orderId,
              orElse: () => {},
            );
            if (refreshedOrder.isNotEmpty) {
              _openChatWithCustomer(refreshedOrder);
            }
          });
        }
        break;
      default:
        // If notification is tapped (not an action), refresh and show the order
        print('Notification tapped (no action), refreshing orders');
        _fetchOrders();
        break;
    }
  }

  void _startPolling() {
    // Poll every 10 seconds for new orders (more frequent for better responsiveness)
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _checkForNewOrders();
      }
    });
  }

  Future<void> _checkForNewOrders() async {
    try {
      print('=== Checking for new orders ===');
      final headers = await _buildAuthHeaders();
      if (headers == null) {
        print('No auth headers available');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null || userId.isEmpty) {
        print('No user ID available');
        return;
      }

      final uri = Uri.parse(ApiConfig.ordersList).replace(queryParameters: {
        'craftsman_id': userId,
      });

      print('Fetching orders from: $uri');

      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 30),
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> raw = data['data'] ?? [];
          final newOrders = raw
              .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
              .toList();

          print('Total orders received: ${newOrders.length}');
          print('Known order IDs: ${_knownOrderIds.length}');

          // Check for new orders
          for (var order in newOrders) {
            final orderId = order['id'] as int?;
            if (orderId == null) continue;

            final status = (order['craftsman_status'] ?? order['status'] ?? '').toString();
            
            // Show notification for new waiting_response, awaiting_assignment, or pending orders
            if (!_knownOrderIds.contains(orderId) && 
                (status == 'waiting_response' || status == 'awaiting_assignment' || status == 'pending')) {
              _knownOrderIds.add(orderId);
              
              print('=== 🎉 NEW ORDER DETECTED ===');
              print('Order ID: $orderId');
              print('Status: $status');
              print('Title: ${order['title']}');
              print('Customer: ${order['customer_name']}');
              print('Known order IDs before: ${_knownOrderIds.length - 1}');
              print('Known order IDs after: ${_knownOrderIds.length}');
              
              // Show notification with sound
              try {
                print('Attempting to show notification...');
                await _notificationService.showNewOrderNotification(
                  orderId: orderId,
                  title: order['title'] ?? 'طلب جديد',
                  customerName: order['customer_name'] ?? 'عميل',
                  description: order['description'] ?? '',
                );
                print('✓ Notification shown successfully');
                
                // Show dialog in the middle of the screen
                if (mounted) {
                  print('Showing dialog in middle of screen...');
                  _showNewOrderDialog(
                    orderId: orderId,
                    title: order['title'] ?? 'طلب جديد',
                    customerName: order['customer_name'] ?? 'عميل',
                    description: order['description'] ?? '',
                    order: order,
                  );
                  print('✓ Dialog shown successfully');
                } else {
                  print('⚠ Widget not mounted, cannot show dialog');
                }
              } catch (e) {
                print('✗ Error showing notification/dialog: $e');
                print('Stack trace: ${StackTrace.current}');
              }
            } else {
              if (_knownOrderIds.contains(orderId)) {
                print('Order $orderId already known, skipping notification');
              } else {
                print('Order $orderId status is $status, not eligible for notification');
              }
            }
          }

          // Update orders list
          // Note: Don't update _knownOrderIds here to allow detection of new orders
          // _knownOrderIds is only updated when a new order is detected and notification is shown
          if (mounted) {
            setState(() {
              _orders = newOrders;
            });
          }
        }
      }
    } catch (e) {
      print('Error checking for new orders: $e');
    }
  }

  Future<void> _checkPendingOrdersForNotification() async {
    // Wait a bit to ensure notifications are initialized
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    print('=== Checking for pending orders on screen load ===');
    print('Total orders: ${_orders.length}');
    
    // Check all current orders for pending status and show notifications
    for (var order in _orders) {
      final orderId = order['id'] as int?;
      if (orderId == null) continue;

      final status = (order['craftsman_status'] ?? order['status'] ?? '').toString();
      
      print('Checking order $orderId with status: $status');
      
      // Show notification for pending orders (waiting_response, awaiting_assignment, or pending)
      if (status == 'waiting_response' || status == 'awaiting_assignment' || status == 'pending') {
        print('=== 🎉 Found pending order on screen load ===');
        print('Order ID: $orderId');
        print('Status: $status');
        print('Title: ${order['title']}');
        print('Customer: ${order['customer_name']}');
        
        // Show notification with sound
        try {
          print('Attempting to show notification for pending order...');
          await _notificationService.showNewOrderNotification(
            orderId: orderId,
            title: order['title'] ?? 'طلب جديد',
            customerName: order['customer_name'] ?? 'عميل',
            description: order['description'] ?? '',
          );
          print('✓ Notification shown successfully for pending order');
          
          // Wait a bit before showing dialog to ensure notification is displayed
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Show dialog in the middle of the screen
          if (mounted) {
            print('Showing dialog for pending order...');
            _showNewOrderDialog(
              orderId: orderId,
              title: order['title'] ?? 'طلب جديد',
              customerName: order['customer_name'] ?? 'عميل',
              description: order['description'] ?? '',
              order: order,
            );
            print('✓ Dialog shown successfully for pending order');
          }
        } catch (e) {
          print('✗ Error showing notification/dialog for pending order: $e');
          print('Stack trace: ${StackTrace.current}');
        }
        
        // Only show notification for the first pending order to avoid spam
        break;
      }
    }
  }

  Future<Map<String, String>?> _buildAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null || token.isEmpty) return null;
    final headers = Map<String, String>.from(ApiConfig.headers);
    headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final headers = await _buildAuthHeaders();
      if (headers == null) {
        setState(() {
          _errorMessage = 'يرجى تسجيل الدخول مرة أخرى';
          _isLoading = false;
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null || userId.isEmpty) {
        setState(() {
          _errorMessage = 'تعذر تحديد حساب الصنايعي. يرجى تسجيل الدخول من جديد.';
          _isLoading = false;
        });
        return;
      }

      final uri = Uri.parse(ApiConfig.ordersList).replace(queryParameters: {
        'craftsman_id': userId,
      });

      final response =
          await http.get(uri, headers: headers).timeout(const Duration(seconds: 30));
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final List<dynamic> raw = data['data'] ?? [];
          final orders = raw
              .map<Map<String, dynamic>>(
                  (item) => Map<String, dynamic>.from(item))
              .toList();
          
          // Don't update _knownOrderIds here - only update when we detect a new order
          // This allows us to detect new orders that arrive after initial load
          // _knownOrderIds will be updated in _checkForNewOrders when a new order is detected
          
          setState(() {
            _orders = orders;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'فشل تحميل الطلبات';
          });
        }
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'فشل تحميل الطلبات (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في الاتصال: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _respondToOrder(int orderId, bool accept) async {
    final headers = await _buildAuthHeaders();
    if (headers == null) {
      setState(() {
        _errorMessage = 'يرجى تسجيل الدخول مرة أخرى';
      });
      return;
    }

    final uri = Uri.parse(
      accept ? ApiConfig.orderAccept(orderId) : ApiConfig.orderReject(orderId),
    );

    try {
      final response =
          await http.post(uri, headers: headers).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        await _fetchOrders();
        if (accept && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.dataSavedSuccessfully,
              ),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'لم يتم تحديث الطلب (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ أثناء تحديث الطلب: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.myOrders,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _orders.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noOrders ?? 'لا توجد طلبات حالياً',
                        style: const TextStyle(fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchOrders,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          return _buildOrderCard(order);
                        },
                      ),
                    ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _errorMessage ?? 'حدث خطأ',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _fetchOrders,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final l10n = AppLocalizations.of(context)!;
    final status = (order['craftsman_status'] ?? order['status'] ?? '').toString();
    final waitingResponse = status == 'waiting_response';
    final accepted = status == 'accepted';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order['title'] ?? l10n.service,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (order['customer_name'] != null) ...[
              const SizedBox(height: 4),
              Text(
                '${_localizedText('العميل', 'Client')}: ${order['customer_name']}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
            const SizedBox(height: 8),
            Text(order['description'] ?? ''),
            // Display images if available
            if (order['images'] != null && (order['images'] as List).isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: (order['images'] as List).length,
                  itemBuilder: (context, imgIndex) {
                    final imageUrl = (order['images'] as List)[imgIndex] as String;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_pin, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(order['location'] ?? ''),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _mapStatusLabel(status),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: accepted ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            if (waitingResponse) _buildActionButtons(order),
            if (accepted) ...[
              ElevatedButton.icon(
                onPressed: () => _openChatWithCustomer(order),
                icon: const Icon(Icons.chat, size: 20),
                label: Text(_localizedText('التحدث مع العميل', 'Parler au client')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _respondToOrder(order['id'], true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(_localizedText('أوافق', 'Accepter')),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _respondToOrder(order['id'], false),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: Text(_localizedText('أرفض', 'Refuser')),
          ),
        ),
      ],
    );
  }

  String _mapStatusLabel(String status) {
    switch (status) {
      case 'waiting_response':
        return _localizedText('بانتظار موافقتك', 'En attente de votre réponse');
      case 'accepted':
        return _localizedText('تم قبول الطلب', 'Commande acceptée');
      case 'rejected':
        return _localizedText('تم رفض الطلب', 'Commande refusée');
      default:
        return _localizedText('حالة الطلب غير معروفة', 'Statut inconnu');
    }
  }

  String _localizedText(String ar, String fr) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? ar : fr;
  }

  void _showNewOrderDialog({
    required int orderId,
    required String title,
    required String customerName,
    required String description,
    required Map<String, dynamic> order,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must interact with the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.notifications_active,
                color: Colors.blue,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _localizedText('طلب جديد', 'Nouvelle commande'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _localizedText('من: $customerName', 'De: $customerName'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
          actions: [
            // Reject button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _respondToOrder(orderId, false);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(
                _localizedText('رفض', 'Refuser'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Accept button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _respondToOrder(orderId, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                _localizedText('قبول', 'Accepter'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Chat button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openChatWithCustomer(order);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                _localizedText('التحدث', 'Discuter'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openChatWithCustomer(Map<String, dynamic> order) async {
    final customerId = order['customer_id'];
    final customerName = order['customer_name'] ?? _localizedText('العميل', 'Client');
    final orderId = order['id'];
    
    if (customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_localizedText('لا يمكن فتح المحادثة: معلومات العميل غير متوفرة', 'Impossible d\'ouvrir la conversation: informations client non disponibles')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get current user (craftsman) ID
    final prefs = await SharedPreferences.getInstance();
    final craftsmanId = prefs.getString('user_id');
    
    if (craftsmanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_localizedText('خطأ: يجب تسجيل الدخول أولاً', 'Erreur: Vous devez vous connecter d\'abord')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create conversation data for the customer
    // Note: In openCraftsmanChat, 'craftsman' refers to the other party (customer in this case)
    // But we need to pass the current craftsman ID for the API
    final conversation = {
      'id': customerId.toString(), // Customer ID (the other party)
      'name': customerName,
      'service': order['title'] ?? _localizedText('خدمة', 'Service'),
      'lastMessage': _localizedText('ابدأ المحادثة الآن', 'Commencez la discussion maintenant'),
      'time': DateTime.now().toString(),
      'unreadCount': 0,
      'isOnline': false,
      'avatar': null,
      'isSupport': false,
      'chat_id': order['chat_id'],
      'craftsman': {
        'id': customerId, // Customer ID (the other party in the chat)
        'name': customerName,
      },
      'customer_id': customerId, // Customer ID for API
      'craftsman_id': int.parse(craftsmanId), // Current user (craftsman) ID for API
      'order_id': orderId,
    };

    openCraftsmanChat(context, conversation);
  }
}

