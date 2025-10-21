import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      // First, try to load from admin panel
      List<Map<String, dynamic>> orders = await _loadOrdersFromAdminPanel();
      
      // If no orders from admin panel, load from local storage
      if (orders.isEmpty) {
        orders = await _loadOrdersFromLocalStorage();
      }
      
      // If still no orders, add default orders
      if (orders.isEmpty) {
        orders = _getDefaultOrders();
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
      // Get user ID from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      
      if (userId == null) {
        print('No user ID found, using default');
        userId = 'user_123'; // Default user ID for demo
      }
      
      print('Loading orders from admin panel for user: $userId');
      
      // Make actual HTTP request to admin panel
      final response = await http.get(
        Uri.parse('${ApiConfig.ordersList}?user_id=$userId'),
        headers: ApiConfig.headers,
      ).timeout(const Duration(seconds: 30));
      
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          List<dynamic> orders = responseData['data'] ?? [];
          print('Loaded ${orders.length} orders from admin panel');
          return orders.cast<Map<String, dynamic>>();
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
          orders.add(Map<String, dynamic>.from(orderData));
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

  List<Map<String, dynamic>> _getDefaultOrders() {
    return [
      {
        'id': '178288',
        'service': 'نقاش',
        'description': 'وحدة اقل من 3 غرف',
        'location': 'المنتزة - الاسكندرية',
        'time': 'أكثر من شهر',
        'progress': 'قدم 4',
        'status': 'قيد الانتظار',
        'iconName': 'brush',
        'serviceType': 'painter',
        'source': 'default',
      },
      {
        'id': '171554',
        'service': 'كهربائي',
        'description': 'صيانات خفيفة',
        'location': 'البيطاش - الاسكندرية',
        'time': 'أكثر من شهر',
        'progress': 'قدم 5',
        'status': 'قيد الانتظار',
        'iconName': 'electrical_services',
        'serviceType': 'electrician',
        'source': 'default',
      },
      {
        'id': '171552',
        'service': 'سيراميك',
        'description': 'وحدة اقل من 3 غرف',
        'location': 'المنتزة - الاسكندرية',
        'time': 'أكثر من شهر',
        'progress': 'قدم 3',
        'status': 'قيد الانتظار',
        'iconName': 'home_repair_service',
        'serviceType': 'ceramic',
        'source': 'default',
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredOrders {
    if (_searchController.text.isEmpty) {
      return _orders;
    }
    return _orders.where((order) {
      return order['service'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
             order['description'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
             order['location'].toLowerCase().contains(_searchController.text.toLowerCase());
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFfec901),
        appBar: AppBar(
          title: const Text(
            'طلباتي',
            style: TextStyle(
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
        textAlign: TextAlign.right,
        onChanged: (value) {
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: 'بحث في الطلبات',
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
    final filteredOrders = _filteredOrders;
    
    if (filteredOrders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'لا توجد طلبات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
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
                    order['time'],
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
                    order['progress'],
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
                  order['status'],
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
              child: const Text(
                'تفاصيل الطلب',
                style: TextStyle(
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text('تفاصيل الطلب ${order['id']}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('الخدمة:', order['service']),
                _buildDetailRow('الوصف:', order['description']),
                _buildDetailRow('الموقع:', order['location']),
                _buildDetailRow('الوقت:', order['time']),
                _buildDetailRow('التقدم:', order['progress']),
                _buildDetailRow('الحالة:', order['status']),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إغلاق'),
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

  Widget _buildFloatingHelpButton() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('مساعدة'),
            backgroundColor: Colors.green,
          ),
        );
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
