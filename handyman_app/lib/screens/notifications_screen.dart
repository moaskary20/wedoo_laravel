import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/language_service.dart';
import 'conversations_screen.dart';
import 'package:handyman_app/l10n/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _primoOnly = false;
  bool _isLoading = false;
  
  // Backend configuration
  static const String _baseUrl = 'https://free-styel.store/api';
  static const String _notificationsEndpoint = '/notifications';
  static const String _updateNotificationSettingsEndpoint = '/notifications/settings';
  
  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _loadNotificationSettings();
  }
  
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'name': 'عز الدين فرج',
      'detail': 'وحدة اقل من 3 غرف',
      'time': 'AM 10:54',
      'date': '9/21/25',
      'image': 'assets/images/craftsman1.jpg',
      'isPrimo': true,
    },
    {
      'id': 2,
      'name': 'محمد محمود',
      'detail': 'وحدة اقل من 3 غرف',
      'time': 'PM 2:37',
      'date': '9/16/25',
      'image': 'assets/images/craftsman2.jpg',
      'isPrimo': true,
    },
    {
      'id': 3,
      'name': 'محمود محمد مهدى',
      'detail': 'وحدة اقل من 3 غرف',
      'time': 'PM 4:07',
      'date': '9/12/25',
      'image': 'assets/images/craftsman3.jpg',
      'isPrimo': true,
    },
    {
      'id': 4,
      'name': 'محمد حسن محمد',
      'detail': 'وحدة اقل من 3 غرف',
      'time': 'PM 4:05',
      'date': '9/12/25',
      'image': 'assets/images/craftsman4.jpg',
      'isPrimo': true,
    },
    {
      'id': 5,
      'name': 'ahmed abuelela',
      'detail': 'صيانات خفيفة',
      'time': 'PM 10:10',
      'date': '5/21/25',
      'image': 'assets/images/craftsman5.jpg',
      'isPrimo': false,
    },
    {
      'id': 6,
      'name': 'زكريا مصطفى زكريا',
      'detail': 'صيانات خفيفة',
      'time': 'PM 12:08',
      'date': '5/21/25',
      'image': 'assets/images/craftsman6.jpg',
      'isPrimo': false,
    },
    {
      'id': 7,
      'name': 'محمد عزت عبد الرازق',
      'detail': 'صيانات خفيفة',
      'time': 'PM 6:33',
      'date': '5/20/25',
      'image': 'assets/images/craftsman7.jpg',
      'isPrimo': false,
    },
    {
      'id': 8,
      'name': 'كيف تختار الكهربائي',
      'detail': 'نصائح مفيدة',
      'time': 'PM 5:30',
      'date': '5/20/25',
      'image': 'assets/images/tip.jpg',
      'isPrimo': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_primoOnly) {
      return _notifications.where((notification) => notification['isPrimo'] == true).toList();
    }
    return _notifications;
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';
    
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFfec901),
        appBar: AppBar(
          title: Text(
            l10n.notifications,
            style: const TextStyle(
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
        body: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              child: Column(
                children: [
                  // Primo Toggle Section
                  _buildPrimoToggle(),
                  
                  const SizedBox(height: 20),
                  
                  // Notifications List
                  _buildNotificationsList(),
                  
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

  Widget _buildPrimoToggle() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'اشعارات وي دو فقط',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Switch(
            value: _primoOnly,
            onChanged: (value) {
              setState(() {
                _primoOnly = value;
              });
              _updateNotificationSettings();
            },
            activeColor: Colors.blue,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    final filteredNotifications = _filteredNotifications;
    
    if (filteredNotifications.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Profile Image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 30,
              color: Colors.grey,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Notification Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main text
                Text(
                  'وافق: ${notification['name']} على طلبك',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Detail text
                Text(
                  notification['detail'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Timestamp
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${notification['time']}, ${notification['date']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Delete Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(6),
            ),
            child: GestureDetector(
              onTap: () => _deleteNotification(notification['id']),
              child: const Text(
                'حذف',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
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

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // For development - simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate loading notifications from admin panel
      print('Loading notifications from admin panel...');
      
      // TODO: Uncomment when backend is ready
      /*
      // Real API call to get notifications
      final response = await http.get(
        Uri.parse('$_baseUrl$_notificationsEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await _getUserToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _notifications.clear();
            _notifications.addAll(data['notifications'] ?? []);
          });
        }
      }
      */

    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/settings/notifications'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _primoOnly = data['data']['promo_offers'] ?? false;
          });
        }
      } else {
        // Fallback to local storage
        final prefs = await SharedPreferences.getInstance();
        setState(() {
          _primoOnly = prefs.getBool('primo_notifications_only') ?? false;
        });
      }
    } catch (e) {
      print('Error loading notification settings: $e');
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _primoOnly = prefs.getBool('primo_notifications_only') ?? false;
      });
    }
  }

  Future<void> _updateNotificationSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('primo_notifications_only', _primoOnly);

      // For development - simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate updating notification settings in admin panel
      print('Updating notification settings in admin panel: primo_only=$_primoOnly');
      
      // TODO: Uncomment when backend is ready
      /*
      // Real API call to update notification settings
      final response = await http.put(
        Uri.parse('$_baseUrl$_updateNotificationSettingsEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await _getUserToken()}',
        },
        body: jsonEncode({
          'primo_notifications_only': _primoOnly,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _showSuccessSnackBar('تم تحديث إعدادات الإشعارات');
        }
      }
      */

      _showSuccessSnackBar('تم تحديث إعدادات الإشعارات في الـ admin panel');

    } catch (e) {
      _showErrorSnackBar('خطأ في تحديث إعدادات الإشعارات');
      print('Error updating notification settings: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    try {
      // For development - simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate deleting notification from admin panel
      print('Deleting notification $notificationId from admin panel');
      
      // TODO: Uncomment when backend is ready
      /*
      // Real API call to delete notification
      final response = await http.delete(
        Uri.parse('$_baseUrl$_notificationsEndpoint/$notificationId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await _getUserToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _notifications.removeWhere((notification) => notification['id'] == notificationId);
          });
          _showSuccessSnackBar('تم حذف الإشعار');
        }
      }
      */

      // Remove from local list
      setState(() {
        _notifications.removeWhere((notification) => notification['id'] == notificationId);
      });
      _showSuccessSnackBar('تم حذف الإشعار من الـ admin panel');

    } catch (e) {
      _showErrorSnackBar('خطأ في حذف الإشعار');
      print('Error deleting notification: $e');
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
}
