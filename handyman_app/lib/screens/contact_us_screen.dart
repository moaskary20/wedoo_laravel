import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/language_service.dart';
import 'conversations_screen.dart';
import 'package:handyman_app/l10n/app_localizations.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = true;
  Locale _currentLocale = LanguageService.defaultLocale;
  
  // Backend configuration
  static const String _baseUrl = 'https://free-styel.store/api';
  static const String _contactUsEndpoint = '/contact-us';
  static const String _supportSettingsEndpoint = '/settings/support';
  
  // Support settings from backend
  Map<String, dynamic> _supportSettings = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSupportSettings();
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
    _nameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get user data from individual SharedPreferences keys
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
        
        // Build location string from saved data
        if (userGovernorate.isNotEmpty && userCity.isNotEmpty && userArea.isNotEmpty) {
          _locationController.text = '$userGovernorate - $userCity - $userArea';
        } else if (userGovernorate.isNotEmpty && userCity.isNotEmpty) {
          _locationController.text = '$userGovernorate - $userCity';
        } else if (userGovernorate.isNotEmpty) {
          _locationController.text = userGovernorate;
        } else {
          final l10n = AppLocalizations.of(context);
          _locationController.text = l10n?.locationNotSet ?? 'لم يتم تحديد الموقع';
        }
      });
    } catch (e) {
      print('Error loading user data: $e');
      // Set default values on error
      final l10n = AppLocalizations.of(context);
      setState(() {
        _nameController.text = l10n?.user ?? 'مستخدم';
        _emailController.text = 'user@example.com';
        _phoneController.text = '0000000000';
        _locationController.text = l10n?.locationNotSet ?? 'لم يتم تحديد الموقع';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSupportSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_supportSettingsEndpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _supportSettings = data['data'] ?? {};
          });
        }
      }
    } catch (e) {
      print('Error loading support settings: $e');
    }
  }

  Future<void> _sendMessage() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseWriteMessage),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare contact message data
      final contactData = {
        'user_name': _nameController.text.trim(),
        'user_email': _emailController.text.trim(),
        'user_phone': _phoneController.text.trim(),
        'user_location': _locationController.text.trim(),
        'message': _messageController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'contact_us',
      };

      // Simulate sending to admin panel
      await Future.delayed(const Duration(seconds: 2));
      
      print('Contact message sent to admin panel: $contactData');
      
      // Show success message
      final l10n = AppLocalizations.of(context)!;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.messageSentSuccess),
            backgroundColor: Colors.green,
          ),
        );
        _messageController.clear();
      }
    } catch (e) {
      print('Error sending contact message: $e');
      final l10n = AppLocalizations.of(context)!;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorSendingMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
        appBar: AppBar(
          title: Text(
            l10n.contactUs,
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
        body: _isLoading
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        
                        // Contact form
                        _buildContactForm(),
                        
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

  Widget _buildContactForm() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Field
          _buildInputField(
            l10n.name,
            _nameController,
            Icons.person,
          ),
          
          const SizedBox(height: 16),
          
          // Email Field
          _buildInputField(
            l10n.email,
            _emailController,
            Icons.email,
          ),
          
          const SizedBox(height: 16),
          
          // Location Field
          _buildInputField(
            l10n.location,
            _locationController,
            Icons.location_on,
          ),
          
          const SizedBox(height: 16),
          
          // Phone Field
          _buildInputField(
            l10n.phoneNumber,
            _phoneController,
            Icons.phone,
          ),
          
          const SizedBox(height: 16),
          
          // Message Field
          _buildMessageField(),
          
          const SizedBox(height: 20),
          
          // Send Button
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon) {
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
            color: const Color(0xFFffe480),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green[300]!, width: 1),
          ),
          child: TextField(
            controller: controller,
            textAlign: _currentLocale.languageCode == 'ar' ? TextAlign.right : TextAlign.left,
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

  Widget _buildMessageField() {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.message,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFffe480),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green[300]!, width: 1),
          ),
          child: TextField(
            controller: _messageController,
            textAlign: _currentLocale.languageCode == 'ar' ? TextAlign.right : TextAlign.left,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l10n.writeYourMessage,
              hintStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: const Icon(
                Icons.message,
                color: Colors.grey,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    final l10n = AppLocalizations.of(context)!;
    
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendMessage,
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
            : Text(
                l10n.submit,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildFloatingHelpButton() {
    final l10n = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onTap: () {
        openSupportChat(context);
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
            Text(
              l10n.help,
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
