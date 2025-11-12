import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'service_request_form.dart';
import 'tips_screen.dart';
import 'conversations_screen.dart';
import '../config/api_config.dart';
import 'package:handyman_app/l10n/app_localizations.dart';

class ServiceScreen extends StatefulWidget {
  final String categoryName;
  final String categoryIcon;
  final Color categoryColor;
  final int categoryId;

  const ServiceScreen({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.categoryId,
  });

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  int _craftsmanCount = 0;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCraftsmanCount();
  }

  Future<void> _fetchCraftsmanCount() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Real API call to get craftsman count
      final response = await http.get(
        Uri.parse('${ApiConfig.craftsmanCount}?category_id=${widget.categoryId}'),
        headers: ApiConfig.headers,
      ).timeout(const Duration(seconds: 30));

      print('Craftsman Count API Response Status: ${response.statusCode}');
      print('Craftsman Count API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _craftsmanCount = data['data']['count'] ?? 0;
            _isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch craftsman count');
        }
      } else {
        throw Exception('Failed to fetch craftsman count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching craftsman count: $e');
      setState(() {
        _errorMessage = 'خطأ في الاتصال: ${e.toString()}';
        _isLoading = false;
        _craftsmanCount = 0; // Set to 0 on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFfec901),
        appBar: AppBar(
          title: Text(
            widget.categoryName,
            style: const TextStyle(
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
                  Text(
                    AppLocalizations.of(context)?.craftsmenInThisTask ?? 'يتواجد في هذه المهمة',
                    style: const TextStyle(
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
                        AppLocalizations.of(context)?.createServiceRequestButton ?? 'انشاء طلب',
                        Icons.arrow_back,
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ServiceRequestForm(
                                categoryName: widget.categoryName,
                                categoryIcon: widget.categoryIcon,
                                categoryColor: widget.categoryColor,
                                categoryId: widget.categoryId, // Pass category ID directly from backend
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 15),
                      
                      _buildActionButton(
                        context,
                        AppLocalizations.of(context)?.craftSecrets ?? 'اعرف سر الصنعة',
                        Icons.arrow_back,
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TipsScreen(
                                categoryName: widget.categoryName,
                                categoryIcon: widget.categoryIcon,
                                categoryColor: widget.categoryColor,
                                categoryId: widget.categoryId,
                              ),
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
              child: _buildFloatingHelpButton(
                AppLocalizations.of(context)?.help ?? 'مساعدة',
                Icons.message,
                () {
                  openSupportChat(context);
                },
              ),
            ),
          ],
        ),
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

  Widget _buildFloatingHelpButton(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              text,
              style: const TextStyle(
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
