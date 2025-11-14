import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'main_screen.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool _isLoading = true;
  String _statusMessage = 'Getting your location...';
  bool _hasError = false;
  

  @override
  void initState() {
    super.initState();
    _getLocationAndSave();
  }

  Future<void> _getLocationAndSave() async {
    try {
      setState(() {
        _statusMessage = 'Checking location permissions...';
      });

      // Check if location permission is granted
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        setState(() {
          _statusMessage = 'Requesting location permission...';
        });
        
        permission = await Geolocator.requestPermission();
        
        if (permission == LocationPermission.denied) {
          setState(() {
            _statusMessage = 'Location permission denied. Please enable location access in settings.';
            _isLoading = false;
            _hasError = true;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _statusMessage = 'Location permissions are permanently denied. Please enable location access in settings.';
          _isLoading = false;
          _hasError = true;
        });
        return;
      }

      setState(() {
        _statusMessage = 'Getting your current location...';
      });

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _statusMessage = 'Location services are disabled. Please enable location services.';
          _isLoading = false;
          _hasError = true;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _statusMessage = 'Location found! Saving coordinates...';
      });

      // Save to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('latitude', position.latitude);
      await prefs.setDouble('longitude', position.longitude);
      await prefs.setBool('location_saved', true);
      await prefs.setString('location_timestamp', DateTime.now().toIso8601String());

      // Get device ID for backend
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceId;
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown';
      } else {
        deviceId = 'unknown';
      }

      await prefs.setString('device_id', deviceId);

      // Try to get address information (optional)
      try {
        setState(() {
          _statusMessage = 'Getting address information...';
        });

        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String address = '${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}';
          String city = place.locality ?? '';
          String country = place.country ?? '';

          await prefs.setString('address', address);
          await prefs.setString('city', city);
          await prefs.setString('country', country);
        }
      } catch (e) {
        print('Error getting address: $e');
        // Continue even if address lookup fails
      }

      // Try to save to backend (optional)
      try {
        await _saveLocationToBackend(
          deviceId,
          position.latitude,
          position.longitude,
          prefs.getString('address') ?? '',
          prefs.getString('city') ?? '',
          prefs.getString('country') ?? '',
        );
      } catch (e) {
        print('Error saving to backend: $e');
        // Continue even if backend save fails
      }

      setState(() {
        _statusMessage = 'Location saved successfully!';
      });

      // Navigate to main screen after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      });

    } catch (e) {
      setState(() {
        _statusMessage = 'Error getting location: $e';
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _saveLocationToBackend(
    String deviceId,
    double latitude,
    double longitude,
    String address,
    String city,
    String country,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://free-styel.store/api/user-locations'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'device_id': deviceId,
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
          'city': city,
          'country': country,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to save location: ${response.body}');
      }
    } catch (e) {
      print('Error saving location to backend: $e');
      // Continue with the app even if backend save fails
    }
  }

  void _retryLocation() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _statusMessage = 'Getting your location...';
    });
    _getLocationAndSave();
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // App Title
              const Text(
                'Handyman App',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 10),
              
              const Text(
                'تطبيق الصنايعية',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 60),
              
              // Loading/Status Section
              if (_isLoading) ...[
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 20),
              ],
              
              // Status Message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      _hasError ? Icons.error_outline : Icons.location_on,
                      size: 40,
                      color: _hasError ? Colors.red : Colors.blue,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 16,
                        color: _hasError ? Colors.red : Colors.grey[700],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Action Buttons
              if (_hasError) ...[
                ElevatedButton.icon(
                  onPressed: _retryLocation,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    // Navigate to main screen without location
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                    );
                  },
                  child: const Text(
                    'Continue without location',
                    style: TextStyle(
                      color: Colors.grey,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
              
              if (_isLoading) ...[
                const Text(
                  'يرجى الانتظار بينما نحصل على موقعك...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              
              const SizedBox(height: 20),
              
              // Demo Mode Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.orange[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'وضع التجربة: استخدام موقع محاكى (القاهرة، مصر)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                icon: Icons.home,
                label: 'الرئيسية',
                isActive: true,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.description,
                label: 'شرح التطبيق',
                isActive: false,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.receipt_long,
                label: 'طلباتي',
                isActive: false,
                onTap: () {},
              ),
              _buildNavItem(
                icon: Icons.settings,
                label: 'الإعدادات',
                isActive: false,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFFfec901) : Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFFfec901) : Colors.white,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
