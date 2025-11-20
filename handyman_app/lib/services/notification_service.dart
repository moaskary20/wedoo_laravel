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

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'new_orders',
      'طلبات جديدة',
      description: 'إشعارات الطلبات الجديدة للصنايعيين',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
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
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
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

    // Sound will be played automatically by the notification system

    const androidDetails = AndroidNotificationDetails(
      'new_orders',
      'طلبات جديدة',
      channelDescription: 'إشعارات الطلبات الجديدة للصنايعيين',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      // Use default system sound (no custom sound file needed)
      category: AndroidNotificationCategory.message,
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

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      orderId,
      'طلب جديد من $customerName',
      title,
      details,
      payload: 'order_$orderId',
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}

