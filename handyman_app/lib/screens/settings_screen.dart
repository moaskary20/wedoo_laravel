import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';
import 'promo_code_screen.dart';
import 'conversations_screen.dart';
import 'terms_of_use_screen.dart';
import 'contact_us_screen.dart';
import 'login_screen.dart';
import 'my_orders_screen.dart';
import 'craftsman_orders_screen.dart';
import '../services/language_service.dart';
import '../main.dart';
import 'package:handyman_app/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName = 'مستخدم';
  String _membershipCode = '000000';
  bool _isLoading = true;
  String? _userProfileImage;
  Locale _currentLocale = LanguageService.defaultLocale;
  String _userType = 'customer';
  
  // Backend configuration
  static const String _baseUrl = 'https:///api/api';
  static const String _settingsEndpoint = '/settings';
  
  // App settings from backend
  Map<String, dynamic> _appSettings = {};
  Map<String, dynamic> _notificationSettings = {};
  Map<String, dynamic> _privacySettings = {};
  Map<String, dynamic> _supportSettings = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAppSettings();
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when returning from other screens
    _loadUserData();
  }

  @override
  void didUpdateWidget(SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data when widget updates
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get user data from SharedPreferences
      final userName = prefs.getString('user_name') ?? 'مستخدم';
      final membershipCode = prefs.getString('user_membership_code') ?? '000000';
      final userType = prefs.getString('user_type') ?? 'customer';
      
      // Load user profile image from admin panel
      final userProfileImage = await _loadUserProfileImage();
      
      setState(() {
        _userName = userName;
        _membershipCode = membershipCode;
        _userProfileImage = userProfileImage;
        _userType = userType;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAppSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_settingsEndpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _appSettings = data['data']['app'] ?? {};
            _notificationSettings = data['data']['notifications'] ?? {};
            _privacySettings = data['data']['privacy'] ?? {};
            _supportSettings = data['data']['support'] ?? {};
          });
        }
      }
    } catch (e) {
      print('Error loading app settings: $e');
    }
  }

  Future<String?> _loadUserProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // First try local storage (most recent) - this is the primary source
      final localImage = prefs.getString('user_profile_image');
      if (localImage != null && localImage.isNotEmpty) {
        print('Loading profile image from local storage: ${localImage.substring(0, localImage.length > 50 ? 50 : localImage.length)}...');
        return localImage;
      }
      
      // If no local image, try admin panel data
      final adminImages = prefs.getStringList('admin_profile_images') ?? [];
      if (adminImages.isNotEmpty) {
        // Get the latest image for this user
        final userId = await _getUserId();
        for (var i = adminImages.length - 1; i >= 0; i--) {
          try {
            final imageData = jsonDecode(adminImages[i]);
            if (imageData['user_id'] == userId) {
              print('Loading profile image from admin panel');
              return imageData['image_data'];
            }
          } catch (e) {
            print('Error parsing admin image data: $e');
          }
        }
      }
      
      print('No profile image found');
      return null;
    } catch (e) {
      print('Error loading user profile image: $e');
      return null;
    }
  }

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? '1';
  }

  Widget _buildUserProfileImage() {
    if (_userProfileImage != null && _userProfileImage!.isNotEmpty) {
      try {
        // Check if it's base64 data
        if (_userProfileImage!.startsWith('data:image') || 
            _userProfileImage!.startsWith('/9j/') || 
            _userProfileImage!.startsWith('iVBOR')) {
          // It's base64 data
          return ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.memory(
              base64Decode(_userProfileImage!.replaceAll('data:image/png;base64,', '')),
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.grey,
                );
              },
            ),
          );
        } else {
          // It's a file path
          return ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.file(
              File(_userProfileImage!),
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.grey,
                );
              },
            ),
          );
        }
      } catch (e) {
        print('Error displaying profile image: $e');
        return const Icon(
          Icons.person,
          size: 30,
          color: Colors.grey,
        );
      }
    }
    
    // Default icon if no image
    return const Icon(
      Icons.person,
      size: 30,
      color: Colors.grey,
    );
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
            l10n.settings,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.blue,
          elevation: 0,
          centerTitle: true,
          actions: [
            Container(
              margin: EdgeInsets.only(right: isRtl ? 16 : 0, left: isRtl ? 0 : 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _currentLocale.languageCode == 'ar' ? 'عربي' : 'FR',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Section
                  _buildProfileSection(),
                  
                  // Settings List
                  _buildSettingsList(),
                  
                  // Social Media Section
                  _buildSocialMediaSection(),
                  
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

  Widget _buildProfileSection() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      width: double.infinity,
      height: 120,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4CAF50),
            Color(0xFFfec901),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLoading ? l10n.loading : _userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _isLoading ? l10n.loading : '${l10n.membershipCode} : $_membershipCode',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: _buildUserProfileImage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList() {
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Settings Section
          _buildSectionTitle(l10n.settings),
          _buildSettingsItem(l10n.editProfile, Icons.settings, () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            );
            
            // Always reload user data when returning from edit profile
            // Clear cached image first to force reload
            setState(() {
              _userProfileImage = null;
            });
            
            // Reload all user data including profile image
            await _loadUserData();
            
            // Force rebuild to show updated image
            if (mounted) {
              setState(() {});
            }
          }),
          _buildSettingsItem(l10n.notifications, Icons.notifications, () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const NotificationsScreen()),
            );
          }),
          if (_userType == 'craftsman')
            _buildSettingsItem(l10n.myOrders, Icons.work_outline, () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CraftsmanOrdersScreen()),
              );
            })
          else
            _buildSettingsItem(l10n.myOrders, Icons.receipt_long, () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MyOrdersScreen()),
              );
            }),
          _buildSettingsItem(l10n.conversations, Icons.chat, () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ConversationsScreen()),
            );
          }),
          _buildSettingsItem(l10n.promoCode, Icons.card_giftcard, () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const PromoCodeScreen()),
            );
          }),
          
          const SizedBox(height: 30),
          
          // Application Section
          _buildSectionTitle(l10n.appTitle),
          _buildSettingsItem(l10n.termsOfUse, Icons.description, () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const TermsOfUseScreen()),
            );
          }),
          _buildSettingsItem(l10n.shareApp, Icons.share, () {
            _showShareOptions();
          }),
          _buildSettingsItem(l10n.contactUs, Icons.phone, () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ContactUsScreen()),
            );
          }),
          _buildSettingsItem(l10n.changeLanguage, Icons.language, () {
            _showLanguageBottomSheet(context);
          }),
          _buildSettingsItem(l10n.deleteAccount, Icons.delete, () {}),
          _buildSettingsItem(l10n.logout, Icons.logout, () {
            _handleLogout();
          }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, top: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.arrow_back_ios,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              icon,
              size: 20,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.followUs,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildSocialMediaIcon(Icons.facebook, const Color(0xFF1877F2), 'f', 'Facebook'),
              const SizedBox(width: 15),
              _buildSocialMediaIcon(Icons.camera_alt, const Color(0xFFE4405F), 'IG', 'Instagram'),
              const SizedBox(width: 15),
              _buildSocialMediaIcon(Icons.music_note, const Color(0xFF000000), 'TT', 'TikTok'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaIcon(IconData icon, Color color, String text, String platform) {
    return GestureDetector(
      onTap: () {
        _openSocialMedia(platform);
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _openSocialMedia(String platform) {
    String url = '';
    String message = '';
    
    switch (platform) {
      case 'Facebook':
        url = 'https://facebook.com/yourpage';
        message = 'فتح صفحة الفيس بوك';
        break;
      case 'Instagram':
        url = 'https://instagram.com/yourpage';
        message = 'فتح صفحة الإنستجرام';
        break;
      case 'TikTok':
        url = 'https://tiktok.com/@yourpage';
        message = 'فتح صفحة التيك توك';
        break;
    }
    
    // Show message to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // TODO: Add url_launcher to open social media links
    // url_launcher.launch(url);
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = _currentLocale.languageCode == 'ar';
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Container(
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
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Title
                Text(
                  l10n.selectLanguage,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Language options
                _buildLanguageOption(
                  context,
                  LanguageService.arabicLocale,
                  l10n.arabic,
                  'Arabic',
                  Icons.language,
                  _currentLocale.languageCode == 'ar',
                ),
                
                _buildLanguageOption(
                  context,
                  LanguageService.frenchLocale,
                  l10n.french,
                  'Français',
                  Icons.language,
                  _currentLocale.languageCode == 'fr',
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, Locale locale, String title, String subtitle, IconData icon, bool isSelected) {
    final l10n = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        context.changeAppLocale(locale);
        setState(() {
          _currentLocale = locale;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.languageChanged(title)),
            backgroundColor: Colors.green,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFfec901).withValues(alpha: 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFfec901) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFfec901) : Colors.grey[300],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFFfec901) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFfec901),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingHelpButton() {
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
              AppLocalizations.of(context)!.help,
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

  Future<void> _handleLogout() async {
    final l10n = AppLocalizations.of(context)!;
    
    // Show confirmation dialog
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.logout),
          content: Text(l10n.logoutConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      try {
        // Clear all user data from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.logoutSuccess),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Navigate to login screen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.logoutError),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showShareOptions() {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = _currentLocale.languageCode == 'ar';
    
    // App share text
    final shareText = l10n.shareAppMessage;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Container(
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
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Title
                Text(
                  l10n.shareApp,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Share options
                _buildShareOption(
                  context,
                  'Facebook',
                  Icons.facebook,
                  const Color(0xFF1877F2),
                  () => _shareOnFacebook(shareText),
                ),
                
                _buildShareOption(
                  context,
                  'WhatsApp',
                  Icons.phone,
                  const Color(0xFF25D366),
                  () => _shareOnWhatsApp(shareText),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareOption(BuildContext context, String platform, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Text(
                platform,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareOnFacebook(String text) async {
    try {
      // Facebook share URL
      final encodedText = Uri.encodeComponent(text);
      final url = 'https://www.facebook.com/sharer/sharer.php?u=https://free-styel.store&quote=$encodedText';
      
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        final l10n = AppLocalizations.of(context)!;
        _showShareError(l10n.cannotOpenFacebook);
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      _showShareError(l10n.errorSharingOnFacebook);
      print('Facebook share error: $e');
    }
  }

  Future<void> _shareOnWhatsApp(String text) async {
    try {
      // WhatsApp share URL
      final encodedText = Uri.encodeComponent(text);
      final url = 'https://wa.me/?text=$encodedText';
      
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        final l10n = AppLocalizations.of(context)!;
        _showShareError(l10n.cannotOpenWhatsApp);
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      _showShareError(l10n.errorSharingOnWhatsApp);
      print('WhatsApp share error: $e');
    }
  }

  void _showShareError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

}
