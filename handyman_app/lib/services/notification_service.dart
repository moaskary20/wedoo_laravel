import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'new_orders',
        'طلبات جديدة',
        description: 'إشعارات الطلبات الجديدة للصنايعيين',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

  static const AndroidNotificationChannel _chatChannel =
      AndroidNotificationChannel(
        'chat_messages',
        'رسائل المحادثات',
        description: 'إشعارات الرسائل الجديدة',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

  Future<void> initialize() async {
    if (_initialized) {
      print('Notifications already initialized');
      return;
    }

    print('=== Initializing notifications ===');

    // Create notification channel for Android with sound enabled
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      try {
        await androidPlugin.createNotificationChannel(_androidChannel);
        await androidPlugin.createNotificationChannel(_chatChannel);
        print('✓ Notification channels created: new_orders, chat_messages');
      } catch (e) {
        print('✗ Error creating notification channel: $e');
      }
    } else {
      print('⚠ Android plugin not available');
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
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
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      // Request notification permission (required for Android 13+)
      final granted = await androidPlugin.requestNotificationsPermission();
      print('Notification permission granted: $granted');

      if (granted != true) {
        print('⚠️ WARNING: Notification permission not granted!');
      }

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
      importance:
          Importance.high, // High importance for sound and heads-up display
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
        summaryText: description.isNotEmpty
            ? description
            : 'اضغط للعرض', // Summary text
        htmlFormatTitle: true,
        htmlFormatContent: true,
      ),
      fullScreenIntent: false, // Don't show as full screen
      autoCancel: true, // Auto cancel when tapped
      ongoing: false, // Not ongoing
      ticker: 'طلب جديد من $customerName', // Ticker text for status bar
      actions: [
        AndroidNotificationAction('accept', 'قبول', showsUserInterface: false),
        AndroidNotificationAction('reject', 'رفض', showsUserInterface: false),
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
      // Verify notification channel exists by recreating it (safe operation)
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        // Recreate channel to ensure it exists with correct settings
        try {
          await androidPlugin.createNotificationChannel(_androidChannel);
          print('✓ Notification channel verified/created');
        } catch (e) {
          print('⚠ Error creating channel (may already exist): $e');
        }
      }

      print('Attempting to display notification...');
      await _notifications.show(
        orderId,
        'طلب جديد من $customerName',
        title,
        details,
        payload: 'order_$orderId',
      );

      print(
        '✓✓✓ Notification displayed successfully with sound and vibration ✓✓✓',
      );
    } catch (e) {
      print('✗✗✗ Error displaying notification: $e ✗✗✗');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<void> showChatMessageNotification({
    required int chatId,
    required String senderName,
    required String message,
  }) async {
    await initialize();

    print('=== Showing chat notification ===');
    print('Chat ID: $chatId');
    print('Sender: $senderName');
    print('Message: $message');

    final androidDetails = AndroidNotificationDetails(
      'chat_messages',
      'رسائل المحادثات',
      channelDescription: 'إشعارات الرسائل الجديدة',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.message,
      showWhen: true,
      when: DateTime.now().millisecondsSinceEpoch,
      styleInformation: BigTextStyleInformation(
        message,
        contentTitle: senderName,
        summaryText: 'رسالة جديدة',
        htmlFormatTitle: true,
        htmlFormatContent: true,
      ),
      autoCancel: true,
      ticker: 'رسالة جديدة من $senderName',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      categoryIdentifier: 'chat_messages',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        try {
          await androidPlugin.createNotificationChannel(_chatChannel);
        } catch (e) {
          print('⚠ Error creating chat channel: $e');
        }
      }

      await _notifications.show(
        chatId + 10000, // Offset ID to avoid conflict with order notifications
        senderName,
        message,
        details,
        payload: 'chat_$chatId',
      );

      print('✓✓✓ Chat notification displayed successfully ✓✓✓');
    } catch (e) {
      print('✗✗✗ Error displaying chat notification: $e ✗✗✗');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
