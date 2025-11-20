import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Create notification channel for Android with sound enabled
    const androidChannel = AndroidNotificationChannel(
      'new_orders',
      'طلبات جديدة',
      description: 'إشعارات الطلبات الجديدة للصنايعيين',
      importance: Importance.high, // High importance ensures sound and heads-up display
      playSound: true, // Enable sound
      enableVibration: true, // Enable vibration
      // Use default system notification sound (no custom sound file needed)
      showBadge: true, // Show badge on app icon
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(androidChannel);
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();

    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      // Request notification permission (required for Android 13+)
      final granted = await androidPlugin.requestNotificationsPermission();
      print('Notification permission granted: $granted');
      
      // Request exact alarms permission (for scheduling notifications)
      try {
        await androidPlugin.requestExactAlarmsPermission();
      } catch (e) {
        print('Exact alarms permission error: $e');
        // This is optional, continue even if it fails
      }
    }

    // iOS permissions are requested automatically through DarwinInitializationSettings
    // No need for separate permission request
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // This will be handled by the screen that shows the notification
  }

  Future<void> showNewOrderNotification({
    required int orderId,
    required String title,
    required String customerName,
    required String description,
  }) async {
    await initialize();

    print('=== Showing notification ===');
    print('Order ID: $orderId');
    print('Title: $title');
    print('Customer: $customerName');

    // Use default notification sound (system default)
    // Note: Cannot use const because 'when' requires a runtime value
    final androidDetails = AndroidNotificationDetails(
      'new_orders', // Channel ID - must match the channel created in initialize()
      'طلبات جديدة', // Channel name
      channelDescription: 'إشعارات الطلبات الجديدة للصنايعيين',
      importance: Importance.high, // High importance for sound and heads-up display
      priority: Priority.high, // High priority for immediate display
      playSound: true, // Enable sound
      enableVibration: true, // Enable vibration
      // Use default system notification sound (no custom sound file needed)
      category: AndroidNotificationCategory.message,
      showWhen: true,
      when: DateTime.now().millisecondsSinceEpoch,
      styleInformation: BigTextStyleInformation(
        title, // Title text
        contentTitle: 'طلب جديد من $customerName', // Notification title
        summaryText: description.isNotEmpty ? description : 'اضغط للعرض', // Summary text
        htmlFormatTitle: true,
        htmlFormatContent: true,
      ),
      fullScreenIntent: false, // Don't show as full screen
      autoCancel: true, // Auto cancel when tapped
      ongoing: false, // Not ongoing
      ticker: 'طلب جديد من $customerName', // Ticker text for status bar
      actions: [
        AndroidNotificationAction(
          'accept',
          'قبول',
          showsUserInterface: false,
        ),
        AndroidNotificationAction(
          'reject',
          'رفض',
          showsUserInterface: false,
        ),
        AndroidNotificationAction(
          'chat',
          'فتح المحادثة',
          showsUserInterface: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      categoryIdentifier: 'new_orders',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        orderId,
        'طلب جديد من $customerName',
        title,
        details,
        payload: 'order_$orderId',
      );
      print('✓ Notification displayed successfully');
    } catch (e) {
      print('✗ Error displaying notification: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}

