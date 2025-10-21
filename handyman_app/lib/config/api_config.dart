class ApiConfig {
  static const String baseUrl = 'http://localhost:8000';
  
  // API Endpoints
  static const String taskTypes = '$baseUrl/api/task-types/index';
  static const String ordersCreate = '$baseUrl/api/orders/create';
  static const String ordersList = '$baseUrl/api/orders/list';
  static const String craftsmanCount = '$baseUrl/api/craftsman/count';
  static const String authLogin = '$baseUrl/api/auth/login';
  static const String authRegister = '$baseUrl/api/auth/register';
  static const String userProfile = '$baseUrl/api/users/profile';
  static const String userUpdate = '$baseUrl/api/users/update';
  static const String notificationsList = '$baseUrl/api/notifications/list';
  static const String notificationsSend = '$baseUrl/api/notifications/send';
  static const String chatList = '$baseUrl/api/chat/list';
  static const String chatSend = '$baseUrl/api/chat/send';
  static const String promoVerify = '$baseUrl/api/promo/verify';
  static const String shopsList = '$baseUrl/api/shops/list';
  static const String shopsShow = '$baseUrl/api/shops/show';
  static const String shopsRate = '$baseUrl/api/shops/rate';
  static const String categoriesList = '$baseUrl/api/categories/list';
  static const String settingsGeneral = '$baseUrl/api/settings/general';
  static const String settingsNotifications = '$baseUrl/api/settings/notifications';
  static const String settingsPrivacy = '$baseUrl/api/settings/privacy';
  static const String settingsSupport = '$baseUrl/api/settings/support';
  
  // Common Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'WedooApp/1.0 (Flutter)',
    'Origin': 'https://free-styel.store',
  };
}
