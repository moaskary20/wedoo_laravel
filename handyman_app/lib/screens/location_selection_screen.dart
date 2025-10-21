import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  String? _selectedGovernorate;
  String? _selectedCity;
  String? _selectedDistrict;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  // Sample data - replace with actual data from backend
  final List<String> _governorates = [
    'تونس',
    'أريانة',
    'بن عروس',
    'منوبة',
    'زغوان',
    'نابل',
    'سوسة',
    'المنستير',
    'المهدية',
    'صفاقس',
    'قابس',
    'مدنين',
    'تطاوين',
    'قفصة',
    'توزر',
    'قبلي',
    'سيدي بوزيد',
    'القيروان',
    'سليانة',
    'باجة',
    'جندوبة',
    'الكاف',
    'سليانة',
    'بنزرت',
  ];

  final Map<String, List<String>> _cities = {
    'تونس': ['تونس العاصمة', 'المرسى', 'سيدي بوسعيد', 'قرطاج', 'أريانة'],
    'أريانة': ['أريانة', 'المنيهلة', 'قلعة الأندلس', 'سيدي ثابت', 'الروضة'],
    'بن عروس': ['بن عروس', 'المحمدية', 'الزهراء', 'رادس', 'حمام الأنف'],
    'منوبة': ['منوبة', 'البطان', 'جندوبة', 'الكاف', 'سليانة'],
    'زغوان': ['زغوان', 'الزريبة', 'الفحص', 'نابل', 'حمام الأغزاز'],
    'نابل': ['نابل', 'قليبية', 'حمام الأغزاز', 'سليمان', 'بني خلاد'],
    'سوسة': ['سوسة', 'المنستير', 'المهدية', 'قصر السعيد', 'القلعة الكبرى'],
    'المنستير': ['المنستير', 'قصر السعيد', 'القلعة الكبرى', 'بني حسان', 'الزاوية'],
    'المهدية': ['المهدية', 'قصر السعيد', 'القلعة الكبرى', 'بني حسان', 'الزاوية'],
    'صفاقس': ['صفاقس', 'سيدي بوزيد', 'القيروان', 'سوسة', 'المهدية'],
    'قابس': ['قابس', 'مدنين', 'تطاوين', 'قفصة', 'توزر'],
    'مدنين': ['مدنين', 'تطاوين', 'قفصة', 'توزر', 'قبلي'],
    'تطاوين': ['تطاوين', 'قفصة', 'توزر', 'قبلي', 'سيدي بوزيد'],
    'قفصة': ['قفصة', 'توزر', 'قبلي', 'سيدي بوزيد', 'القيروان'],
    'توزر': ['توزر', 'قبلي', 'سيدي بوزيد', 'القيروان', 'صفاقس'],
    'قبلي': ['قبلي', 'سيدي بوزيد', 'القيروان', 'صفاقس', 'قابس'],
    'سيدي بوزيد': ['سيدي بوزيد', 'القيروان', 'صفاقس', 'قابس', 'مدنين'],
    'القيروان': ['القيروان', 'صفاقس', 'قابس', 'مدنين', 'تطاوين'],
    'سليانة': ['سليانة', 'باجة', 'جندوبة', 'الكاف', 'منوبة'],
    'باجة': ['باجة', 'جندوبة', 'الكاف', 'منوبة', 'سليانة'],
    'جندوبة': ['جندوبة', 'الكاف', 'منوبة', 'سليانة', 'باجة'],
    'الكاف': ['الكاف', 'منوبة', 'سليانة', 'باجة', 'جندوبة'],
    'بنزرت': ['بنزرت', 'أريانة', 'تونس', 'المرسى', 'سيدي بوسعيد'],
  };

  final Map<String, List<String>> _districts = {
    'تونس العاصمة': ['الحي الإداري', 'الحي الجامعي', 'الحي الصناعي', 'الحي السكني'],
    'المرسى': ['المرسى', 'المرسى الجديد', 'المرسى القديم', 'المرسى البحري'],
    'سيدي بوسعيد': ['سيدي بوسعيد', 'سيدي بوسعيد الجديد', 'سيدي بوسعيد القديم'],
    'قرطاج': ['قرطاج', 'قرطاج الجديد', 'قرطاج القديم', 'قرطاج البحري'],
    'أريانة': ['أريانة', 'أريانة الجديدة', 'أريانة القديمة', 'أريانة الصناعية'],
    'المنيهلة': ['المنيهلة', 'المنيهلة الجديدة', 'المنيهلة القديمة'],
    'قلعة الأندلس': ['قلعة الأندلس', 'قلعة الأندلس الجديدة', 'قلعة الأندلس القديمة'],
    'سيدي ثابت': ['سيدي ثابت', 'سيدي ثابت الجديد', 'سيدي ثابت القديم'],
    'الروضة': ['الروضة', 'الروضة الجديدة', 'الروضة القديمة'],
    'بن عروس': ['بن عروس', 'بن عروس الجديدة', 'بن عروس القديمة'],
    'المحمدية': ['المحمدية', 'المحمدية الجديدة', 'المحمدية القديمة'],
    'الزهراء': ['الزهراء', 'الزهراء الجديدة', 'الزهراء القديمة'],
    'رادس': ['رادس', 'رادس الجديدة', 'رادس القديمة'],
    'حمام الأنف': ['حمام الأنف', 'حمام الأنف الجديد', 'حمام الأنف القديم'],
    'منوبة': ['منوبة', 'منوبة الجديدة', 'منوبة القديمة'],
    'البطان': ['البطان', 'البطان الجديد', 'البطان القديم'],
    'جندوبة': ['جندوبة', 'جندوبة الجديدة', 'جندوبة القديمة'],
    'الكاف': ['الكاف', 'الكاف الجديدة', 'الكاف القديمة'],
    'سليانة': ['سليانة', 'سليانة الجديدة', 'سليانة القديمة'],
    'زغوان': ['زغوان', 'زغوان الجديدة', 'زغوان القديمة'],
    'الزريبة': ['الزريبة', 'الزريبة الجديدة', 'الزريبة القديمة'],
    'الفحص': ['الفحص', 'الفحص الجديد', 'الفحص القديم'],
    'نابل': ['نابل', 'نابل الجديدة', 'نابل القديمة'],
    'حمام الأغزاز': ['حمام الأغزاز', 'حمام الأغزاز الجديد', 'حمام الأغزاز القديم'],
    'قليبية': ['قليبية', 'قليبية الجديدة', 'قليبية القديمة'],
    'سليمان': ['سليمان', 'سليمان الجديد', 'سليمان القديم'],
    'بني خلاد': ['بني خلاد', 'بني خلاد الجديدة', 'بني خلاد القديمة'],
    'سوسة': ['سوسة', 'سوسة الجديدة', 'سوسة القديمة'],
    'المنستير': ['المنستير', 'المنستير الجديدة', 'المنستير القديمة'],
    'المهدية': ['المهدية', 'المهدية الجديدة', 'المهدية القديمة'],
    'قصر السعيد': ['قصر السعيد', 'قصر السعيد الجديد', 'قصر السعيد القديم'],
    'القلعة الكبرى': ['القلعة الكبرى', 'القلعة الكبرى الجديدة', 'القلعة الكبرى القديمة'],
    'بني حسان': ['بني حسان', 'بني حسان الجديدة', 'بني حسان القديمة'],
    'الزاوية': ['الزاوية', 'الزاوية الجديدة', 'الزاوية القديمة'],
    'صفاقس': ['صفاقس', 'صفاقس الجديدة', 'صفاقس القديمة'],
    'قابس': ['قابس', 'قابس الجديدة', 'قابس القديمة'],
    'مدنين': ['مدنين', 'مدنين الجديدة', 'مدنين القديمة'],
    'تطاوين': ['تطاوين', 'تطاوين الجديدة', 'تطاوين القديمة'],
    'قفصة': ['قفصة', 'قفصة الجديدة', 'قفصة القديمة'],
    'توزر': ['توزر', 'توزر الجديدة', 'توزر القديمة'],
    'قبلي': ['قبلي', 'قبلي الجديدة', 'قبلي القديمة'],
    'سيدي بوزيد': ['سيدي بوزيد', 'سيدي بوزيد الجديدة', 'سيدي بوزيد القديمة'],
    'القيروان': ['القيروان', 'القيروان الجديدة', 'القيروان القديمة'],
    'باجة': ['باجة', 'باجة الجديدة', 'باجة القديمة'],
    'بنزرت': ['بنزرت', 'بنزرت الجديدة', 'بنزرت القديمة'],
  };

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
                
                const SizedBox(height: 40),
                
                // Divider line
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey[300],
                ),
                
                const SizedBox(height: 20),
                
                // Section title
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'منطقة سكنك',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Governorate Dropdown
                _buildDropdown(
                  value: _selectedGovernorate,
                  hint: 'المحافظة',
                  items: _governorates,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedGovernorate = value;
                      _selectedCity = null;
                      _selectedDistrict = null;
                    });
                  },
                ),
                
                const SizedBox(height: 15),
                
                // City Dropdown
                _buildDropdown(
                  value: _selectedCity,
                  hint: 'المدينة',
                  items: _selectedGovernorate != null 
                      ? _cities[_selectedGovernorate] ?? []
                      : [],
                  onChanged: (String? value) {
                    setState(() {
                      _selectedCity = value;
                      _selectedDistrict = null;
                    });
                  },
                ),
                
                const SizedBox(height: 15),
                
                // District Dropdown
                _buildDropdown(
                  value: _selectedDistrict,
                  hint: 'الحي',
                  items: _selectedCity != null 
                      ? _districts[_selectedCity] ?? []
                      : [],
                  onChanged: (String? value) {
                    setState(() {
                      _selectedDistrict = value;
                    });
                  },
                ),
                
                const SizedBox(height: 30),
                
                // Terms of Use Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (bool? value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                      activeColor: Colors.blue,
                    ),
                    const Expanded(
                      child: Text(
                        'لقد قرأت شروط الاستخدام وأوافق عليها',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Create Button
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
                    onPressed: _isLoading ? null : _handleCreate,
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
                            'انشاء',
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

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _handleCreate() async {
    if (_selectedGovernorate == null || 
        _selectedCity == null || 
        _selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار المحافظة والمدينة والحي'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى الموافقة على شروط الاستخدام'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get user data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      
      // Prepare registration data
      final registrationData = {
        'name': prefs.getString('temp_user_name') ?? '',
        'phone': prefs.getString('temp_phone_number') ?? '',
        'email': prefs.getString('temp_user_email') ?? '',
        'password': prefs.getString('temp_user_password') ?? '',
        'user_type': prefs.getString('temp_user_type') ?? 'customer',
        'governorate': _selectedGovernorate!,
        'city': _selectedCity!,
        'district': _selectedDistrict!,
      };

      // Send registration data to backend
      final response = await http.post(
        Uri.parse('https://free-styel.store/api/auth/register.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(registrationData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['success'] == true) {
          // Save user data to SharedPreferences
          final userData = responseData['data'];
          await prefs.setString('user_id', userData['id'].toString());
          await prefs.setString('user_name', userData['name']);
          await prefs.setString('user_phone', userData['phone']);
          await prefs.setString('user_email', userData['email']);
          await prefs.setString('user_governorate', userData['governorate']);
          await prefs.setString('user_city', userData['city']);
          await prefs.setString('user_area', userData['district']);
          await prefs.setString('user_membership_code', userData['membership_code']);
          await prefs.setString('access_token', userData['access_token']);
          await prefs.setString('refresh_token', userData['refresh_token']);
          await prefs.setBool('is_logged_in', true);
          await prefs.setString('login_timestamp', DateTime.now().toIso8601String());
          
          // Clear temporary data
          await _clearTempData();
          
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إنشاء الحساب بنجاح!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );

            // Navigate back to login screen
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
              (route) => false,
            );
          }
        } else {
          throw Exception(responseData['message'] ?? 'Registration failed');
        }
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في التسجيل: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Registration error: $e');
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

  Future<void> _clearTempData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('temp_user_name');
      await prefs.remove('temp_user_email');
      await prefs.remove('temp_user_password');
      await prefs.remove('temp_user_age_range');
      await prefs.remove('temp_user_type');
    } catch (e) {
      print('Error clearing temp data: $e');
    }
  }
}