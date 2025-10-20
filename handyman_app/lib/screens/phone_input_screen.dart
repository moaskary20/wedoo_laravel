import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'membership_type_screen.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  
  // Backend configuration - Using localhost for development
  static const String _baseUrl = 'http://localhost:8000/api';
  static const String _verifyPhoneEndpoint = '/auth/verify-phone';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFfec901),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.blue),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.blue,
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Phone Input Field
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'الموبايل',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.phone,
                        color: Colors.black,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Next Button
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'التالي',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNext() async {
    if (_phoneController.text.isEmpty) {
      _showErrorSnackBar('يرجى إدخال رقم الهاتف');
      return;
    }

    // Validate phone number format
    if (!_isValidPhoneNumber(_phoneController.text)) {
      _showErrorSnackBar('يرجى إدخال رقم هاتف صحيح');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // For development - simulate phone verification without backend
      await Future.delayed(const Duration(seconds: 1));
      
      // Save phone number temporarily
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('temp_phone_number', _phoneController.text.trim());
      
      // Show success message
      _showSuccessSnackBar('تم التحقق من رقم الهاتف بنجاح');
      
      // Navigate to membership type screen
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MembershipTypeScreen(),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في الاتصال. يرجى التحقق من الإنترنت');
      print('Phone verification error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isValidPhoneNumber(String phone) {
    // Egyptian phone number validation
    final phoneRegex = RegExp(r'^01[0-9]{9}$');
    return phoneRegex.hasMatch(phone);
  }

  Future<String> _getDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString('device_id');
      
      if (deviceId == null) {
        deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString('device_id', deviceId);
      }
      
      return deviceId;
    } catch (e) {
      return 'device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
