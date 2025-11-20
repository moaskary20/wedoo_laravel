import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'location_selection_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../config/api_config.dart';
import '../services/language_service.dart';
import 'package:handyman_app/l10n/app_localizations.dart';
import 'my_orders_screen.dart';
import 'conversations_screen.dart';

class ServiceRequestForm extends StatefulWidget {
  final String categoryName;
  final String categoryIcon;
  final Color categoryColor;
  final int? categoryId; // Optional: if provided, use it directly instead of converting from name

  const ServiceRequestForm({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    this.categoryId,
  });

  @override
  State<ServiceRequestForm> createState() => _ServiceRequestFormState();
}

class _ServiceRequestFormState extends State<ServiceRequestForm> {
  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSearchingCraftsman = false;
  Map<String, dynamic>? _nearestCraftsman;
  final ValueNotifier<int> _craftsmanDialogVersion = ValueNotifier<int>(0);
  Timer? _orderStatusTimer;
  String? _currentOrderId;
  String _currentCraftsmanStatus = 'awaiting_assignment';

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
  int? _selectedTaskTypeId; // Store task type ID instead of name
  List<Map<String, dynamic>> _taskTypes = [];
  bool _isLoadingTaskTypes = false;
  
  // Helper function to get task type name based on current locale
  String _getTaskTypeName(Map<String, dynamic> taskType) {
    final isRtl = _currentLocale.languageCode == 'ar';
    
    if (isRtl) {
      // Return Arabic name if available, otherwise fallback to name
      return taskType['name_ar'] ?? taskType['name_arabic'] ?? taskType['name'] ?? '';
    } else {
      // Return French name if available, otherwise fallback to name
      return taskType['name_fr'] ?? taskType['name_french'] ?? taskType['name'] ?? '';
    }
  }

  // Step 2: Task Specifications
  final TextEditingController _taskDescriptionController = TextEditingController();
  final TextEditingController _urgencyController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  String? _selectedUrgency;
  Locale _currentLocale = LanguageService.defaultLocale;

  // Step 3: Location
  Map<String, dynamic>? _savedLocation;
  bool _useSavedLocation = true;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
    _fetchTaskTypes();
    _loadCurrentLocale();
  }

  Future<void> _loadCurrentLocale() async {
    final locale = await LanguageService.getSavedLocale();
    if (mounted) {
      final l10n = AppLocalizations.of(context);
      setState(() {
        _currentLocale = locale;
        // Set default urgency to the translated text
        if (l10n != null) {
          _selectedUrgency = l10n.normal;
        } else {
          _selectedUrgency = 'عادي';
        }
        // Reset selected task type when locale changes to refresh display names
        // The ID remains the same, but display names will update
      });
    }
  }

  List<String> _getUrgencyLevels() {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return ['عاجل', 'عادي', 'غير عاجل'];
    return [l10n.urgent, l10n.normal, l10n.notUrgent];
  }

  String _getUrgencyValue(String displayText) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return displayText;
    if (displayText == l10n.urgent) return 'urgent';
    if (displayText == l10n.normal) return 'normal';
    if (displayText == l10n.notUrgent) return 'not_urgent';
    return displayText;
  }

  bool get _isCurrentLocaleArabic => _currentLocale.languageCode == 'ar';

  String _localizedText(String arabicText, String frenchText) {
    return _isCurrentLocaleArabic ? arabicText : frenchText;
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

      // Get category ID - use provided ID if available, otherwise convert from name
      int categoryId = widget.categoryId ?? _getCategoryId(widget.categoryName);
      
      // Debug logging
      print('Category Name: ${widget.categoryName}');
      print('Category ID (from backend): ${widget.categoryId}');
      print('Category ID (used): $categoryId');

      // Fetch from HTTPS server
      final response = await http.get(
        Uri.parse('${ApiConfig.taskTypes}?category_id=$categoryId'),
        headers: ApiConfig.headers,
      ).timeout(const Duration(seconds: 30));

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          // Extract task types directly from data array
          List<dynamic> allTaskTypes = responseData['data'] ?? [];
          
          // Filter task types by category_id to ensure only relevant types are shown
          List<Map<String, dynamic>> filteredTaskTypes = [];
          for (var taskType in allTaskTypes) {
            final taskTypeMap = taskType as Map<String, dynamic>;
            final taskCategoryId = taskTypeMap['category_id'] ?? 
                                  taskTypeMap['categoryId'] ?? 
                                  taskTypeMap['category']?['id'];
            
            // Convert to int for comparison
            int? taskCategoryIdInt;
            if (taskCategoryId != null) {
              if (taskCategoryId is int) {
                taskCategoryIdInt = taskCategoryId;
              } else if (taskCategoryId is String) {
                taskCategoryIdInt = int.tryParse(taskCategoryId);
              }
            }
            
            // Only include task types that match the current category
            if (taskCategoryIdInt == categoryId) {
              filteredTaskTypes.add(taskTypeMap);
            }
          }
          
          print('Total task types from API: ${allTaskTypes.length}');
          print('Filtered task types for category $categoryId: ${filteredTaskTypes.length}');
          
          setState(() {
            _taskTypes = filteredTaskTypes;
            _isLoadingTaskTypes = false;
          });
        } else {
          throw Exception(responseData['message'] ?? 'Failed to fetch task types');
        }
      } else {
        throw Exception('Failed to fetch task types: ${response.statusCode}');
      }
      
    } catch (e) {
      print('Error fetching task types: $e');
      setState(() {
        _isLoadingTaskTypes = false;
        _taskTypes = [];
      });
      
      final l10n = AppLocalizations.of(context);
      // Show specific error messages
      String errorMessage = l10n?.errorLoadingTaskTypes ?? 'خطأ في تحميل أنواع المهام';
      if (e.toString().contains('ClientException')) {
        errorMessage = l10n?.serverConnectionErrorCheckInternet ?? 'خطأ في الاتصال بالخادم. تحقق من اتصال الإنترنت';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = l10n?.connectionTimeoutTryAgain ?? 'انتهت مهلة الاتصال. حاول مرة أخرى';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = l10n?.cannotReachServer ?? 'لا يمكن الوصول إلى الخادم. تحقق من اتصال الإنترنت';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _taskDescriptionController.dispose();
    _urgencyController.dispose();
    _budgetController.dispose();
    _craftsmanDialogVersion.dispose();
    _orderStatusTimer?.cancel();
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
          l10n.createServiceRequest,
          style: const TextStyle(
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
    final l10n = AppLocalizations.of(context)!;
    
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              l10n.loading,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                l10n.errorSendingRequest,
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
                label: Text(l10n.tryAgain),
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
    final l10n = AppLocalizations.of(context)!;
    final isRtl = _currentLocale.languageCode == 'ar';
    
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
          Text(
            l10n.taskType,
            style: const TextStyle(
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
              else if (_taskTypes.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          l10n.noTasksAvailable,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            _fetchTaskTypes();
                          },
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._taskTypes.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> taskType = entry.value;
                  int taskTypeId = taskType['id'] ?? taskType['task_type_id'] ?? index;
                  bool isSelected = _selectedTaskTypeId == taskTypeId;
                  String displayName = _getTaskTypeName(taskType);
                  
                  return Column(
                    children: [
                      RadioListTile<int>(
                        title: Text(
                          displayName,
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
                                '${l10n.price}: ${taskType['price_range']}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            if (taskType['duration'] != null)
                              Text(
                                '${l10n.duration}: ${taskType['duration']}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.right,
                              ),
                          ],
                        ),
                        value: taskTypeId,
                        groupValue: _selectedTaskTypeId,
                        onChanged: (int? value) {
                          setState(() {
                            _selectedTaskTypeId = value;
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
    final l10n = AppLocalizations.of(context)!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.taskSpecifications,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 20),
          
          // Task Description
          Text(
            l10n.taskDescriptionLabel,
            style: const TextStyle(
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
              hintText: l10n.writeDetailedDescription,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Urgency Level
          Text(
            l10n.priorityLevel,
            style: const TextStyle(
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
                value: _selectedUrgency ?? _getUrgencyLevels()[1], // Default to 'normal' translated
                isExpanded: true,
                items: _getUrgencyLevels().map((String urgency) {
                  return DropdownMenuItem<String>(
                    value: urgency,
                    child: Text(urgency),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUrgency = newValue;
                  });
                },
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Budget
          Text(
            l10n.expectedBudget,
            style: const TextStyle(
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
              hintText: l10n.budgetExample,
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
    final l10n = AppLocalizations.of(context)!;
    
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
          child: Text(
            l10n.taskLocation,
            style: const TextStyle(
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
    final l10n = AppLocalizations.of(context)!;
    
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
            child: Text(
              l10n.editLocation,
              style: const TextStyle(
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
    final l10n = AppLocalizations.of(context)!;
    
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
          child: Text(
            l10n.addPhotos,
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
    final l10n = AppLocalizations.of(context)!;
    final isRtl = _currentLocale.languageCode == 'ar';
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.selectImageSource,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceOption(
                      l10n.camera,
                      Icons.camera_alt,
                      () => _pickImage(ImageSource.camera, index),
                    ),
                    _buildImageSourceOption(
                      l10n.gallery,
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
        
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.imageAddedSuccessfully),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        Navigator.of(context).pop(); // Close bottom sheet even if no image selected
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      Navigator.of(context).pop(); // Close bottom sheet on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.errorAddingImage}: ${e.toString()}'),
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
    final l10n = AppLocalizations.of(context)!;
    
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
              child: Text(
                l10n.clickMapToMoveMarker,
                style: const TextStyle(
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
        child: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Center(
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
                    l10n.mapLocation,
                    style: TextStyle(
                      fontSize: 16,
                  color: Colors.grey,
                    ),
                  ),
              SizedBox(height: 4),
                  Text(
                    l10n.clickToSelectLocation,
                    style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          },
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
      child: kIsWeb
          ? (_imageBytes.length > index && _imageBytes[index].isNotEmpty)
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
              : const Center(
                  child: Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 30,
                  ),
                )
          : (_selectedImages.length > index && _selectedImages[index].path.isNotEmpty)
              ? Image.file(
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
                )
              : const Center(
                  child: Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 30,
                  ),
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
    final isRtl = _currentLocale.languageCode == 'ar';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
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
                      Text(
                        l10n.selectLocation,
                        style: const TextStyle(
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
                child: Text(
                        l10n.confirmLocation,
                  style: const TextStyle(
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
    final l10n = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLocationText = arabicName;
        });
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.locationSelected}: $arabicName'),
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
    final l10n = AppLocalizations.of(context)!;
    
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
            _currentStep == 2 ? l10n.submit : l10n.next,
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
    final l10n = AppLocalizations.of(context)!;
    
    switch (_currentStep) {
      case 0:
        if (_selectedTaskTypeId == null) {
          _showErrorSnackBar(l10n.selectTaskType);
          return false;
        }
        return true;
      case 1:
        if (_taskDescriptionController.text.trim().isEmpty) {
          _showErrorSnackBar(l10n.pleaseWriteTaskDescription);
          return false;
        }
        if (_taskDescriptionController.text.trim().length < 10) {
          _showErrorSnackBar(l10n.pleaseWriteMoreDetailed);
          return false;
        }
        return true;
      case 2:
        if (!_useSavedLocation && _savedLocation == null) {
          _showErrorSnackBar(l10n.pleaseSelectLocation);
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

    final l10n = AppLocalizations.of(context)!;

    // Additional validation before submission
    if (_selectedTaskTypeId == null) {
      _showErrorSnackBar(l10n.pleaseSelectTaskType);
      return;
    }

    if (_taskDescriptionController.text.trim().isEmpty) {
      _showErrorSnackBar(l10n.pleaseWriteTaskDescription);
      return;
    }

    if (_taskDescriptionController.text.trim().length < 10) {
      _showErrorSnackBar(l10n.pleaseWriteMoreDetailed);
      return;
    }

    if (!_useSavedLocation && _savedLocation == null) {
      _showErrorSnackBar(l10n.pleaseSelectLocation);
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
        int taskTypeId = taskType['id'] ?? taskType['task_type_id'] ?? 0;
        if (taskTypeId == _selectedTaskTypeId) {
          selectedTaskTypeDetails = taskType;
          break;
        }
      }

      final String taskTypeName = _getTaskTypeName(selectedTaskTypeDetails ?? {});
      final String orderTitle = _buildOrderTitle(taskTypeName);
      final Map<String, dynamic> locationDetails = await _buildLocationDetails();
    final String userId = await _getUserId();
    final int? customerIdInt = int.tryParse(userId);

      // Prepare request data (matches backend validation)
      Map<String, dynamic> requestData = {
        'customer_id': customerIdInt ?? userId,
        'task_type_id': _selectedTaskTypeId,
        'title': orderTitle,
        'description': _taskDescriptionController.text.trim(),
        'location': locationDetails['formatted'],
        'governorate': locationDetails['governorate'],
        'city': locationDetails['city'],
        'district': locationDetails['district'],
        'budget': _getBudgetValue(),
        'notes': null,

        // Additional metadata for app usage
        'task_type': taskTypeName,
        'task_type_details': selectedTaskTypeDetails,
        'category': widget.categoryName,
        'urgency': _getUrgencyValue(_selectedUrgency ?? _getUrgencyLevels()[1]),
        'location_details': locationDetails,
        'use_saved_location': _useSavedLocation,
        'images': _selectedImages.map((image) => image.path).toList(),
        'created_at': DateTime.now().toIso8601String(),
        'status': 'pending',
        'user_id': userId,
      };

      // Prepare headers with authentication token
      final headers = await _buildAuthHeaders();
      if (headers == null) {
        throw Exception('User is not authenticated. Please log in again.');
      }

      // Send to admin panel
      final uri = Uri.parse(ApiConfig.ordersCreate);
      final httpResponse = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode(requestData),
          )
          .timeout(const Duration(seconds: 30));

      Map<String, dynamic>? backendOrder;
      if (httpResponse.statusCode == 200) {
        final resp = jsonDecode(httpResponse.body);
        if (resp['success'] != true) {
          throw Exception(resp['message'] ?? 'Unknown server error');
        }
        backendOrder = resp['data'] as Map<String, dynamic>?;
      } else {
        throw Exception('HTTP ${httpResponse.statusCode}: ${httpResponse.body}');
      }
      
      final String? backendOrderId = backendOrder?['id']?.toString();
      requestData['backend_order_id'] = backendOrderId;
      requestData['backend_order'] = backendOrder;

      // Verify order exists in backend before proceeding
      await _verifyOrderStoredInBackend(userId, backendOrderId);

      // Start searching for nearby craftsman (async, updates dialog when done)
      _startCraftsmanSearch(requestData);
      
      // Stop loading before showing success UI
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      
      // Show success dialog with chat option
      _showSuccessDialogWithChat();
      
    } catch (e) {
      print('Error submitting request: $e');
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = '${l10n.errorSendingRequest}: $e';
        _isLoading = false;
      });
      
      // Show error message to user
      _showErrorSnackBar(l10n.errorSendingRequestRetry);
    }
  }

  Future<String> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  Future<Map<String, String>?> _buildAuthHeaders() async {
    final token = await _getUserToken();
    if (token.isEmpty) {
      return null;
    }
    final headers = Map<String, String>.from(ApiConfig.headers);
    headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  String _buildOrderTitle(String taskTypeName) {
    if (taskTypeName.trim().isNotEmpty) {
      return taskTypeName;
    }
    if (widget.categoryName.trim().isNotEmpty) {
      return widget.categoryName;
    }
    final l10n = AppLocalizations.of(context);
    return l10n?.createServiceRequest ?? 'Service Request';
  }

  Future<Map<String, dynamic>> _buildLocationDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final String savedGovernorate = prefs.getString('user_governorate') ?? '';
    final String savedCity = prefs.getString('user_city') ?? '';
    final String savedDistrict = prefs.getString('user_area') ?? '';
    
    final Map<String, dynamic>? baseLocation = _savedLocation;
    final List<String> parts = [];

    final String address = (baseLocation?['address'] as String?) ?? '';
    final String city = (baseLocation?['city'] as String?) ?? savedCity;
    final String country = (baseLocation?['country'] as String?) ?? '';

    void addPart(String value) {
      if (value.trim().isNotEmpty) {
        parts.add(value.trim());
      }
    }

    addPart(address);
    addPart(city);
    addPart(country);

    if (parts.isEmpty && _selectedLocationText.trim().isNotEmpty) {
      parts.add(_selectedLocationText.trim());
    }

    if (parts.isEmpty) {
      parts.add('${_selectedLocation.latitude.toStringAsFixed(5)}, ${_selectedLocation.longitude.toStringAsFixed(5)}');
    }

    return {
      'formatted': parts.join(', '),
      'address': address.isNotEmpty ? address : _selectedLocationText,
      'city': city,
      'country': country,
      'latitude': baseLocation?['latitude'] ?? _selectedLocation.latitude,
      'longitude': baseLocation?['longitude'] ?? _selectedLocation.longitude,
      'governorate': savedGovernorate,
      'district': savedDistrict,
    };
  }

  String? _getBudgetValue() {
    final text = _budgetController.text.trim();
    if (text.isEmpty) return null;
    final sanitized = text.replaceAll(RegExp(r'[^0-9.]'), '');
    if (sanitized.isEmpty) return null;
    return sanitized;
  }

  String _getRequestSuccessMessage() {
    final isRtl = _currentLocale.languageCode == 'ar';
    return isRtl
        ? 'تم إرسال طلبك بنجاح، وسيتم التواصل معك قريباً لمتابعة التفاصيل.'
        : 'Votre demande a été envoyée avec succès. Nous vous contacterons bientôt.';
  }

  Future<void> _inviteCraftsmanToOrder(
    Map<String, dynamic> craftsman,
    String orderId,
  ) async {
    final headers = await _buildAuthHeaders();
    final craftsmanId = craftsman['id'];
    final parsedOrderId = int.tryParse(orderId);

    if (headers == null || craftsmanId == null || parsedOrderId == null) {
      return;
    }

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.orderInvite(parsedOrderId)),
            headers: headers,
            body: jsonEncode({'craftsman_id': craftsmanId}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        setState(() {
          _currentOrderId = orderId;
          _currentCraftsmanStatus = 'waiting_response';
          _nearestCraftsman?['craftsman_status'] = 'waiting_response';
        });
        _craftsmanDialogVersion.value++;
        _startOrderStatusPolling(orderId);
      } else {
        print('Error inviting craftsman: ${response.body}');
      }
    } catch (e) {
      print('Error inviting craftsman: $e');
    }
  }

  void _startOrderStatusPolling(String orderId) {
    _orderStatusTimer?.cancel();
    _orderStatusTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _refreshOrderStatus(orderId),
    );
  }

  Future<void> _refreshOrderStatus(String orderId) async {
    final headers = await _buildAuthHeaders();
    if (headers == null) return;

    try {
      final userId = await _getUserId();
      final uri = Uri.parse('${ApiConfig.ordersList}?user_id=$userId');
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> orders = data['data'] ?? [];
          final order = orders.firstWhere(
            (element) => element['id']?.toString() == orderId,
            orElse: () => null,
          );

          if (order != null) {
            final status =
                order['craftsman_status'] ?? order['status'] ?? 'pending';
            setState(() {
              _currentCraftsmanStatus = status;
              _nearestCraftsman?['craftsman_status'] = status;
            });
            _craftsmanDialogVersion.value++;
            if (status == 'accepted') {
              _orderStatusTimer?.cancel();
            }
          }
        }
      }
    } catch (e) {
      print('Error refreshing order status: $e');
    }
  }

  void _startCraftsmanSearch(Map<String, dynamic> requestData) {
    setState(() {
      _isSearchingCraftsman = true;
      _nearestCraftsman = null;
    });
    _craftsmanDialogVersion.value++;

    _findNearestCraftsman(requestData).then((craftsman) async {
      if (!mounted) return;
      setState(() {
        _isSearchingCraftsman = false;
        _nearestCraftsman = craftsman;
      });
      _craftsmanDialogVersion.value++;
      final backendOrderId = requestData['backend_order_id']?.toString();
      if (craftsman != null && backendOrderId != null) {
        await _inviteCraftsmanToOrder(craftsman, backendOrderId);
      }
    }).catchError((error) {
      print('Error finding craftsman: $error');
      if (!mounted) return;
      setState(() {
        _isSearchingCraftsman = false;
        _nearestCraftsman = null;
      });
      _craftsmanDialogVersion.value++;
    });
  }

  Widget _buildCraftsmanStatusSection(BuildContext dialogContext) {
    return ValueListenableBuilder<int>(
      valueListenable: _craftsmanDialogVersion,
      builder: (_, __, ___) {
        if (_isSearchingCraftsman) {
          return _buildCraftsmanSearchingView();
        }

        if (_nearestCraftsman != null) {
          return _buildCraftsmanCard(dialogContext, _nearestCraftsman!);
        }

        return Text(
          _localizedText(
            'لم نتمكن من العثور على صنايعي في الوقت الحالي، سنرسل لك إشعاراً بمجرد توفر أحدهم.',
            'Impossible de trouver un artisan pour le moment. Nous vous informerons dès qu’un artisan sera disponible.',
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }

  Widget _buildCraftsmanSearchingView() {
    return Column(
      children: [
        const SizedBox(height: 4),
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        const SizedBox(height: 12),
        Text(
          _localizedText(
            'جارٍ البحث عن صنايعي قريب...',
            'Recherche d’un artisan à proximité...',
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCraftsmanCard(
    BuildContext dialogContext,
    Map<String, dynamic> craftsman,
  ) {
    final rating = (craftsman['rating'] as num?)?.toDouble() ?? 0.0;
    final distance = (craftsman['distance_label'] ?? craftsman['distance'])?.toString() ?? '';
    final name = craftsman['name']?.toString() ??
        _localizedText('صنايعي قريب', 'Artisan à proximité');
    final statusValue =
        (craftsman['craftsman_status'] ?? _currentCraftsmanStatus).toString();
    final isAccepted = statusValue == 'accepted';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _localizedText('تم العثور على صنايعي قريب', 'Artisan trouvé à proximité'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                child: Text(
                  name.isNotEmpty ? name.substring(0, 1) : '?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.place, color: Colors.redAccent, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          distance,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAccepted
                            ? Colors.green.withValues(alpha: 0.15)
                            : Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getCraftsmanStatusLabel(statusValue),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isAccepted ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  isAccepted ? () => _handleTalkNow(dialogContext, craftsman) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAccepted ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _localizedText('تحدث الآن', 'Parlez maintenant'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (!isAccepted && _currentOrderId != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  if (_currentOrderId != null) {
                    _refreshOrderStatus(_currentOrderId!);
                  }
                },
                child: Text(
                  _localizedText('تحديث الحالة', 'Actualiser l’état'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getCraftsmanStatusLabel(String status) {
    switch (status) {
      case 'waiting_response':
        return _localizedText('بانتظار موافقة الصنايعي', 'En attente de confirmation');
      case 'accepted':
        return _localizedText('تمت الموافقة ويمكن التحدث الآن', 'Accepté, vous pouvez discuter');
      case 'rejected':
        return _localizedText('تم رفض الطلب، نبحث عن صنايعي آخر', 'Rejeté, recherche d’un autre artisan');
      case 'awaiting_assignment':
      default:
        return _localizedText('جارٍ تحديد الصنايعي المناسب', 'Recherche d’un artisan disponible');
    }
  }

  void _handleTalkNow(
    BuildContext dialogContext,
    Map<String, dynamic> craftsman,
  ) {
    Navigator.of(dialogContext).pop();
    _resetForm();
    openCraftsmanChat(context, craftsman);
  }

  Future<void> _verifyOrderStoredInBackend(String userId, String? orderId) async {
    if (orderId == null || orderId.isEmpty) {
      print('Backend verification skipped: missing order ID');
      return;
    }

    try {
      final headers = await _buildAuthHeaders();
      if (headers == null) {
        print('Skipping order verification: missing auth token');
        return;
      }

      final uri = Uri.parse('${ApiConfig.ordersList}?user_id=$userId');
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> orders = data['data'] ?? [];
          final bool exists = orders.any((order) {
            final dynamic id = order['id'];
            return id != null && id.toString() == orderId;
          });
          print(exists
              ? 'Order verification success: order #$orderId found in backend.'
              : 'Order verification warning: order #$orderId not found in backend list.');
        } else {
          print('Order verification failed: backend returned success=false (${data['message']})');
        }
      } else {
        print('Order verification failed with HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Order verification error: $e');
    }
  }

  void _resetForm() {
    _orderStatusTimer?.cancel();
    setState(() {
      _currentStep = 0;
      _selectedTaskTypeId = null;
      _taskDescriptionController.clear();
      _budgetController.clear();
      _selectedUrgency = AppLocalizations.of(context)?.normal ?? 'Normal';
      _selectedImages.clear();
      _imageBytes.clear();
      _isLoading = false;
      _errorMessage = null;
      _useSavedLocation = true;
      _isSearchingCraftsman = false;
      _nearestCraftsman = null;
      _currentOrderId = null;
      _currentCraftsmanStatus = 'awaiting_assignment';
    });
    _loadSavedLocation();
    _craftsmanDialogVersion.value++;
  }

  Future<Map<String, dynamic>?> _findNearestCraftsman(Map<String, dynamic> requestData) async {
    try {
      final headers = await _buildAuthHeaders();
      if (headers == null) {
        print('Cannot load craftsmen: missing auth token');
        return null;
      }

      final prefs = await SharedPreferences.getInstance();
      final locationDetails = requestData['location_details'] as Map<String, dynamic>? ?? {};

      final queryParams = <String, String>{
        if (widget.categoryId != null) 'category_id': widget.categoryId.toString(),
        if ((locationDetails['governorate'] ?? '').toString().isNotEmpty)
          'governorate': locationDetails['governorate'].toString(),
        if ((locationDetails['city'] ?? '').toString().isNotEmpty)
          'city': locationDetails['city'].toString(),
        if ((locationDetails['district'] ?? '').toString().isNotEmpty)
          'district': locationDetails['district'].toString(),
        if ((prefs.getString('user_governorate') ?? '').isNotEmpty && (locationDetails['governorate'] ?? '').toString().isEmpty)
          'governorate': prefs.getString('user_governorate') ?? '',
        if ((prefs.getString('user_city') ?? '').isNotEmpty && (locationDetails['city'] ?? '').toString().isEmpty)
          'city': prefs.getString('user_city') ?? '',
        if ((prefs.getString('user_area') ?? '').isNotEmpty && (locationDetails['district'] ?? '').toString().isEmpty)
          'district': prefs.getString('user_area') ?? '',
        'limit': '5',
      };

      queryParams.removeWhere((key, value) => value.isEmpty);

      final uri = Uri.parse(ApiConfig.craftsmanNearby).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data'] ?? [];
          if (list.isNotEmpty) {
            final nearestCraftsman = Map<String, dynamic>.from(list.first as Map);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('selected_craftsman', jsonEncode(nearestCraftsman));
            print('Nearest craftsman loaded: $nearestCraftsman');
            return nearestCraftsman;
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to load craftsmen');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error loading nearby craftsmen: $e');
    }
    return null;
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
    final cachedId = prefs.getString('user_id');
    if (cachedId != null && cachedId.isNotEmpty && cachedId != 'null') {
      return cachedId;
    }

    final token = prefs.getString('access_token');
    if (token == null || token.isEmpty) {
      throw Exception('لم يتم العثور على بيانات تسجيل الدخول. يرجى تسجيل الدخول مرة أخرى.');
    }

    final headers = Map<String, String>.from(ApiConfig.headers);
    headers['Authorization'] = 'Bearer $token';

    try {
      final response = await http
          .get(Uri.parse(ApiConfig.userProfile), headers: headers)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'] ?? body['user'] ?? body;
        final dynamic idValue = data is Map<String, dynamic> ? (data['id'] ?? data['user_id']) : null;

        if (idValue != null) {
          final resolvedId = idValue.toString();
          await prefs.setString('user_id', resolvedId);
          return resolvedId;
        }
      } else if (response.statusCode == 401) {
        throw Exception('انتهت جلسة تسجيل الدخول. يرجى تسجيل الدخول مرة أخرى.');
      }

      throw Exception('تعذر الحصول على بيانات المستخدم من الخادم.');
    } catch (error) {
      if (error is TimeoutException) {
        throw Exception('انتهت مهلة الاتصال أثناء جلب بيانات الحساب.');
      }
      rethrow;
    }
  }

  int _getCategoryId(String categoryName) {
    // Map category names to IDs based on the API
    // The API has 8 categories: كهرباء وإضاءة, سباكة, نجارة, دهان, تكييف وتبريد, سيراميك وبلاط, حدادة, ديكور
    switch (categoryName) {
      case 'خدمات صيانة المنازل':
        return 1; // Home Maintenance -> كهرباء وإضاءة
      case 'خدمات التنظيف':
        return 2; // Cleaning Services -> سباكة
      case 'النقل والخدمات اللوجستية':
        return 3; // Transportation -> نجارة
      case 'خدمات السيارات':
        return 4; // Car Services -> دهان
      case 'خدمات طارئة (عاجلة)':
        return 5; // Emergency Services -> تكييف وتبريد
      case 'خدمات الأسر والعائلات':
        return 6; // Family Services -> سيراميك وبلاط
      case 'خدمات تقنية':
        return 7; // Technical Services -> حدادة
      case 'خدمات الحديقة':
        return 8; // Garden Services -> ديكور
      case 'حرف وخدمات متنوعة':
        return 1; // Various Crafts -> كهرباء وإضاءة
      case 'المصاعد والألواح الشمسية':
        return 2; // Elevators & Solar -> سباكة
      case 'خدمات التعليم والدروس الخصوصية':
        return 3; // Education Services -> نجارة
      case 'خدمات المناسبات والإحتفالات':
        return 4; // Events & Celebrations -> دهان
      case 'خدمات السفر والسياحة':
        return 5; // Travel & Tourism -> تكييف وتبريد
      case 'خدمات المكاتب والمستندات':
        return 6; // Office Services -> سيراميك وبلاط
      case 'خدمات التسوق':
        return 7; // Shopping Services -> حدادة
      case 'خدمات للمؤسسات والشركات':
        return 8; // Corporate Services -> ديكور
      case 'خدمات ذوي الإحتياجات الخاصة':
        return 1; // Special Needs -> كهرباء وإضاءة
      default:
        return 1; // Default to first category if not found
    }
  }


  void _showSuccessDialogWithChat() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final isRtl = _currentLocale.languageCode == 'ar';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.createServiceRequest,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _getRequestSuccessMessage(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildCraftsmanStatusSection(dialogContext),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MyOrdersScreen(),
                        ),
                      );
                      _resetForm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      l10n.myOrders,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _resetForm();
                  },
                  child: Text(
                    l10n.close,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
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
}

class MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Implementation placeholder
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
