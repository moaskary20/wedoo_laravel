import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'service_request_form.dart';
import 'tips_screen.dart';
import 'service_screen.dart';
import 'craft_secrets_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryName;
  final String categoryIcon;
  final Color categoryColor;
  final int categoryId;

  const CategoryDetailScreen({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.categoryId,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  int _craftsmanCount = 0;
  bool _isLoading = true;
  String _errorMessage = '';

  // Backend configuration
  static const String _baseUrl = 'https://free-styel.store/api';
  static const String _getCraftsmanCountEndpoint = '/craftsman/count';

  @override
  void initState() {
    super.initState();
    _loadCraftsmanCount();
  }

  Future<void> _loadCraftsmanCount() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // For development - simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate different counts based on category
      int simulatedCount = _getSimulatedCount();
      
      setState(() {
        _craftsmanCount = simulatedCount;
        _isLoading = false;
      });

      // TODO: Uncomment when backend is ready
      /*
      // Real API call to get craftsman count
      final response = await http.get(
        Uri.parse('$_baseUrl$_getCraftsmanCountEndpoint?category_id=${widget.categoryId}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _craftsmanCount = data['count'] ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'خطأ في تحميل البيانات';
          _isLoading = false;
        });
      }
      */
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في تحميل البيانات';
        _isLoading = false;
      });
    }
  }

  int _getSimulatedCount() {
    // Simulate different counts based on category ID
    switch (widget.categoryId) {
      case 1: return 1250; // الكهرباء
      case 2: return 890;  // السباكة
      case 3: return 2100;  // النجارة
      case 4: return 750;   // الدهان
      case 5: return 1100; // التكييف
      case 6: return 650;  // الأقفال
      case 7: return 950;  // الألمنيوم
      case 8: return 800;  // السيراميك
      case 9: return 1200; // المصاعد
      case 10: return 450; // الأثاث
      case 11: return 700; // الحدادة
      case 12: return 550; // النجارة
      default: return 1000;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfec901),
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // Craftsman count text
                const Text(
                  'عدد الصنايعية في هذه المهنة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 10),
                
                // Large number display
                if (_isLoading)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                  )
                else if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  )
                else
                  Text(
                    _craftsmanCount.toString(),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                
                const SizedBox(height: 30),
                
                // Craftsman illustration
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.engineering,
                    size: 60,
                    color: Colors.orange,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Action Buttons
                Column(
                  children: [
              _buildActionButton(
                context,
                'انشاء طلب',
                Icons.arrow_back,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ServiceRequestForm(
                        categoryName: widget.categoryName,
                        categoryIcon: widget.categoryIcon,
                        categoryColor: widget.categoryColor,
                      ),
                    ),
                  );
                },
              ),
                    
                    const SizedBox(height: 15),
                    
                    _buildActionButton(
                      context,
                      'اعرف سر الصنعة',
                      Icons.arrow_back,
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CraftSecretsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Floating Help Button
          Positioned(
            left: 20,
            top: 100,
            child: FloatingActionButton(
              onPressed: () {
                // Handle help button press
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('مساعدة'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              backgroundColor: Colors.green.withValues(alpha: 0.8),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.message,
                    color: Colors.white,
                    size: 20,
                  ),
                  Text(
                    'مساعدة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFEEF8C),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              Icon(
                Icons.chevron_left,
                size: 18,
                color: Colors.black87,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'home_repair':
        return Icons.home_repair_service;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'directions_car':
        return Icons.directions_car;
      case 'emergency':
        return Icons.emergency;
      case 'family_restroom':
        return Icons.family_restroom;
      case 'computer':
        return Icons.computer;
      case 'yard':
        return Icons.yard;
      case 'handyman':
        return Icons.handyman;
      case 'solar_power':
        return Icons.solar_power;
      case 'school':
        return Icons.school;
      case 'celebration':
        return Icons.celebration;
      case 'flight':
        return Icons.flight;
      case 'business':
        return Icons.business;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'business_center':
        return Icons.business_center;
      case 'accessibility':
        return Icons.accessibility;
      default:
        return Icons.build;
    }
  }
}
