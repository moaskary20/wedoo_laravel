import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedGovernorate = 'تونس';
  String _selectedCity = 'تونس العاصمة';
  String _selectedArea = 'الحي الإداري';
  bool _isLoading = false;
  bool _isInitialLoading = true;
  
  // Profile image
  File? _selectedImage;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  // Backend configuration
  static const String _baseUrl = 'https://free-styel.store/api';
  static const String _updateProfileEndpoint = '/user/update-profile';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get user data from SharedPreferences
      final userName = prefs.getString('user_name') ?? '';
      final userEmail = prefs.getString('user_email') ?? '';
      final userPhone = prefs.getString('user_phone') ?? '';
      final userGovernorate = prefs.getString('user_governorate') ?? '';
      final userCity = prefs.getString('user_city') ?? '';
      final userArea = prefs.getString('user_area') ?? '';
      
      setState(() {
        _nameController.text = userName.isNotEmpty ? userName : 'مستخدم';
        _emailController.text = userEmail.isNotEmpty ? userEmail : 'user@example.com';
        _phoneController.text = userPhone.isNotEmpty ? userPhone : '0000000000';
        
        // Set location data with validation
        if (userGovernorate.isNotEmpty && _getGovernorates().contains(userGovernorate)) {
          _selectedGovernorate = userGovernorate;
        }
        if (userCity.isNotEmpty && _getCitiesForGovernorate(_selectedGovernorate).contains(userCity)) {
          _selectedCity = userCity;
        }
        if (userArea.isNotEmpty && _getAreasForCity(_selectedCity).contains(userArea)) {
          _selectedArea = userArea;
        }
        
        _isInitialLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
          title: const Text(
            'تعديل بياناتي',
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
        body: _isInitialLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            : Stack(
                children: [
                  // Main content
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                  
                  // Profile Picture Section
                  _buildProfilePictureSection(),
                  
                  const SizedBox(height: 30),
                  
                  // Name Field
                  _buildInputField(
                    'الاسم',
                    _nameController,
                    Icons.person,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Email Field
                  _buildInputField(
                    'البريد الالكتروني',
                    _emailController,
                    Icons.email,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Password Hint
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: const Text(
                      'اترك كلمتا المرور فارغتين إن لم ترد تغييرها',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // New Password Field
                  _buildInputField(
                    'كلمة المرور الجديدة',
                    _newPasswordController,
                    Icons.lock,
                    isPassword: true,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Confirm Password Field
                  _buildInputField(
                    'تأكيد كلمة المرور',
                    _confirmPasswordController,
                    Icons.lock,
                    isPassword: true,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Location Section
                  _buildLocationSection(),
                  
                  const SizedBox(height: 30),
                  
                  // Contact Information
                  _buildInputField(
                    'بيانات الإتصال',
                    _phoneController,
                    Icons.phone,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Save Button
                  _buildSaveButton(),
                  
                  const SizedBox(height: 100), // Space for floating button
                ],
              ),
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

  Widget _buildProfilePictureSection() {
    return Center(
      child: GestureDetector(
        onTap: _showImagePickerOptions,
        child: Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(60),
                border: Border.all(color: Colors.grey[400]!, width: 2),
              ),
              child: _buildProfileImage(),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_selectedImage != null) {
      if (kIsWeb) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: Image.memory(
            _imageBytes!,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: Image.file(
            _selectedImage!,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        );
      }
    } else {
      return const Icon(
        Icons.person,
        size: 60,
        color: Colors.grey,
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Text(
                'اختر صورة جديدة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('التقاط صورة'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('اختيار من المعرض'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('حذف الصورة'),
                  onTap: () {
                    Navigator.pop(context);
                    _removeImage();
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        
        // Convert to bytes for web compatibility
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _imageBytes = bytes;
          });
        }
        
        _showSuccessSnackBar('تم اختيار الصورة بنجاح');
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في اختيار الصورة');
      print('Image picker error: $e');
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _imageBytes = null;
    });
    _showSuccessSnackBar('تم حذف الصورة');
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
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
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: Icon(
                icon,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'منطقة سكنك',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        
        // Governorate Dropdown
        _buildDropdown(
          'المحافظة',
          _selectedGovernorate,
          [
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
            'بنزرت',
          ],
          (value) {
            setState(() {
              _selectedGovernorate = value!;
              _selectedCity = _getCitiesForGovernorate(value).first;
              _selectedArea = _getAreasForCity(_selectedCity).first;
            });
          },
        ),
        
        const SizedBox(height: 15),
        
        // City Dropdown
        _buildDropdown(
          'المدينة',
          _selectedCity,
          _getCitiesForGovernorate(_selectedGovernorate),
          (value) {
            setState(() {
              _selectedCity = value!;
              _selectedArea = _getAreasForCity(value).first;
            });
          },
        ),
        
        const SizedBox(height: 15),
        
        // Area Dropdown
        _buildDropdown(
          'المنطقة',
          _selectedArea,
          _getAreasForCity(_selectedCity),
          (value) {
            setState(() {
              _selectedArea = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
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
                'حفظ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
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

  List<String> _getGovernorates() {
    return [
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
      'بنزرت',
    ];
  }

  List<String> _getCitiesForGovernorate(String governorate) {
    switch (governorate) {
      case 'تونس':
        return ['تونس العاصمة', 'المرسى', 'سيدي بوسعيد', 'قرطاج', 'أريانة'];
      case 'أريانة':
        return ['أريانة', 'المنيهلة', 'قلعة الأندلس', 'سيدي ثابت', 'الروضة'];
      case 'بن عروس':
        return ['بن عروس', 'المحمدية', 'الزهراء', 'رادس', 'حمام الأنف'];
      case 'منوبة':
        return ['منوبة', 'البطان', 'جندوبة', 'الكاف', 'سليانة'];
      case 'زغوان':
        return ['زغوان', 'الزريبة', 'الفحص', 'نابل', 'حمام الأغزاز'];
      case 'نابل':
        return ['نابل', 'قليبية', 'حمام الأغزاز', 'سليمان', 'بني خلاد'];
      case 'سوسة':
        return ['سوسة', 'المنستير', 'المهدية', 'قصر السعيد', 'القلعة الكبرى'];
      case 'المنستير':
        return ['المنستير', 'قصر السعيد', 'القلعة الكبرى', 'بني حسان', 'الزاوية'];
      case 'المهدية':
        return ['المهدية', 'قصر السعيد', 'القلعة الكبرى', 'بني حسان', 'الزاوية'];
      case 'صفاقس':
        return ['صفاقس', 'سيدي بوزيد', 'القيروان', 'سوسة', 'المهدية'];
      case 'قابس':
        return ['قابس', 'مدنين', 'تطاوين', 'قفصة', 'توزر'];
      case 'مدنين':
        return ['مدنين', 'تطاوين', 'قفصة', 'توزر', 'قبلي'];
      case 'تطاوين':
        return ['تطاوين', 'قفصة', 'توزر', 'قبلي', 'سيدي بوزيد'];
      case 'قفصة':
        return ['قفصة', 'توزر', 'قبلي', 'سيدي بوزيد', 'القيروان'];
      case 'توزر':
        return ['توزر', 'قبلي', 'سيدي بوزيد', 'القيروان', 'صفاقس'];
      case 'قبلي':
        return ['قبلي', 'سيدي بوزيد', 'القيروان', 'صفاقس', 'قابس'];
      case 'سيدي بوزيد':
        return ['سيدي بوزيد', 'القيروان', 'صفاقس', 'قابس', 'مدنين'];
      case 'القيروان':
        return ['القيروان', 'صفاقس', 'قابس', 'مدنين', 'تطاوين'];
      case 'سليانة':
        return ['سليانة', 'باجة', 'جندوبة', 'الكاف', 'منوبة'];
      case 'باجة':
        return ['باجة', 'جندوبة', 'الكاف', 'منوبة', 'سليانة'];
      case 'جندوبة':
        return ['جندوبة', 'الكاف', 'منوبة', 'سليانة', 'باجة'];
      case 'الكاف':
        return ['الكاف', 'منوبة', 'سليانة', 'باجة', 'جندوبة'];
      case 'بنزرت':
        return ['بنزرت', 'أريانة', 'تونس', 'المرسى', 'سيدي بوسعيد'];
      default:
        return ['تونس العاصمة'];
    }
  }

  List<String> _getAreasForCity(String city) {
    switch (city) {
      case 'تونس العاصمة':
        return ['الحي الإداري', 'الحي الجامعي', 'الحي الصناعي', 'الحي السكني'];
      case 'المرسى':
        return ['المرسى', 'المرسى الجديد', 'المرسى القديم', 'المرسى البحري'];
      case 'سيدي بوسعيد':
        return ['سيدي بوسعيد', 'سيدي بوسعيد الجديد', 'سيدي بوسعيد القديم'];
      case 'قرطاج':
        return ['قرطاج', 'قرطاج الجديد', 'قرطاج القديم', 'قرطاج البحري'];
      case 'أريانة':
        return ['أريانة', 'أريانة الجديدة', 'أريانة القديمة', 'أريانة الصناعية'];
      case 'المنيهلة':
        return ['المنيهلة', 'المنيهلة الجديدة', 'المنيهلة القديمة'];
      case 'قلعة الأندلس':
        return ['قلعة الأندلس', 'قلعة الأندلس الجديدة', 'قلعة الأندلس القديمة'];
      case 'سيدي ثابت':
        return ['سيدي ثابت', 'سيدي ثابت الجديد', 'سيدي ثابت القديم'];
      case 'الروضة':
        return ['الروضة', 'الروضة الجديدة', 'الروضة القديمة'];
      case 'بن عروس':
        return ['بن عروس', 'بن عروس الجديدة', 'بن عروس القديمة'];
      case 'المحمدية':
        return ['المحمدية', 'المحمدية الجديدة', 'المحمدية القديمة'];
      case 'الزهراء':
        return ['الزهراء', 'الزهراء الجديدة', 'الزهراء القديمة'];
      case 'رادس':
        return ['رادس', 'رادس الجديدة', 'رادس القديمة'];
      case 'حمام الأنف':
        return ['حمام الأنف', 'حمام الأنف الجديد', 'حمام الأنف القديم'];
      case 'منوبة':
        return ['منوبة', 'منوبة الجديدة', 'منوبة القديمة'];
      case 'البطان':
        return ['البطان', 'البطان الجديد', 'البطان القديم'];
      case 'جندوبة':
        return ['جندوبة', 'جندوبة الجديدة', 'جندوبة القديمة'];
      case 'الكاف':
        return ['الكاف', 'الكاف الجديدة', 'الكاف القديمة'];
      case 'سليانة':
        return ['سليانة', 'سليانة الجديدة', 'سليانة القديمة'];
      case 'زغوان':
        return ['زغوان', 'زغوان الجديدة', 'زغوان القديمة'];
      case 'الزريبة':
        return ['الزريبة', 'الزريبة الجديدة', 'الزريبة القديمة'];
      case 'الفحص':
        return ['الفحص', 'الفحص الجديد', 'الفحص القديم'];
      case 'نابل':
        return ['نابل', 'نابل الجديدة', 'نابل القديمة'];
      case 'حمام الأغزاز':
        return ['حمام الأغزاز', 'حمام الأغزاز الجديد', 'حمام الأغزاز القديم'];
      case 'قليبية':
        return ['قليبية', 'قليبية الجديدة', 'قليبية القديمة'];
      case 'سليمان':
        return ['سليمان', 'سليمان الجديد', 'سليمان القديم'];
      case 'بني خلاد':
        return ['بني خلاد', 'بني خلاد الجديدة', 'بني خلاد القديمة'];
      case 'سوسة':
        return ['سوسة', 'سوسة الجديدة', 'سوسة القديمة'];
      case 'المنستير':
        return ['المنستير', 'المنستير الجديدة', 'المنستير القديمة'];
      case 'المهدية':
        return ['المهدية', 'المهدية الجديدة', 'المهدية القديمة'];
      case 'قصر السعيد':
        return ['قصر السعيد', 'قصر السعيد الجديد', 'قصر السعيد القديم'];
      case 'القلعة الكبرى':
        return ['القلعة الكبرى', 'القلعة الكبرى الجديدة', 'القلعة الكبرى القديمة'];
      case 'بني حسان':
        return ['بني حسان', 'بني حسان الجديدة', 'بني حسان القديمة'];
      case 'الزاوية':
        return ['الزاوية', 'الزاوية الجديدة', 'الزاوية القديمة'];
      case 'صفاقس':
        return ['صفاقس', 'صفاقس الجديدة', 'صفاقس القديمة'];
      case 'قابس':
        return ['قابس', 'قابس الجديدة', 'قابس القديمة'];
      case 'مدنين':
        return ['مدنين', 'مدنين الجديدة', 'مدنين القديمة'];
      case 'تطاوين':
        return ['تطاوين', 'تطاوين الجديدة', 'تطاوين القديمة'];
      case 'قفصة':
        return ['قفصة', 'قفصة الجديدة', 'قفصة القديمة'];
      case 'توزر':
        return ['توزر', 'توزر الجديدة', 'توزر القديمة'];
      case 'قبلي':
        return ['قبلي', 'قبلي الجديدة', 'قبلي القديمة'];
      case 'سيدي بوزيد':
        return ['سيدي بوزيد', 'سيدي بوزيد الجديدة', 'سيدي بوزيد القديمة'];
      case 'القيروان':
        return ['القيروان', 'القيروان الجديدة', 'القيروان القديمة'];
      case 'باجة':
        return ['باجة', 'باجة الجديدة', 'باجة القديمة'];
      case 'بنزرت':
        return ['بنزرت', 'بنزرت الجديدة', 'بنزرت القديمة'];
      default:
        return ['الحي الإداري'];
    }
  }

  Future<void> _saveProfile() async {
    // Validate inputs
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('يرجى إدخال الاسم');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showErrorSnackBar('يرجى إدخال البريد الإلكتروني');
      return;
    }

    if (_newPasswordController.text.isNotEmpty && 
        _newPasswordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('كلمة المرور الجديدة غير متطابقة');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare profile data
      Map<String, dynamic> profileData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'governorate': _selectedGovernorate,
        'city': _selectedCity,
        'area': _selectedArea,
        'location': '$_selectedGovernorate, $_selectedCity, $_selectedArea',
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add image if selected
      if (_selectedImage != null) {
        if (kIsWeb && _imageBytes != null) {
          // For web, convert image to base64
          profileData['profile_image'] = base64Encode(_imageBytes!);
          profileData['image_type'] = 'base64';
        } else if (!kIsWeb) {
          // For mobile, send image path
          profileData['profile_image_path'] = _selectedImage!.path;
          profileData['image_type'] = 'file';
        }
      }

      // Add password if provided
      if (_newPasswordController.text.isNotEmpty) {
        profileData['password'] = _newPasswordController.text;
      }

      // Send to admin panel
      await _sendProfileToAdminPanel(profileData);
      
      // Save to SharedPreferences (simulate local storage)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameController.text.trim());
      await prefs.setString('user_email', _emailController.text.trim());
      await prefs.setString('user_phone', _phoneController.text.trim());
      await prefs.setString('user_governorate', _selectedGovernorate);
      await prefs.setString('user_city', _selectedCity);
      await prefs.setString('user_area', _selectedArea);
      await prefs.setString('user_location', '$_selectedGovernorate, $_selectedCity, $_selectedArea');
      
      if (_newPasswordController.text.isNotEmpty) {
        await prefs.setString('user_password', _newPasswordController.text);
      }
      
      // Save profile image if selected
      if (_selectedImage != null) {
        await _saveProfileImageToAdminPanel(profileData);
        
        // Also save locally for immediate display
        await _saveProfileImageLocally();
      }

      // TODO: Uncomment when backend is ready
      /*
      // Real API call to save profile
      final response = await http.put(
        Uri.parse('$_baseUrl$_updateProfileEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await _getUserToken()}',
        },
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          _showSuccessSnackBar('تم حفظ البيانات بنجاح');
        } else {
          _showErrorSnackBar(responseData['message'] ?? 'فشل في حفظ البيانات');
        }
      } else {
        _showErrorSnackBar('خطأ في الخادم. يرجى المحاولة مرة أخرى');
      }
      */

      _showSuccessSnackBar('تم حفظ البيانات بنجاح في الـ admin panel');
      
      // Navigate back with success result
      if (mounted) {
        Navigator.of(context).pop(true);
      }
      
    } catch (e) {
      _showErrorSnackBar('خطأ في الاتصال. يرجى التحقق من الإنترنت');
      print('Profile save error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  Future<void> _sendProfileToAdminPanel(Map<String, dynamic> profileData) async {
    try {
      // Simulate API call to admin panel
      await Future.delayed(const Duration(seconds: 1));
      
      // Prepare admin panel data
      final adminData = {
        'user_id': await _getUserId(),
        'profile_data': profileData,
        'update_type': 'profile_update',
        'timestamp': DateTime.now().toIso8601String(),
        'fields_updated': _getUpdatedFields(profileData),
      };
      
      // Save to SharedPreferences (simulate admin panel)
      final prefs = await SharedPreferences.getInstance();
      List<String> profileUpdates = prefs.getStringList('admin_profile_updates') ?? [];
      profileUpdates.add(jsonEncode(adminData));
      await prefs.setStringList('admin_profile_updates', profileUpdates);
      
      print('Profile data sent to admin panel: $adminData');
      
    } catch (e) {
      print('Error sending profile to admin panel: $e');
      rethrow;
    }
  }

  Future<void> _saveProfileImageToAdminPanel(Map<String, dynamic> profileData) async {
    try {
      // Simulate image upload to admin panel
      await Future.delayed(const Duration(seconds: 2));
      
      // Prepare image data for admin panel
      final imageData = {
        'user_id': await _getUserId(),
        'image_type': profileData['image_type'],
        'image_data': profileData['profile_image'] ?? profileData['profile_image_path'],
        'upload_timestamp': DateTime.now().toIso8601String(),
        'image_size': _imageBytes?.length ?? 0,
        'update_type': 'profile_image_update',
      };
      
      // Save to SharedPreferences (simulate admin panel)
      final prefs = await SharedPreferences.getInstance();
      List<String> imageUpdates = prefs.getStringList('admin_profile_images') ?? [];
      imageUpdates.add(jsonEncode(imageData));
      await prefs.setStringList('admin_profile_images', imageUpdates);
      
      print('Profile image saved to admin panel: ${imageData['image_size']} bytes');
      
    } catch (e) {
      print('Error saving profile image to admin panel: $e');
      rethrow;
    }
  }

  List<String> _getUpdatedFields(Map<String, dynamic> profileData) {
    List<String> updatedFields = [];
    
    if (profileData.containsKey('name')) updatedFields.add('name');
    if (profileData.containsKey('email')) updatedFields.add('email');
    if (profileData.containsKey('phone')) updatedFields.add('phone');
    if (profileData.containsKey('governorate')) updatedFields.add('governorate');
    if (profileData.containsKey('city')) updatedFields.add('city');
    if (profileData.containsKey('area')) updatedFields.add('area');
    if (profileData.containsKey('password')) updatedFields.add('password');
    if (profileData.containsKey('profile_image')) updatedFields.add('profile_image');
    
    return updatedFields;
  }

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? '1';
  }

  Future<void> _saveProfileImageLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_selectedImage != null) {
        if (kIsWeb && _imageBytes != null) {
          // For web, save as base64
          final base64Image = base64Encode(_imageBytes!);
          await prefs.setString('user_profile_image', base64Image);
          print('Profile image saved locally as base64: ${base64Image.length} characters');
        } else if (!kIsWeb) {
          // For mobile, save file path
          await prefs.setString('user_profile_image', _selectedImage!.path);
          print('Profile image saved locally as file path: ${_selectedImage!.path}');
        }
      }
    } catch (e) {
      print('Error saving profile image locally: $e');
    }
  }
}
