import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'shop_detail_screen.dart';

class ShopsExhibitionsScreen extends StatefulWidget {
  const ShopsExhibitionsScreen({super.key});

  @override
  State<ShopsExhibitionsScreen> createState() => _ShopsExhibitionsScreenState();
}

class _ShopsExhibitionsScreenState extends State<ShopsExhibitionsScreen> {
  String _currentLocation = 'جاري تحديد الموقع...';
  bool _isLoadingLocation = true;
  List<Map<String, dynamic>> _shops = [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoadingLocation = true;
        _currentLocation = 'جاري تحديد الموقع...';
      });

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentLocation = 'خدمات الموقع غير مفعلة';
          _isLoadingLocation = false;
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentLocation = 'تم رفض إذن الموقع';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocation = 'إذن الموقع مرفوض نهائياً';
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position with timeout and null safety
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (positionError) {
        print('Position error: $positionError');
        // Try with lower accuracy if high accuracy fails
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 5),
          );
        } catch (lowAccuracyError) {
          print('Low accuracy position error: $lowAccuracyError');
          setState(() {
            _currentLocation = 'فشل في الحصول على الموقع';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (position == null) {
        setState(() {
          _currentLocation = 'فشل في الحصول على الموقع';
          _isLoadingLocation = false;
        });
        return;
      }

      // Get address from coordinates with null safety
      try {
        // Check if coordinates are valid
        if (position.latitude.isNaN || position.longitude.isNaN || 
            position.latitude == 0.0 || position.longitude == 0.0) {
          setState(() {
            _currentLocation = 'إحداثيات غير صحيحة';
            _isLoadingLocation = false;
          });
          return;
        }

        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String locationName = '';
          
          // Try to get locality first with null safety
          if (place.locality != null && place.locality!.isNotEmpty) {
            locationName = place.locality!;
          }
          
          // Add administrative area if available with null safety
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
            if (locationName.isNotEmpty) {
              locationName += ' - ${place.administrativeArea!}';
            } else {
              locationName = place.administrativeArea!;
            }
          }
          
          // Add country if no other location found with null safety
          if (locationName.isEmpty && place.country != null && place.country!.isNotEmpty) {
            locationName = place.country!;
          }
          
          // Fallback to coordinates if no location name found
          if (locationName.isEmpty) {
            locationName = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
          }

          setState(() {
            _currentLocation = locationName;
            _isLoadingLocation = false;
          });
        } else {
          // If no placemarks found, use coordinates
          setState(() {
            _currentLocation = '${position!.latitude.toStringAsFixed(4)}, ${position!.longitude.toStringAsFixed(4)}';
            _isLoadingLocation = false;
          });
        }
      } catch (geocodingError) {
        print('Geocoding error: $geocodingError');
        // If geocoding fails, use coordinates as fallback
        setState(() {
          if (geocodingError.toString().contains('null') || geocodingError.toString().contains('Unexpected null')) {
            _currentLocation = 'تم تحديد الموقع (بدون عنوان)';
          } else {
            _currentLocation = '${position!.latitude.toStringAsFixed(4)}, ${position!.longitude.toStringAsFixed(4)}';
          }
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      print('Location error: $e');
      setState(() {
        if (e.toString().contains('timeout') || e.toString().contains('TimeoutException')) {
          _currentLocation = 'انتهت مهلة تحديد الموقع';
        } else if (e.toString().contains('permission')) {
          _currentLocation = 'مشكلة في أذونات الموقع';
        } else if (e.toString().contains('network') || e.toString().contains('NetworkException')) {
          _currentLocation = 'مشكلة في الاتصال بالإنترنت';
        } else {
          _currentLocation = 'خطأ في تحديد الموقع';
        }
        _isLoadingLocation = false;
      });
    }
  }

  void _loadShopsForCategory(String categoryName) async {
    setState(() {
      _selectedCategory = categoryName;
      _isLoadingLocation = true;
    });

    try {
      // Load shops from admin panel
      final shops = await _loadShopsFromAdminPanel(categoryName);
      setState(() {
        _shops = shops;
        _isLoadingLocation = false;
      });
    } catch (e) {
      print('Error loading shops: $e');
      // Fallback to local data
      setState(() {
        _shops = _getShopsForCategory(categoryName);
        _isLoadingLocation = false;
      });
    }
  }

  // Load shops immediately when category is selected
  void _selectCategory(String categoryName) {
    setState(() {
      _selectedCategory = categoryName;
      _shops = _getShopsForCategory(categoryName);
    });
  }

  Future<List<Map<String, dynamic>>> _loadShopsFromAdminPanel(String categoryName) async {
    try {
      final response = await http.get(
        Uri.parse('https://free-styel.store/api/shops'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          List<Map<String, dynamic>> shops = [];
          
          for (var shop in data['data']) {
            // Filter by category
            if (shop['category'] == categoryName && shop['status'] == true) {
              shops.add({
                'name': shop['name'],
                'rating': shop['rating']?.toDouble() ?? 0.0,
                'reviews': shop['reviews'] ?? 0,
                'distance': _calculateDistance(shop['latitude'], shop['longitude']),
                'image': shop['image'] ?? 'https://via.placeholder.com/300x200/1976D2/ffffff?text=Shop',
                'address': shop['address'] ?? '',
                'phone': shop['phone'] ?? '',
                'description': shop['description'] ?? '',
              });
            }
          }
          
          return shops;
        }
      }
      
      // If API fails, return empty list
      return [];
    } catch (e) {
      print('Error loading shops from admin panel: $e');
      return [];
    }
  }

  String _calculateDistance(double? lat, double? lng) {
    if (lat == null || lng == null) return 'غير محدد';
    
    // Simple distance calculation (in real app, use proper distance calculation)
    double distance = ((lat - 36.8065).abs() + (lng - 10.1815).abs()) * 100;
    return '${distance.toStringAsFixed(1)} كم';
  }

  List<Map<String, dynamic>> _getShopsForCategory(String categoryName) {
    // Return different shops based on category
    switch (categoryName) {
      case 'معرض دهانات وديكورات':
        return [
          {
            'name': 'Art Of Design',
            'rating': 0.0,
            'reviews': 0,
            'distance': '2.4 كم',
            'image': 'https://via.placeholder.com/300x200/000000/ffffff?text=ART+OF+DESIGN',
          },
          {
            'name': 'Art Of Design',
            'rating': 0.0,
            'reviews': 0,
            'distance': '2.4 كم',
            'image': 'https://via.placeholder.com/300x200/CCCCCC/666666?text=Logo',
          },
          {
            'name': 'للدعاية والإعلان وجميع أنواع المطبوعات الورقية',
            'rating': 0.0,
            'reviews': 0,
            'distance': '3.2 كم',
            'image': 'https://via.placeholder.com/300x200/FF6B6B/ffffff?text=Omar+Tacseer',
          },
          {
            'name': 'عالم الإبداع للتشطيبات المتكاملة',
            'rating': 0.0,
            'reviews': 0,
            'distance': '3.7 كم',
            'image': 'https://via.placeholder.com/300x200/8B4513/ffffff?text=Samples',
          },
          {
            'name': 'تصنيع وحدات الحمامات',
            'rating': 0.0,
            'reviews': 0,
            'distance': '3.9 كم',
            'image': 'https://via.placeholder.com/300x200/4169E1/ffffff?text=Showroom',
          },
          {
            'name': 'RAQEEBO print ADV',
            'rating': 0.0,
            'reviews': 0,
            'distance': '3.9 كم',
            'image': 'https://via.placeholder.com/300x200/FF1493/ffffff?text=RAQEEBO',
          },
        ];
      case 'كهرباء وإضاءة':
        return [
          {
            'name': 'محل الإضاءة الحديثة',
            'rating': 4.5,
            'reviews': 23,
            'distance': '1.2 كم',
            'image': 'https://via.placeholder.com/300x200/FFD700/000000?text=Lighting',
          },
          {
            'name': 'شركة الكهرباء المتقدمة',
            'rating': 4.2,
            'reviews': 15,
            'distance': '2.1 كم',
            'image': 'https://via.placeholder.com/300x200/1976D2/ffffff?text=Electric',
          },
          {
            'name': 'معرض المصابيح الذكية',
            'rating': 4.8,
            'reviews': 31,
            'distance': '0.8 كم',
            'image': 'https://via.placeholder.com/300x200/FF9800/ffffff?text=Smart',
          },
        ];
      case 'أدوات صحية':
        return [
          {
            'name': 'محل الأدوات الصحية',
            'rating': 4.3,
            'reviews': 18,
            'distance': '1.5 كم',
            'image': 'https://via.placeholder.com/300x200/4CAF50/ffffff?text=Plumbing',
          },
          {
            'name': 'شركة السباكة المتخصصة',
            'rating': 4.6,
            'reviews': 27,
            'distance': '2.3 كم',
            'image': 'https://via.placeholder.com/300x200/00BCD4/ffffff?text=Pipes',
          },
        ];
      case 'مطابخ':
        return [
          {
            'name': 'معرض المطابخ الفاخرة',
            'rating': 4.7,
            'reviews': 35,
            'distance': '1.8 كم',
            'image': 'https://via.placeholder.com/300x200/8D6E63/ffffff?text=Kitchen',
          },
          {
            'name': 'شركة تصميم المطابخ',
            'rating': 4.4,
            'reviews': 22,
            'distance': '2.5 كم',
            'image': 'https://via.placeholder.com/300x200/795548/ffffff?text=Design',
          },
        ];
      case 'أبواب مصفحة':
        return [
          {
            'name': 'شركة الأبواب المصفحة',
            'rating': 4.9,
            'reviews': 42,
            'distance': '3.1 كم',
            'image': 'https://via.placeholder.com/300x200/607D8B/ffffff?text=Doors',
          },
          {
            'name': 'معرض الأبواب الأمنية',
            'rating': 4.5,
            'reviews': 28,
            'distance': '2.7 كم',
            'image': 'https://via.placeholder.com/300x200/455A64/ffffff?text=Security',
          },
        ];
      case 'سيراميك وأطقم صحية':
        return [
          {
            'name': 'معرض السيراميك الأوروبي',
            'rating': 4.6,
            'reviews': 33,
            'distance': '1.9 كم',
            'image': 'https://via.placeholder.com/300x200/795548/ffffff?text=Ceramic',
          },
          {
            'name': 'محل الأطقم الصحية',
            'rating': 4.3,
            'reviews': 19,
            'distance': '2.4 كم',
            'image': 'https://via.placeholder.com/300x200/00BCD4/ffffff?text=Sanitary',
          },
        ];
      case 'إيجار وبيع عدد وأدوات':
        return [
          {
            'name': 'شركة تأجير الأدوات',
            'rating': 4.4,
            'reviews': 26,
            'distance': '1.6 كم',
            'image': 'https://via.placeholder.com/300x200/FF5722/ffffff?text=Tools',
          },
          {
            'name': 'معرض الأدوات المتخصصة',
            'rating': 4.7,
            'reviews': 38,
            'distance': '2.2 كم',
            'image': 'https://via.placeholder.com/300x200/3F51B5/ffffff?text=Equipment',
          },
        ];
      case 'Smart Home':
        return [
          {
            'name': 'شركة المنزل الذكي',
            'rating': 4.8,
            'reviews': 45,
            'distance': '1.3 كم',
            'image': 'https://via.placeholder.com/300x200/9C27B0/ffffff?text=Smart+Home',
          },
          {
            'name': 'معرض التكنولوجيا الذكية',
            'rating': 4.5,
            'reviews': 29,
            'distance': '2.8 كم',
            'image': 'https://via.placeholder.com/300x200/673AB7/ffffff?text=Technology',
          },
        ];
      case 'زراعة ولاند سكيب':
        return [
          {
            'name': 'شركة تنسيق الحدائق',
            'rating': 4.6,
            'reviews': 31,
            'distance': '3.5 كم',
            'image': 'https://via.placeholder.com/300x200/4CAF50/ffffff?text=Garden',
          },
          {
            'name': 'معرض النباتات الداخلية',
            'rating': 4.2,
            'reviews': 17,
            'distance': '2.1 كم',
            'image': 'https://via.placeholder.com/300x200/8BC34A/ffffff?text=Plants',
          },
        ];
      case 'خامات أخشاب':
        return [
          {
            'name': 'معرض الأخشاب الطبيعية',
            'rating': 4.4,
            'reviews': 24,
            'distance': '2.9 كم',
            'image': 'https://via.placeholder.com/300x200/8D6E63/ffffff?text=Wood',
          },
          {
            'name': 'شركة الخشب المصنع',
            'rating': 4.7,
            'reviews': 36,
            'distance': '1.7 كم',
            'image': 'https://via.placeholder.com/300x200/5D4037/ffffff?text=Manufactured',
          },
        ];
      case 'حمامات سباحة':
        return [
          {
            'name': 'شركة بناء المسابح',
            'rating': 4.9,
            'reviews': 48,
            'distance': '4.2 كم',
            'image': 'https://via.placeholder.com/300x200/00BCD4/ffffff?text=Pool',
          },
          {
            'name': 'معرض معدات السباحة',
            'rating': 4.3,
            'reviews': 21,
            'distance': '3.8 كم',
            'image': 'https://via.placeholder.com/300x200/03A9F4/ffffff?text=Equipment',
          },
        ];
      case 'أبواب جراجات':
        return [
          {
            'name': 'شركة أبواب الجراجات',
            'rating': 4.5,
            'reviews': 32,
            'distance': '2.6 كم',
            'image': 'https://via.placeholder.com/300x200/607D8B/ffffff?text=Garage',
          },
          {
            'name': 'معرض الأبواب الأوتوماتيكية',
            'rating': 4.8,
            'reviews': 41,
            'distance': '3.3 كم',
            'image': 'https://via.placeholder.com/300x200/455A64/ffffff?text=Automatic',
          },
        ];
      case 'مراتب وستائر':
        return [
          {
            'name': 'معرض المراتب الفاخرة',
            'rating': 4.6,
            'reviews': 34,
            'distance': '1.4 كم',
            'image': 'https://via.placeholder.com/300x200/9C27B0/ffffff?text=Mattress',
          },
          {
            'name': 'محل الستائر المخصصة',
            'rating': 4.4,
            'reviews': 25,
            'distance': '2.0 كم',
            'image': 'https://via.placeholder.com/300x200/E91E63/ffffff?text=Curtains',
          },
        ];
      case 'أثاث ومفروشات':
        return [
          {
            'name': 'معرض الأثاث الحديث',
            'rating': 4.7,
            'reviews': 39,
            'distance': '1.8 كم',
            'image': 'https://via.placeholder.com/300x200/795548/ffffff?text=Furniture',
          },
          {
            'name': 'شركة المفروشات الفاخرة',
            'rating': 4.5,
            'reviews': 28,
            'distance': '2.5 كم',
            'image': 'https://via.placeholder.com/300x200/8D6E63/ffffff?text=Luxury',
          },
        ];
      case 'كاميرات مراقبة':
        return [
          {
            'name': 'شركة أنظمة المراقبة',
            'rating': 4.8,
            'reviews': 44,
            'distance': '2.3 كم',
            'image': 'https://via.placeholder.com/300x200/3F51B5/ffffff?text=Security',
          },
          {
            'name': 'معرض الكاميرات الذكية',
            'rating': 4.6,
            'reviews': 37,
            'distance': '1.9 كم',
            'image': 'https://via.placeholder.com/300x200/2196F3/ffffff?text=Smart+Cam',
          },
        ];
      case 'نباتات':
        return [
          {
            'name': 'معرض النباتات الداخلية',
            'rating': 4.3,
            'reviews': 20,
            'distance': '1.6 كم',
            'image': 'https://via.placeholder.com/300x200/4CAF50/ffffff?text=Indoor',
          },
          {
            'name': 'محل النباتات الخارجية',
            'rating': 4.5,
            'reviews': 26,
            'distance': '2.7 كم',
            'image': 'https://via.placeholder.com/300x200/8BC34A/ffffff?text=Outdoor',
          },
        ];
      case 'أجهزة كهربائية':
        return [
          {
            'name': 'معرض الأجهزة الكهربائية',
            'rating': 4.4,
            'reviews': 30,
            'distance': '1.5 كم',
            'image': 'https://via.placeholder.com/300x200/1976D2/ffffff?text=Appliances',
          },
          {
            'name': 'شركة الأجهزة المنزلية',
            'rating': 4.6,
            'reviews': 35,
            'distance': '2.2 كم',
            'image': 'https://via.placeholder.com/300x200/42A5F5/ffffff?text=Home+App',
          },
        ];
      case 'مصاعد':
        return [
          {
            'name': 'شركة المصاعد الحديثة',
            'rating': 4.9,
            'reviews': 52,
            'distance': '3.1 كم',
            'image': 'https://via.placeholder.com/300x200/607D8B/ffffff?text=Elevator',
          },
          {
            'name': 'معرض أنظمة المصاعد',
            'rating': 4.7,
            'reviews': 43,
            'distance': '2.8 كم',
            'image': 'https://via.placeholder.com/300x200/455A64/ffffff?text=Systems',
          },
        ];
      default:
        return [
          {
            'name': 'محل تجاري عام',
            'rating': 4.0,
            'reviews': 15,
            'distance': '2.0 كم',
            'image': 'https://via.placeholder.com/300x200/9E9E9E/ffffff?text=General',
          },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _selectedCategory ?? 'المحلات والمعارض',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _selectedCategory == null ? _buildCategoriesView() : _buildShopsView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Help action
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('مساعدة')),
          );
        },
        backgroundColor: const Color(0xFF1976D2),
        child: const Icon(Icons.message, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildCategoriesView() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _buildCategoryCard(category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () => _selectCategory(category['name']),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFfec901),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category['icon'],
                color: Colors.black,
                size: 30,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              category['name'],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopsView() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: const Color(0xFFfec901),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _isLoadingLocation ? 'جاري تحديد الموقع...' : _currentLocation,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (_currentLocation.contains('خطأ') || _currentLocation.contains('غير مفعلة') || _currentLocation.contains('مرفوض'))
                GestureDetector(
                  onTap: _getCurrentLocation,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFfec901),
            ),
            child: _shops.isEmpty ? _buildEmptyState() : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _shops.length,
              itemBuilder: (context, index) {
                final shop = _shops[index];
                return _buildShopCard(shop);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'لا توجد محلات في هذا التصنيف',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'سيتم إضافة محلات جديدة قريباً',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard(Map<String, dynamic> shop) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ShopDetailScreen(shop: shop),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFfec901),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          shop['rating'].toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 4),
                        ...List.generate(5, (index) {
                          return Icon(
                            index < shop['rating'].floor()
                                ? Icons.star
                                : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          );
                        }),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          shop['reviews'].toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.store,
                  size: 30,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static final List<Map<String, dynamic>> _categories = [
    {
      'name': 'كهرباء وإضاءة',
      'icon': Icons.lightbulb,
      'color': const Color(0xFF1976D2),
    },
    {
      'name': 'أدوات صحية',
      'icon': Icons.plumbing,
      'color': const Color(0xFF4CAF50),
    },
    {
      'name': 'معرض دهانات وديكورات',
      'icon': Icons.brush,
      'color': const Color(0xFFFF9800),
    },
    {
      'name': 'مطابخ',
      'icon': Icons.kitchen,
      'color': const Color(0xFF8D6E63),
    },
    {
      'name': 'أبواب مصفحة',
      'icon': Icons.door_front_door,
      'color': const Color(0xFF607D8B),
    },
    {
      'name': 'سيراميك وأطقم صحية',
      'icon': Icons.bathtub,
      'color': const Color(0xFF795548),
    },
    {
      'name': 'إيجار وبيع عدد وأدوات',
      'icon': Icons.build,
      'color': const Color(0xFF00BCD4),
    },
    {
      'name': 'Smart Home',
      'icon': Icons.home,
      'color': const Color(0xFF9C27B0),
    },
    {
      'name': 'زراعة ولاند سكيب',
      'icon': Icons.landscape,
      'color': const Color(0xFF4CAF50),
    },
    {
      'name': 'خامات أخشاب',
      'icon': Icons.forest,
      'color': const Color(0xFF8D6E63),
    },
    {
      'name': 'حمامات سباحة',
      'icon': Icons.pool,
      'color': const Color(0xFF00BCD4),
    },
    {
      'name': 'أبواب جراجات',
      'icon': Icons.garage,
      'color': const Color(0xFF607D8B),
    },
    {
      'name': 'مراتب وستائر',
      'icon': Icons.bed,
      'color': const Color(0xFF9C27B0),
    },
    {
      'name': 'أثاث ومفروشات',
      'icon': Icons.chair,
      'color': const Color(0xFF795548),
    },
    {
      'name': 'كاميرات مراقبة',
      'icon': Icons.videocam,
      'color': const Color(0xFF3F51B5),
    },
    {
      'name': 'نباتات',
      'icon': Icons.local_florist,
      'color': const Color(0xFF4CAF50),
    },
    {
      'name': 'أجهزة كهربائية',
      'icon': Icons.electrical_services,
      'color': const Color(0xFF1976D2),
    },
    {
      'name': 'مصاعد',
      'icon': Icons.elevator,
      'color': const Color(0xFF607D8B),
    },
  ];
}
