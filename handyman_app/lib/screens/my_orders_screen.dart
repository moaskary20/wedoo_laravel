import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/language_service.dart';
import 'conversations_screen.dart';
import 'review_screen.dart';
import 'package:handyman_app/l10n/app_localizations.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  Locale _currentLocale = LanguageService.defaultLocale;

  @override
  void initState() {
    super.initState();
    _loadOrders();
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

  Future<Map<String, String>?> _buildAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null || token.isEmpty) return null;
    final headers = Map<String, String>.from(ApiConfig.headers);
    headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<void> _loadOrders() async {
    try {
      List<Map<String, dynamic>> orders = await _loadOrdersFromAdminPanel();

      if (orders.isEmpty) {
        orders = await _loadOrdersFromLocalStorage();
      }

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading orders: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _loadOrdersFromAdminPanel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final headers = await _buildAuthHeaders();
      final userId = prefs.getString('user_id');

      if (headers == null) {
        print('Missing auth headers, cannot load orders from backend');
        return [];
      }

      print('Loading orders from admin panel for user: $userId');

      final uri = Uri.parse(ApiConfig.ordersList).replace(queryParameters: {
        if (userId != null && userId.isNotEmpty) 'user_id': userId,
      });

      final response =
          await http.get(uri, headers: headers).timeout(const Duration(seconds: 30));
      
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> orders = responseData['data'] ?? [];
          print('Loaded ${orders.length} orders from admin panel');
          return orders
              .map((order) =>
                  _normalizeBackendOrder(Map<String, dynamic>.from(order)))
              .toList();
        } else {
          throw Exception(responseData['message'] ?? 'Failed to load orders');
        }
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
      
    } catch (e) {
      print('Error loading orders from admin panel: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _loadOrdersFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get orders from SharedPreferences
      final ordersList = prefs.getStringList('user_orders') ?? [];
      List<Map<String, dynamic>> orders = [];
      
      for (String orderString in ordersList) {
        try {
          final orderData = jsonDecode(orderString);
          final map = Map<String, dynamic>.from(orderData);
          map['source'] = map['source'] ?? 'local';
          orders.add(map);
        } catch (e) {
          print('Error parsing order: $e');
        }
      }
      
      print('Loaded ${orders.length} orders from local storage');
      return orders;
      
    } catch (e) {
      print('Error loading orders from local storage: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> get _filteredOrders {
    if (_searchController.text.isEmpty) {
      return _orders;
    }
    final query = _searchController.text.toLowerCase();
    return _orders.where((order) {
      final service = (order['service'] ?? '').toString().toLowerCase();
      final description = (order['description'] ?? '').toString().toLowerCase();
      final location = (order['location'] ?? '').toString().toLowerCase();
      return service.contains(query) ||
          description.contains(query) ||
          location.contains(query);
    }).toList();
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'brush':
        return Icons.brush;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'home_repair_service':
        return Icons.home_repair_service;
      case 'plumbing':
        return Icons.plumbing;
      case 'build':
        return Icons.build;
      case 'construction':
        return Icons.construction;
      default:
        return Icons.home_repair_service;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            l10n.myOrders,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.blue,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _loadOrders();
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            : Stack(
                children: [
                  // Main content
                  Column(
                    children: [
                      // Search Bar
                      _buildSearchBar(),
                      
                      // Orders List
                      Expanded(
                        child: _buildOrdersList(),
                      ),
                    ],
                  ),
            
            // Floating Help Button
            Positioned(
              left: 20,
              top: 100,
              child: _buildFloatingHelpButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFffe480),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textAlign: _currentLocale.languageCode == 'ar' ? TextAlign.right : TextAlign.left,
        onChanged: (value) {
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: l10n.searchInOrders,
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: Icon(
            Icons.search,
            color: Colors.grey[600],
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    final l10n = AppLocalizations.of(context)!;
    final filteredOrders = _filteredOrders;
    
    if (filteredOrders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            l10n.noOrders,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isLoading = true;
        });
        await _loadOrders();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFffe480),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row - Time and Service Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getOrderTimeText(order),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconFromName(order['iconName'] ?? 'home_repair_service'),
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Order ID and Service
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order['id'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                order['service'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Description
          Text(
            order['description'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Location
          Text(
            order['location'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (_formatBudgetForDisplay(order) != null) ...[
            Row(
              children: [
                Icon(
                  Icons.payments,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatBudgetForDisplay(order)!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Bottom row - Progress and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getProgressText(order, l10n),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getStatusText(order, l10n),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Review Button (for completed orders)
          if (_isOrderCompleted(order)) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToReview(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(
                  order['has_review'] == true ? Icons.edit : Icons.star,
                  size: 20,
                ),
                label: Text(
                  order['has_review'] == true ? 'تعديل التقييم' : 'تقييم الصنايعي',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          // Details Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showOrderDetails(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                l10n.orderDetails,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = _currentLocale.languageCode == 'ar';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            title: Text('${l10n.orderDetails} ${order['id']}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('${l10n.service}:', order['service']),
                _buildDetailRow('${l10n.description}:', order['description']),
                _buildDetailRow('${l10n.location}:', order['location']),
                _buildDetailRow('${l10n.time}:', _getOrderTimeText(order)),
                _buildDetailRow('${l10n.progress}:', _getProgressText(order, l10n)),
                _buildDetailRow('${l10n.status}:', _getStatusText(order, l10n)),
                if (_formatBudgetForDisplay(order) != null)
                  _buildDetailRow('${l10n.budget}:', _formatBudgetForDisplay(order)!),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.close),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _normalizeBackendOrder(Map<String, dynamic> raw) {
    // Read status first (updated by admin), then fallback to craftsman_status
    final statusKey =
        (raw['status'] ?? raw['craftsman_status'] ?? 'pending').toString();
    return {
      'id': raw['id']?.toString() ?? '',
      'service': raw['title'] ??
          raw['task_type_name'] ??
          raw['task_type'] ??
          'طلب خدمة',
      'description': raw['description'] ?? '—',
      'location': raw['location'] ?? _composeLocation(raw),
      'time': raw['created_at'],
      'created_at': raw['created_at'],
      'progress_key': statusKey,
      'status_key': statusKey,
      'iconName': _guessIconName(raw['task_type_name'] ?? ''),
      'budget_value': raw['budget'],
      'source': 'backend',
      // Review data
      'has_review': raw['has_review'] ?? false,
      'review': raw['review'],
      // Craftsman and customer info
      'craftsman_name': raw['craftsman_name'],
      'customer_name': raw['customer_name'],
    };
  }

  String _composeLocation(Map<String, dynamic> raw) {
    final parts = <String>[];
    for (final field in ['district', 'city', 'governorate']) {
      final value = raw[field];
      if (value != null && value.toString().trim().isNotEmpty) {
        parts.add(value.toString().trim());
      }
    }
    return parts.isNotEmpty ? parts.join(' - ') : '—';
  }

  String _getOrderTimeText(Map<String, dynamic> order) {
    if (order['source'] == 'default') {
      return order['time'] ?? '';
    }
    final createdAt = order['time'] ?? order['created_at'];
    if (createdAt is String && createdAt.isNotEmpty) {
      try {
        final date = DateTime.parse(createdAt);
        final now = DateTime.now();
        if (date.year == now.year &&
            date.month == now.month &&
            date.day == now.day) {
          return _currentLocale.languageCode == 'ar' ? 'اليوم' : 'Aujourd\'hui';
        }
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      } catch (_) {
        return createdAt;
      }
    }
    return '';
  }

  String _getProgressText(Map<String, dynamic> order, AppLocalizations l10n) {
    if (order['source'] == 'default') {
      return order['progress'] ?? '';
    }
    final statusKey = (order['progress_key'] ?? '').toString();
    switch (statusKey) {
      case 'awaiting_assignment':
      case 'pending_assignment':
      case 'pending':
        return _currentLocale.languageCode == 'ar'
            ? 'جاري مراجعة الطلب'
            : 'Commande en cours de validation';
      case 'waiting_response':
        return _currentLocale.languageCode == 'ar'
            ? 'بانتظار موافقة الصنايعي'
            : 'En attente de l’artisan';
      case 'accepted':
      case 'in_progress':
        return _currentLocale.languageCode == 'ar'
            ? 'الصنايعي يعمل على طلبك'
            : 'Artisan en cours d’intervention';
      case 'completed':
        return _currentLocale.languageCode == 'ar'
            ? 'تم تنفيذ الطلب'
            : 'Commande terminée';
      case 'rejected':
        return _currentLocale.languageCode == 'ar'
            ? 'تم رفض الطلب'
            : 'Commande refusée';
      default:
        return l10n.pending;
    }
  }

  String _getStatusText(Map<String, dynamic> order, AppLocalizations l10n) {
    if (order['source'] == 'default') {
      return order['status'] ?? l10n.pending;
    }
    final statusKey = (order['status_key'] ?? '').toString();
    switch (statusKey) {
      case 'pending':
      case 'pending_assignment':
      case 'awaiting_assignment':
        return _currentLocale.languageCode == 'ar'
            ? 'قيد المراجعة'
            : 'En attente';
      case 'waiting_response':
        return _currentLocale.languageCode == 'ar'
            ? 'بانتظار الصنايعي'
            : 'En attente de l’artisan';
      case 'accepted':
      case 'in_progress':
        return _currentLocale.languageCode == 'ar'
            ? 'جاري التنفيذ'
            : 'En cours';
      case 'completed':
        return _currentLocale.languageCode == 'ar'
            ? 'مكتمل'
            : 'Terminée';
      case 'rejected':
        return _currentLocale.languageCode == 'ar'
            ? 'مرفوض'
            : 'Refusée';
      default:
        return l10n.pendingStatus;
    }
  }

  String? _formatBudgetForDisplay(Map<String, dynamic> order) {
    final value = order['budget_value'] ?? order['budget'];
    if (value == null) return null;

    num? numeric;
    if (value is num) {
      numeric = value;
    } else {
      numeric = num.tryParse(value.toString());
    }

    final amount = numeric != null
        ? (numeric % 1 == 0 ? numeric.toStringAsFixed(0) : numeric.toString())
        : value.toString();
    final suffix = _currentLocale.languageCode == 'fr' ? 'DT' : 'د.ت';
    return '$amount $suffix';
  }

  String _guessIconName(String serviceName) {
    final lower = serviceName.toLowerCase();
    if (lower.contains('كهرب') || lower.contains('elect')) {
      return 'electrical_services';
    }
    if (lower.contains('سباك') || lower.contains('plumb')) {
      return 'plumbing';
    }
    if (lower.contains('نجار') || lower.contains('menuis')) {
      return 'build';
    }
    if (lower.contains('حداد') || lower.contains('metal')) {
      return 'construction';
    }
    if (lower.contains('دهان') || lower.contains('peint')) {
      return 'brush';
    }
    return 'home_repair_service';
  }

  bool _isOrderCompleted(Map<String, dynamic> order) {
    final status = (order['status_key'] ?? order['progress_key'] ?? '').toString();
    return status == 'completed';
  }

  Future<void> _navigateToReview(Map<String, dynamic> order) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReviewScreen(
          orderId: order['id'].toString(),
          craftsmanName: order['craftsman_name'],
          orderTitle: order['service'],
          existingReview: order['review'],
        ),
      ),
    );

    // Reload orders if review was submitted
    if (result == true) {
      setState(() {
        _isLoading = true;
      });
      await _loadOrders();
    }
  }

  Widget _buildFloatingHelpButton() {
    return GestureDetector(
      onTap: () {
        openSupportChat(context);
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.message,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(height: 2),
            const Text(
              'مساعدة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
