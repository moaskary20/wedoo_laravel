import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'location_selection_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ServiceRequestForm extends StatefulWidget {
  final String categoryName;
  final String categoryIcon;
  final Color categoryColor;

  const ServiceRequestForm({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
  });

  @override
  State<ServiceRequestForm> createState() => _ServiceRequestFormState();
}

class _ServiceRequestFormState extends State<ServiceRequestForm> {
  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Image picker
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  List<Uint8List> _imageBytes = [];
  
  // Location
  String _selectedLocationText = 'Cairo, Egypt, Cairo';
  
  // Google Maps
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng _selectedLocation = const LatLng(30.0444, 31.2357); // Cairo coordinates
  
  // Interactive map marker position
  Offset _markerPosition = const Offset(150, 100); // Initial marker position

  // Step 1: Task Type
  String? _selectedTaskType;
  List<Map<String, dynamic>> _taskTypes = [];
  bool _isLoadingTaskTypes = false;

  // Step 2: Task Specifications
  final TextEditingController _taskDescriptionController = TextEditingController();
  final TextEditingController _urgencyController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  String _selectedUrgency = 'عادي';
  final List<String> _urgencyLevels = ['عاجل', 'عادي', 'غير عاجل'];

  // Step 3: Location
  Map<String, dynamic>? _savedLocation;
  bool _useSavedLocation = true;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
    _fetchTaskTypes();
  }

  Future<void> _loadSavedLocation() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('location_saved') == true) {
        setState(() {
          _savedLocation = {
            'address': prefs.getString('address') ?? '',
            'city': prefs.getString('city') ?? '',
            'country': prefs.getString('country') ?? '',
            'latitude': prefs.getDouble('latitude') ?? 0.0,
            'longitude': prefs.getDouble('longitude') ?? 0.0,
          };
          setState(() {
          _selectedLocationText = '${_savedLocation!['address']}, ${_savedLocation!['city']}';
          });
        });
      }
    } catch (e) {
      print('Error loading saved location: $e');
    }
  }

  Future<void> _fetchTaskTypes() async {
    try {
      setState(() {
        _isLoadingTaskTypes = true;
      });

      final response = await http.get(
        Uri.parse('http://localhost:8000/api/task-types/index.php'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            _taskTypes = (data['data'] as List).cast<Map<String, dynamic>>();
            _isLoadingTaskTypes = false;
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load task types: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching task types: $e');
      setState(() {
        _isLoadingTaskTypes = false;
        // Fallback to default task types if API fails
        _taskTypes = [
          {
            'id': 1,
            'name': 'وحدة اقل من 3 غرف',
            'name_en': 'Unit less than 3 rooms',
            'description': 'خدمات صيانة للوحدات الصغيرة',
            'price_range': '50-200 دينار تونسي',
            'duration': '1-3 ساعات',
            'difficulty': 'easy',
          },
          {
            'id': 2,
            'name': 'وحدة 3 غرف او اكثر',
            'name_en': 'Unit 3 rooms or more',
            'description': 'خدمات صيانة للوحدات الكبيرة',
            'price_range': '200-500 دينار تونسي',
            'duration': '3-6 ساعات',
            'difficulty': 'medium',
          },
          {
            'id': 3,
            'name': 'مرمات خفيفة اقل من 20 م2',
            'name_en': 'Light repairs less than 20 m2',
            'description': 'اعمال ليوم او يومان على الاكثر',
            'price_range': '100-300 دينار تونسي',
            'duration': '1-2 يوم',
            'difficulty': 'easy',
          },
        ];
      });
    }
  }

  @override
  void dispose() {
    _taskDescriptionController.dispose();
    _urgencyController.dispose();
    _budgetController.dispose();
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
          'إنشاء طلب خدمة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
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
          Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),
          
          // Form Content
          Expanded(
            child: _buildFormContent(),
          ),
          
          // Navigation Buttons
          _buildNavigationButtons(),
        ],
          ),
          
        ],
      ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepIndicator(0, '1'),
          _buildStepConnector(),
          _buildStepIndicator(1, '2'),
          _buildStepConnector(),
          _buildStepIndicator(2, '3'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title) {
    bool isActive = step == _currentStep;
    bool isCompleted = step < _currentStep;
    
    return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
        color: isActive ? Colors.blue : (isCompleted ? Colors.blue : const Color(0xFFfec901)),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                title,
                      style: TextStyle(
                  color: isActive ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
      ),
    );
  }

  Widget _buildStepConnector() {
    return Container(
      height: 2,
      width: 40,
      color: _currentStep > 0 ? Colors.blue : const Color(0xFFfec901),
    );
  }

  Widget _buildFormContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'جاري إرسال الطلب...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                'خطأ في إرسال الطلب',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isLoading = false;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('حاول مرة أخرى'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return _buildStep1();
    }
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFffe480),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          const Text(
            'نوع المهمة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 20),
              
              // Task Type Options
              if (_isLoadingTaskTypes)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                ..._taskTypes.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> taskType = entry.value;
                  bool isSelected = _selectedTaskType == taskType['name'];
                  
                  return Column(
                    children: [
                      RadioListTile<String>(
                        title: Text(
                          taskType['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (taskType['description'] != null && taskType['description'].isNotEmpty)
                              Text(
                                taskType['description'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            if (taskType['price_range'] != null)
                              Text(
                                'السعر: ${taskType['price_range']}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            if (taskType['duration'] != null)
                              Text(
                                'المدة: ${taskType['duration']}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.right,
                              ),
                          ],
                        ),
                        value: taskType['name'] ?? '',
                        groupValue: _selectedTaskType,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedTaskType = value;
                          });
                        },
                        activeColor: Colors.blue,
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (index < _taskTypes.length - 1)
                        const Divider(height: 1),
                    ],
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مواصفات المهمة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 20),
          
          // Task Description
          const Text(
            'وصف المهمة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _taskDescriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'اكتب وصفاً مفصلاً للمهمة المطلوبة...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Urgency Level
          const Text(
            'مستوى الأولوية',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedUrgency,
                isExpanded: true,
                items: _urgencyLevels.map((String urgency) {
                  return DropdownMenuItem<String>(
                    value: urgency,
                    child: Text(urgency),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUrgency = newValue!;
                  });
                },
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Budget
          const Text(
            'الميزانية المتوقعة (اختياري)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'مثال: 500 ريال',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.attach_money),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task Location Section
          _buildLocationSection(),
          
          const SizedBox(height: 20),
          
          // Map Section
          _buildMapSection(),
          
          const SizedBox(height: 20),
          
          // Image Upload Section
          _buildImageUploadSection(),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Task Location Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFffe480),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'مكان المهمة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Current Location
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFffe480),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _selectedLocationText,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Edit Location Button
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFfec901),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange[300]!),
            ),
            child: const Text(
              'تعديل المكان',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Map Container
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildMapWidget(),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFffe480),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'أضف صور (اختياري)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Image placeholders
        Row(
          children: List.generate(5, (index) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
              color: Colors.blue,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: GestureDetector(
                  onTap: () => _showImagePicker(index),
                  child: _buildImageWidget(index),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _showImagePicker(int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'اختر مصدر الصورة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceOption(
                      'الكاميرا',
                      Icons.camera_alt,
                      () => _pickImage(ImageSource.camera, index),
                    ),
                    _buildImageSourceOption(
                      'المعرض',
                      Icons.photo_library,
                      () => _pickImage(ImageSource.gallery, index),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
                ),
              ],
            ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, int index) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          // Ensure we have enough slots in the lists
          while (_selectedImages.length <= index) {
            _selectedImages.add(File(''));
          }
          while (_imageBytes.length <= index) {
            _imageBytes.add(Uint8List(0));
          }
          
          _selectedImages[index] = File(image.path);
          
          // For web compatibility, read image as bytes
          if (kIsWeb) {
            image.readAsBytes().then((bytes) {
              setState(() {
                _imageBytes[index] = bytes;
              });
            });
          }
        });
        
        Navigator.of(context).pop(); // Close bottom sheet
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة الصورة بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        Navigator.of(context).pop(); // Close bottom sheet even if no image selected
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close bottom sheet on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إضافة الصورة: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildMapWidget() {
    return Stack(
              children: [
        // Try to show Google Map, fallback to placeholder if error
        _buildGoogleMapWithFallback(),
        
        // Map pin overlay
        Positioned(
          top: 80,
          left: MediaQuery.of(context).size.width / 2 - 20,
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleMapWithFallback() {
    return _buildInteractiveMapPlaceholder();
  }

  Widget _buildInteractiveMapPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[50]!,
            Colors.green[50]!,
            Colors.yellow[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
      child: Stack(
        children: [
          // Map-like background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: MapPatternPainter(),
            ),
          ),
          
          // Interactive map area
          Positioned.fill(
            child: GestureDetector(
              onTapDown: (details) {
                // Move marker to tap position
                    setState(() {
                  _updateLocationFromTap(details.localPosition);
                    });
                  },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          
          // Draggable map pin
          Positioned(
            top: _markerPosition.dy - 20,
            left: _markerPosition.dx - 20,
            child: GestureDetector(
              onPanUpdate: (details) {
                    setState(() {
                  _markerPosition = details.localPosition;
                  _updateLocationFromDrag(details.localPosition);
                    });
                  },
              onPanEnd: (details) {
                // Final position update
                _updateLocationFromDrag(_markerPosition);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          
          // Map instructions
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'اضغط على الخريطة لتحريك العلامة أو اسحب العلامة الحمراء',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Map attribution
          Positioned(
            bottom: 4,
            left: 8,
            child: Text(
              'Map ©2025',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateLocationFromTap(Offset position) {
    setState(() {
      _markerPosition = position;
    });
    _updateLocationFromDrag(position);
  }

  void _updateLocationFromDrag(Offset position) {
    // Simulate location update based on drag position
    String locationText = '';
    if (position.dx < 100) {
      locationText = 'المنتزة - الاسكندرية';
    } else if (position.dx < 200) {
      locationText = 'مدينة نصر - القاهرة';
    } else if (position.dx < 300) {
      locationText = 'المعادي - القاهرة';
    } else if (position.dx < 400) {
      locationText = 'الزمالك - القاهرة';
    } else {
      locationText = 'موقع مخصص';
    }
    
    setState(() {
      _selectedLocationText = locationText;
    });
  }

  Widget _buildMapPlaceholder() {
    return GestureDetector(
      onTap: () => _showLocationPicker(),
      child: Container(
              width: double.infinity,
        height: double.infinity,
              decoration: BoxDecoration(
          color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
        child: const Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Icon(
                Icons.map,
                size: 50,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
                  Text(
                'خريطة الموقع',
                    style: TextStyle(
                      fontSize: 16,
                  color: Colors.grey,
                    ),
                  ),
              SizedBox(height: 4),
                  Text(
                'اضغط لاختيار الموقع',
                    style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildImageWidget(int index) {
    bool hasImage = _selectedImages.length > index && 
                   _selectedImages[index].path.isNotEmpty;
    
    if (!hasImage) {
      return const Center(
        child: Icon(
          Icons.camera_alt,
          color: Colors.blue,
          size: 30,
        ),
      );
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: kIsWeb && _imageBytes.length > index && _imageBytes[index].isNotEmpty
          ? Image.memory(
              _imageBytes[index],
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 30,
                  ),
                );
              },
            )
          : Image.file(
              _selectedImages[index],
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 30,
                  ),
                );
              },
            ),
    );
  }

  void _updateLocationText(LatLng position) {
    // Simple location text update based on coordinates
    String locationText = '';
    if (position.latitude > 31.0 && position.latitude < 31.5 && 
        position.longitude > 29.5 && position.longitude < 30.0) {
      locationText = 'المنتزة - الاسكندرية';
    } else if (position.latitude > 30.0 && position.latitude < 30.1 && 
               position.longitude > 31.2 && position.longitude < 31.3) {
      locationText = 'مدينة نصر - القاهرة';
    } else if (position.latitude > 29.9 && position.latitude < 30.0 && 
               position.longitude > 31.2 && position.longitude < 31.3) {
      locationText = 'المعادي - القاهرة';
    } else if (position.latitude > 30.0 && position.latitude < 30.1 && 
               position.longitude > 31.1 && position.longitude < 31.2) {
      locationText = 'الزمالك - القاهرة';
    } else if (position.latitude > 30.0 && position.latitude < 30.1 && 
               position.longitude > 31.3 && position.longitude < 31.4) {
      locationText = 'الرحاب - القاهرة';
    } else if (position.latitude > 30.0 && position.latitude < 30.1 && 
               position.longitude > 30.9 && position.longitude < 31.0) {
      locationText = 'الشيخ زايد - الجيزة';
    } else if (position.latitude > 30.0 && position.latitude < 30.1 && 
               position.longitude > 30.8 && position.longitude < 30.9) {
      locationText = 'الهرم - الجيزة';
    } else if (position.latitude > 30.1 && position.latitude < 30.2 && 
               position.longitude > 31.4 && position.longitude < 31.5) {
      locationText = 'مدينة الشروق - القاهرة';
    } else {
      locationText = 'موقع مخصص (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
    }
    
    setState(() {
      _selectedLocationText = locationText;
    });
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Color(0xFFfec901),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
      decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
      child: Row(
        children: [
                      const Text(
                        'اختيار الموقع',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                
                // Location options
            Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildLocationOption('المنتزة - الاسكندرية', 'Alexandria, Egypt'),
                        _buildLocationOption('مدينة نصر - القاهرة', 'Nasr City, Cairo, Egypt'),
                        _buildLocationOption('المعادي - القاهرة', 'Maadi, Cairo, Egypt'),
                        _buildLocationOption('الزمالك - القاهرة', 'Zamalek, Cairo, Egypt'),
                        _buildLocationOption('الرحاب - القاهرة', 'Rehab, Cairo, Egypt'),
                        _buildLocationOption('الشيخ زايد - الجيزة', 'Sheikh Zayed, Giza, Egypt'),
                        _buildLocationOption('الهرم - الجيزة', 'Giza, Egypt'),
                        _buildLocationOption('مدينة الشروق - القاهرة', 'Shorouk City, Cairo, Egypt'),
                      ],
                    ),
                  ),
                ),
                
                // Confirm button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1e3a8a),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                        'تأكيد الموقع',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                          color: Colors.white,
                  ),
                ),
              ),
            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationOption(String arabicName, String englishName) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLocationText = arabicName;
        });
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم اختيار الموقع: $arabicName'),
            backgroundColor: Colors.green,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFffe480),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 12),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    arabicName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    englishName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
            child: ElevatedButton(
              onPressed: _currentStep == 2 ? _submitRequest : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
            _currentStep == 2 ? 'نشر' : 'التالي',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      ),
    );
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
    });
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_selectedTaskType == null) {
          _showErrorSnackBar('يرجى اختيار نوع المهمة');
          return false;
        }
        return true;
      case 1:
        if (_taskDescriptionController.text.trim().isEmpty) {
          _showErrorSnackBar('يرجى كتابة وصف المهمة');
          return false;
        }
        if (_taskDescriptionController.text.trim().length < 10) {
          _showErrorSnackBar('يرجى كتابة وصف أكثر تفصيلاً (10 أحرف على الأقل)');
          return false;
        }
        return true;
      case 2:
        if (!_useSavedLocation && _savedLocation == null) {
          _showErrorSnackBar('يرجى اختيار موقع للمهمة');
          return false;
        }
        return true;
      default:
        return true;
    }
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

  Future<void> _submitRequest() async {
    if (!_validateCurrentStep()) return;

    // Additional validation before submission
    if (_selectedTaskType == null) {
      _showErrorSnackBar('يرجى اختيار نوع المهمة');
      return;
    }

    if (_taskDescriptionController.text.trim().isEmpty) {
      _showErrorSnackBar('يرجى كتابة وصف المهمة');
      return;
    }

    if (_taskDescriptionController.text.trim().length < 10) {
      _showErrorSnackBar('يرجى كتابة وصف أكثر تفصيلاً (10 أحرف على الأقل)');
      return;
    }

    if (!_useSavedLocation && _savedLocation == null) {
      _showErrorSnackBar('يرجى اختيار موقع للمهمة');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Find selected task type details
      Map<String, dynamic>? selectedTaskTypeDetails;
      for (var taskType in _taskTypes) {
        if (taskType['name'] == _selectedTaskType) {
          selectedTaskTypeDetails = taskType;
          break;
        }
      }

      // Prepare request data
      Map<String, dynamic> requestData = {
        'task_type': _selectedTaskType,
        'task_type_id': selectedTaskTypeDetails?['id'],
        'task_type_details': selectedTaskTypeDetails,
        'category': widget.categoryName,
        'description': _taskDescriptionController.text.trim(),
        'urgency': _selectedUrgency,
        'budget': _budgetController.text.trim().isNotEmpty 
            ? _budgetController.text.trim() 
            : null,
        'use_saved_location': _useSavedLocation,
        'location': _useSavedLocation && _savedLocation != null
            ? {
                'address': _savedLocation!['address'],
                'city': _savedLocation!['city'],
                'country': _savedLocation!['country'],
                'latitude': _savedLocation!['latitude'],
                'longitude': _savedLocation!['longitude'],
              }
            : null,
        'images': _selectedImages.map((image) => image.path).toList(),
        'created_at': DateTime.now().toIso8601String(),
        'status': 'pending',
        'user_id': await _getUserId(),
      };

      // For development - simulate API calls
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate successful request submission
      print('Request submitted to admin panel: $requestData');
      
      // Simulate finding nearest craftsman
      await _findNearestCraftsman(requestData);
      
      // Simulate saving to user orders
      await _saveToUserOrders(requestData);
      
      // Show success dialog with chat option
      _showSuccessDialogWithChat();
      
    } catch (e) {
      print('Error submitting request: $e');
      setState(() {
        _errorMessage = 'خطأ في إرسال الطلب: $e';
        _isLoading = false;
      });
      
      // Show error message to user
      _showErrorSnackBar('خطأ في إرسال الطلب. يرجى المحاولة مرة أخرى');
    }
  }

  Future<void> _findNearestCraftsman(Map<String, dynamic> requestData) async {
    // Simulate finding nearest craftsman
    await Future.delayed(const Duration(seconds: 1));
    
    // Calculate real distance (simulate GPS calculation)
    double realDistance = _calculateRealDistance();
    String distanceText = '${realDistance.toStringAsFixed(1)} كم';
    
    // Simulate craftsman data
    Map<String, dynamic> nearestCraftsman = {
      'id': 123,
      'name': 'أحمد محمد',
      'rating': 4.8,
      'distance': distanceText,
      'real_distance_km': realDistance,
      'specialization': widget.categoryName,
      'phone': '+216123456789',
      'is_available': true,
      'location': {
        'lat': 36.8065,
        'lng': 10.1815,
      },
    };
    
    print('Nearest craftsman found: $nearestCraftsman');
    
    // Save craftsman info for chat
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_craftsman', jsonEncode(nearestCraftsman));
    
    // Send chat notification to craftsman
    await _sendChatNotificationToCraftsman(nearestCraftsman);
  }

  double _calculateRealDistance() {
    // Simulate real distance calculation based on GPS coordinates
    // In real app, this would use actual GPS coordinates
    double baseDistance = 1.5 + (DateTime.now().millisecond % 100) / 100.0;
    return baseDistance;
  }

  Future<void> _sendChatNotificationToCraftsman(Map<String, dynamic> craftsman) async {
    try {
      // Simulate sending notification to craftsman
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Save chat session to admin panel
      final chatData = {
        'customer_id': await _getUserId(),
        'craftsman_id': craftsman['id'],
        'service_type': widget.categoryName,
        'distance_km': craftsman['real_distance_km'],
        'status': 'new_chat',
        'timestamp': DateTime.now().toIso8601String(),
        'message': 'طلب خدمة جديد من العميل',
      };
      
      // Save to SharedPreferences (simulate admin panel)
      final prefs = await SharedPreferences.getInstance();
      List<String> chatSessions = prefs.getStringList('admin_chat_sessions') ?? [];
      chatSessions.add(jsonEncode(chatData));
      await prefs.setStringList('admin_chat_sessions', chatSessions);
      
      print('Chat notification sent to craftsman: $chatData');
    } catch (e) {
      print('Error sending chat notification: $e');
    }
  }

  Future<void> _saveToUserOrders(Map<String, dynamic> requestData) async {
    try {
      // Simulate saving to user orders
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Generate order ID
      String orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
      
      // Prepare order data
      Map<String, dynamic> orderData = {
        'id': orderId,
        'service': widget.categoryName,
        'description': requestData['description'] ?? 'طلب خدمة جديد',
        'location': requestData['location']?['address'] ?? 'الموقع المحفوظ',
        'time': 'اليوم',
        'progress': 'قدم 1',
        'status': 'قيد الانتظار',
        'iconName': _getServiceIconName(widget.categoryName),
        'serviceType': _getServiceType(widget.categoryName),
        'created_at': DateTime.now().toIso8601String(),
        'user_id': await _getUserId(),
      };
      
      // Save to SharedPreferences (simulate database)
      final prefs = await SharedPreferences.getInstance();
      List<String> orders = prefs.getStringList('user_orders') ?? [];
      orders.add(jsonEncode(orderData));
      await prefs.setStringList('user_orders', orders);
      
      print('Order saved to user orders: $orderData');
      print('Total orders now: ${orders.length}');
      
      // Also save to admin panel
      await _saveToAdminPanel(orderData);
      
    } catch (e) {
      print('Error saving to user orders: $e');
    }
  }

  Future<void> _saveToAdminPanel(Map<String, dynamic> orderData) async {
    try {
      final adminData = {
        'order_id': orderData['id'],
        'user_id': orderData['user_id'],
        'service': orderData['service'],
        'description': orderData['description'],
        'location': orderData['location'],
        'status': orderData['status'],
        'created_at': orderData['created_at'],
        'type': 'service_request',
      };
      
      // Send to admin panel API
      await _sendOrderToAdminPanel(adminData);
      
      // Also save locally for backup
      final prefs = await SharedPreferences.getInstance();
      List<String> adminOrders = prefs.getStringList('admin_orders') ?? [];
      adminOrders.add(jsonEncode(adminData));
      await prefs.setStringList('admin_orders', adminOrders);
      
      print('Order saved to admin panel: $adminData');
    } catch (e) {
      print('Error saving to admin panel: $e');
    }
  }

  Future<void> _sendOrderToAdminPanel(Map<String, dynamic> orderData) async {
    try {
      // Simulate API call to admin panel
      await Future.delayed(const Duration(seconds: 1));
      
      // In real app, this would be an actual HTTP request
      print('Sending order to admin panel API: $orderData');
      
      // Simulate successful response
      print('Order successfully registered in admin panel');
      
    } catch (e) {
      print('Error sending order to admin panel: $e');
      throw e;
    }
  }

  IconData _getServiceIcon(String categoryName) {
    switch (categoryName) {
      case 'نقاش':
        return Icons.brush;
      case 'كهربائي':
        return Icons.electrical_services;
      case 'سيراميك':
        return Icons.home_repair_service;
      case 'سباك':
        return Icons.plumbing;
      case 'نجار':
        return Icons.build;
      case 'حداد':
        return Icons.construction;
      default:
        return Icons.home_repair_service;
    }
  }

  String _getServiceIconName(String categoryName) {
    switch (categoryName) {
      case 'نقاش':
        return 'brush';
      case 'كهربائي':
        return 'electrical_services';
      case 'سيراميك':
        return 'home_repair_service';
      case 'سباك':
        return 'plumbing';
      case 'نجار':
        return 'build';
      case 'حداد':
        return 'construction';
      default:
        return 'home_repair_service';
    }
  }

  String _getServiceType(String categoryName) {
    switch (categoryName) {
      case 'نقاش':
        return 'painter';
      case 'كهربائي':
        return 'electrician';
      case 'سيراميك':
        return 'ceramic';
      case 'سباك':
        return 'plumber';
      case 'نجار':
        return 'carpenter';
      case 'حداد':
        return 'blacksmith';
      default:
        return 'other';
    }
  }

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? '1';
  }

  Future<String> _getCraftsmanDistance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final craftsmanData = prefs.getString('selected_craftsman');
      if (craftsmanData != null) {
        final craftsman = jsonDecode(craftsmanData);
        return craftsman['distance'] ?? 'غير محدد';
      }
      return 'غير محدد';
    } catch (e) {
      return 'غير محدد';
    }
  }

  void _showSuccessDialogWithChat() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              const SizedBox(width: 10),
              const Text(
                'تم إرسال الطلب',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'تم إرسال طلب الخدمة بنجاح!',
            style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                'تم العثور على أقرب صنايعي متاح:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              FutureBuilder<String>(
                future: _getCraftsmanDistance(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      'أحمد محمد - تقييم 4.8 - المسافة: ${snapshot.data}',
                      style: const TextStyle(fontSize: 14, color: Colors.blue),
                    );
                  }
                  return const Text(
                    'أحمد محمد - تقييم 4.8 - المسافة: جاري الحساب...',
                    style: TextStyle(fontSize: 14, color: Colors.blue),
                  );
                },
              ),
              const SizedBox(height: 10),
              const Text(
                'يمكنك الآن الدخول للشات مع الصنايعي',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to category detail
              },
              child: const Text('إغلاق'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _openChatWithCraftsman();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('حسناً'),
            ),
          ],
        );
      },
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

  void _openChatWithCraftsman() async {
    // Get real distance from saved craftsman data
    final prefs = await SharedPreferences.getInstance();
    final craftsmanData = prefs.getString('selected_craftsman');
    String distance = '2.5 كم'; // Default
    
    if (craftsmanData != null) {
      try {
        final craftsman = jsonDecode(craftsmanData);
        distance = craftsman['distance'] ?? '2.5 كم';
      } catch (e) {
        print('Error parsing craftsman data: $e');
      }
    }
    
    // Navigate to chat screen with craftsman
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ChatScreen(
          craftsmanName: 'أحمد محمد',
          craftsmanRating: 4.8,
          craftsmanDistance: distance,
          category: widget.categoryName,
        ),
      ),
    );
  }
}

// Simple Chat Screen
class _ChatScreen extends StatefulWidget {
  final String craftsmanName;
  final double craftsmanRating;
  final String craftsmanDistance;
  final String category;

  const _ChatScreen({
    required this.craftsmanName,
    required this.craftsmanRating,
    required this.craftsmanDistance,
    required this.category,
  });

  @override
  State<_ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<_ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add({
      'text': 'مرحباً! أنا ${widget.craftsmanName}، سأقوم بمساعدتك في ${widget.category}',
      'isMe': false,
      'time': DateTime.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfec901),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.craftsmanName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'تقييم ${widget.craftsmanRating} - ${widget.craftsmanDistance}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'اكتب رسالتك...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    return Align(
      alignment: message['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message['isMe'] ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message['text'],
          style: TextStyle(
            color: message['isMe'] ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    final messageTime = DateTime.now();

    setState(() {
      _messages.add({
        'text': messageText,
        'isMe': true,
        'time': messageTime,
      });
    });

    _messageController.clear();

    // Send message to craftsman and save to admin panel
    await _sendMessageToCraftsman(messageText, messageTime);

    // Simulate craftsman response
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({
          'text': 'شكراً لك! سأقوم بالرد عليك قريباً.',
          'isMe': false,
          'time': DateTime.now(),
        });
      });
    });
  }

  Future<void> _sendMessageToCraftsman(String message, DateTime timestamp) async {
    try {
      // Save message to admin panel
      final messageData = {
        'customer_id': await _getUserId(),
        'craftsman_id': 123, // Default craftsman ID
        'message': message,
        'sender': 'customer',
        'timestamp': timestamp.toIso8601String(),
        'service_type': widget.category,
        'distance': widget.craftsmanDistance,
      };

      // Save to SharedPreferences (simulate admin panel)
      final prefs = await SharedPreferences.getInstance();
      List<String> messages = prefs.getStringList('admin_chat_messages') ?? [];
      messages.add(jsonEncode(messageData));
      await prefs.setStringList('admin_chat_messages', messages);

      print('Message sent to craftsman and saved to admin panel: $messageData');
    } catch (e) {
      print('Error sending message to craftsman: $e');
    }
  }

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? '1';
  }
}

class MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw grid lines to simulate a map
    for (int i = 0; i < size.width; i += 30) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }

    for (int i = 0; i < size.height; i += 30) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }

    // Draw some random circles to simulate buildings/landmarks
    final circlePaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final x = (i * 60.0) % size.width;
      final y = (i * 40.0) % size.height;
      canvas.drawCircle(Offset(x, y), 3, circlePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
