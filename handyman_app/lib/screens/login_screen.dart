import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'demo_location_screen.dart';
import 'phone_input_screen.dart';
import 'forgot_password_screen.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';
import '../services/language_service.dart';
import '../main.dart';
import 'package:handyman_app/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  Locale _currentLocale = LanguageService.defaultLocale;

  // Backend configuration - Using remote server

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadCurrentLocale();
  }

  Future<void> _loadCurrentLocale() async {
    final locale = await LanguageService.getSavedLocale();
    if (mounted) {
      setState(() {
        _currentLocale = locale;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      if (isLoggedIn) {
        // Check if token is still valid
        final loginTimestamp = prefs.getString('login_timestamp');
        if (loginTimestamp != null) {
          final loginTime = DateTime.parse(loginTimestamp);
          final now = DateTime.now();
          final difference = now.difference(loginTime);

          // If logged in within last 7 days, navigate to main screen
          if (difference.inDays < 7) {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const DemoLocationScreen(),
                ),
              );
            }
          } else {
            // Token expired, clear login data
            await _clearLoginData();
          }
        }
      }
    } catch (e) {
      print('Error checking login status: $e');
    }
  }

  Future<void> _clearLoginData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_logged_in');
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('login_timestamp');
    } catch (e) {
      print('Error clearing login data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = _currentLocale.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFfec901),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Language Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => _showLanguageBottomSheet(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.language,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _currentLocale.languageCode == 'ar'
                                  ? l10n.arabic
                                  : l10n.french,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Text below logo
                const SizedBox(height: 20),
                Text(
                  l10n.yourServicesOnUs,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Phone Number Field
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
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: l10n.enterPhoneNumber,
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(Icons.phone, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Password Field
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
                  child: TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: l10n.password,
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
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

                const SizedBox(height: 15),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      l10n.forgotPassword,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Login Button
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            l10n.login,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // New User Registration
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFffe480),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PhoneInputScreen(),
                        ),
                      );
                    },
                    child: Text(
                      l10n.dontHaveAccount,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        // floatingActionButton removed (help button)
      ),
    );
  }

  void _handleLogin() async {
    final l10n = AppLocalizations.of(context)!;

    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar(l10n.pleaseFillAllFields);
      return;
    }

    // Validate phone number format (accept any international phone number)
    if (!_isValidPhoneNumber(_phoneController.text)) {
      _showErrorSnackBar(l10n.pleaseEnterValidPhone);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize ApiService
      ApiService.init();

      // Send login request to backend using ApiService
      final response = await ApiService.post(
        '/api/auth/login',
        data: {
          'phone': _phoneController.text.trim(),
          'password': _passwordController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          // Save user data to SharedPreferences
          final userData = responseData['data'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', userData['id']?.toString() ?? '');
          await prefs.setString('user_name', userData['name'] ?? '');
          await prefs.setString('user_phone', userData['phone'] ?? '');
          await prefs.setString('user_email', userData['email'] ?? '');
          await prefs.setString(
            'user_governorate',
            userData['governorate'] ?? '',
          );
          await prefs.setString('user_city', userData['city'] ?? '');
          await prefs.setString('user_area', userData['district'] ?? '');
          await prefs.setString(
            'user_membership_code',
            userData['membership_code'] ?? '',
          );
          await prefs.setString(
            'user_type',
            userData['user_type'] ?? 'customer',
          );
          await prefs.setString('access_token', userData['access_token'] ?? '');
          await prefs.setString(
            'refresh_token',
            userData['refresh_token'] ?? '',
          );
          await prefs.setBool('is_logged_in', true);
          await prefs.setString(
            'login_timestamp',
            DateTime.now().toIso8601String(),
          );

          // Show success message
          final l10n = AppLocalizations.of(context)!;
          _showSuccessSnackBar(l10n.loginSuccess);

          // Navigate to location screen
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const DemoLocationScreen(),
              ),
            );
          }
        } else {
          final l10n = AppLocalizations.of(context)!;
          _showErrorSnackBar(
            responseData['message'] ?? l10n.invalidPhoneOrPassword,
          );
        }
      } else {
        final l10n = AppLocalizations.of(context)!;
        _showErrorSnackBar(l10n.serverConnectionError);
      }
    } catch (e) {
      print('Login error: $e');
      final l10n = AppLocalizations.of(context)!;
      if (e.toString().contains('TimeoutException')) {
        _showErrorSnackBar(l10n.connectionTimeout);
      } else if (e.toString().contains('SocketException')) {
        _showErrorSnackBar(l10n.checkInternetConnection);
      } else {
        _showErrorSnackBar(l10n.connectionErrorRetry);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isValidPhoneNumber(String phone) {
    // Accept any phone number:
    // - International: starts with + followed by country code (1-9) and 6-14 digits
    // - Local: starts with 0 followed by 7-14 digits (e.g., 01000690805)
    // - International without +: starts with country code (1-9) and 6-14 digits
    final cleanedPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Pattern 1: International with + (e.g., +201000690805)
    if (RegExp(r'^\+[1-9]\d{6,14}$').hasMatch(cleanedPhone)) {
      return true;
    }

    // Pattern 2: Local number starting with 0 (e.g., 01000690805)
    if (RegExp(r'^0\d{7,14}$').hasMatch(cleanedPhone)) {
      return true;
    }

    // Pattern 3: International without + (e.g., 201000690805)
    if (RegExp(r'^[1-9]\d{6,14}$').hasMatch(cleanedPhone)) {
      return true;
    }

    return false;
  }

  void _showLanguageBottomSheet() {
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
                  l10n.selectLanguage,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.arabic),
                  onTap: () {
                    Navigator.pop(context);
                    context.changeAppLocale(const Locale('ar'));
                    setState(() {
                      _currentLocale = const Locale('ar');
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.french),
                  onTap: () {
                    Navigator.pop(context);
                    context.changeAppLocale(const Locale('fr'));
                    setState(() {
                      _currentLocale = const Locale('fr');
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save user information
      await prefs.setString('user_id', userData['id'].toString());
      await prefs.setString('user_name', userData['name'] ?? '');
      await prefs.setString('user_phone', userData['phone'] ?? '');
      await prefs.setString('user_email', userData['email'] ?? '');
      await prefs.setString('access_token', userData['access_token'] ?? '');
      await prefs.setString('refresh_token', userData['refresh_token'] ?? '');
      await prefs.setBool('is_logged_in', true);
      await prefs.setString(
        'login_timestamp',
        DateTime.now().toIso8601String(),
      );

      // Save additional user data if available
      if (userData['avatar'] != null && userData['avatar'].toString().isNotEmpty) {
        final avatarUrl = userData['avatar'].toString();
        await prefs.setString('user_avatar', avatarUrl);
        // Always update user_profile_image with server avatar (server is source of truth)
        await prefs.setString('user_profile_image', avatarUrl);
        print('Saved avatar to user_profile_image during login: $avatarUrl');
      } else {
        // If server doesn't have avatar, check if we have a preserved one from logout
        final preservedImage = prefs.getString('user_profile_image');
        if (preservedImage != null && preservedImage.isNotEmpty) {
          // Keep the preserved image
          await prefs.setString('user_avatar', preservedImage);
          print('Kept preserved profile image during login: $preservedImage');
        }
      }
      if (userData['location'] != null) {
        await prefs.setString('user_location', userData['location']);
      }
    } catch (e) {
      print('Error saving user data: $e');
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
