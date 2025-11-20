import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'location_selection_screen.dart';

class CraftsmanRegistrationScreen extends StatefulWidget {
  const CraftsmanRegistrationScreen({super.key});

  @override
  State<CraftsmanRegistrationScreen> createState() => _CraftsmanRegistrationScreenState();
}

class _CraftsmanRegistrationScreenState extends State<CraftsmanRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedAgeRange;
  int? _selectedCategoryId;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isLoadingCategories = true;
  List<Map<String, dynamic>> _categories = [];
  String? _categoryError;

  final List<String> _ageRanges = ['20-35', '35-45', '45-65'];
  
  // Backend configuration - Using localhost
  static const String _baseUrl = 'https://free-styel.store/api';
  static const String _saveCraftsmanDataEndpoint = '/auth/save-craftsman-data';
  
  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoryError = null;
    });

    try {
      final response = await http
          .get(Uri.parse(ApiConfig.categoriesList), headers: ApiConfig.headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final items = (data['data'] as List<dynamic>? ?? [])
              .where((item) => item['id'] != null)
              .map<Map<String, dynamic>>((item) {
            return {
              'id': item['id'],
              'name': item['name_ar'] ??
                  item['name'] ??
                  item['title'] ??
                  item['name_fr'] ??
                  'القسم',
            };
          }).toList();

          setState(() {
            _categories = items.isNotEmpty ? items : _buildFallbackCategories();
            if (items.isEmpty) {
              _categoryError = 'تم تحميل قائمة الأقسام الافتراضية';
            }
          });
        } else {
          throw Exception(data['message'] ?? 'فشل تحميل الأقسام');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _categories = _buildFallbackCategories();
        _categoryError = 'تعذر تحميل الأقسام، تم تحميل قائمة افتراضية';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _buildFallbackCategories() {
    return [
      {'id': 1, 'name': 'خدمات صيانة المنازل'},
      {'id': 2, 'name': 'خدمات التنظيف'},
      {'id': 3, 'name': 'النقل والخدمات اللوجستية'},
      {'id': 4, 'name': 'خدمات السيارات'},
      {'id': 5, 'name': 'خدمات طارئة (عاجلة)'},
      {'id': 6, 'name': 'خدمات الأسر والعائلات'},
      {'id': 7, 'name': 'خدمات تقنية'},
      {'id': 8, 'name': 'خدمات الحديقة'},
    ];
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Logo
                Container(
                  width: 100,
                  height: 100,
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
                    Icons.build,
                    size: 50,
                    color: Colors.blue,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Name Field
                _buildInputField(
                  controller: _nameController,
                  hintText: 'الاسم',
                  icon: Icons.person,
                ),
                
                const SizedBox(height: 20),
                
                // Email Field
                _buildInputField(
                  controller: _emailController,
                  hintText: 'البريد الإلكتروني',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                
                const SizedBox(height: 20),
                
                // Password Field
                _buildInputField(
                  controller: _passwordController,
                  hintText: 'ادخل كلمة مرور جديدة',
                  icon: Icons.lock,
                  isPassword: true,
                ),
                
                const SizedBox(height: 30),
                
                // Age Range Selection
                const Text(
                  'حدد فئاتك العمرية',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.right,
                ),
                
                const SizedBox(height: 15),
                
                ..._ageRanges.map((ageRange) => _buildAgeRangeOption(ageRange)),
                
                const SizedBox(height: 30),
                
                _buildCategoryDropdown(),
                
                const SizedBox(height: 40),
                
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return Container(
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
        controller: controller,
        keyboardType: keyboardType,
        textAlign: TextAlign.right,
        obscureText: isPassword ? !_isPasswordVisible : false,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.black,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAgeRangeOption(String ageRange) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Radio<String>(
            value: ageRange,
            groupValue: _selectedAgeRange,
            onChanged: (String? value) {
              setState(() {
                _selectedAgeRange = value;
              });
            },
            activeColor: Colors.blue,
          ),
          Text(
            ageRange,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    if (_isLoadingCategories) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_categories.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'لا توجد أقسام متاحة حالياً',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
          TextButton(
            onPressed: _loadCategories,
            child: const Text('إعادة تحميل الأقسام'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'اختر القسم الذي تعمل به',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: _selectedCategoryId,
              hint: const Text('اختر القسم'),
              items: _categories.map((category) {
                return DropdownMenuItem<int>(
                  value: category['id'] as int,
                  child: Text(category['name'] as String),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),
          ),
        ),
        if (_categoryError != null) ...[
          const SizedBox(height: 8),
          Text(
            _categoryError!,
            style: const TextStyle(color: Colors.orange, fontSize: 12),
          ),
        ],
      ],
    );
  }

  void _handleNext() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _selectedAgeRange == null ||
        _selectedCategoryId == null) {
      _showErrorSnackBar('يرجى ملء جميع الحقول');
      return;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      _showErrorSnackBar('يرجى إدخال بريد إلكتروني صحيح');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // For development - simulate craftsman data saving without backend
      await Future.delayed(const Duration(seconds: 1));
      
      // Get phone number, membership type, and craftsman type from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      
      // Save user data temporarily
      await prefs.setString('temp_user_name', _nameController.text);
      await prefs.setString('temp_user_email', _emailController.text.trim());
      await prefs.setString('temp_user_password', _passwordController.text);
      await prefs.setString('temp_user_age_range', _selectedAgeRange!);
      await prefs.setString('temp_user_type', 'craftsman');
      await prefs.setInt('temp_user_category_id', _selectedCategoryId!);
      
      // Show success message
      _showSuccessSnackBar('تم حفظ بيانات الصنايعي بنجاح');
      
      // Navigate to location selection screen
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const LocationSelectionScreen(),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في الاتصال. يرجى التحقق من الإنترنت');
      print('Craftsman registration error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
