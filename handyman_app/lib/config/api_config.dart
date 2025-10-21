class ApiConfig {
  static const String baseUrl = 'https://free-styel.store';
  
  // API Endpoints
  static const String taskTypes = '$baseUrl/api/task-types/index.php';
  static const String ordersCreate = '$baseUrl/api/orders/create.php';
  static const String ordersList = '$baseUrl/api/orders/list.php';
  static const String craftsmanCount = '$baseUrl/api/craftsman/count.php';
  static const String authLogin = '$baseUrl/api/auth/login.php';
  static const String authRegister = '$baseUrl/api/auth/register.php';
  static const String userProfile = '$baseUrl/api/users/profile.php';
  static const String userUpdate = '$baseUrl/api/users/update.php';
  static const String notificationsList = '$baseUrl/api/notifications/list.php';
  static const String notificationsSend = '$baseUrl/api/notifications/send.php';
  static const String chatList = '$baseUrl/api/chat/list.php';
  static const String chatSend = '$baseUrl/api/chat/send.php';
  static const String promoVerify = '$baseUrl/api/promo/verify.php';
  static const String shopsList = '$baseUrl/api/shops/list.php';
  static const String shopsShow = '$baseUrl/api/shops/show.php';
  static const String shopsRate = '$baseUrl/api/shops/rate.php';
  static const String categoriesList = '$baseUrl/api/categories/list.php';
  static const String settingsGeneral = '$baseUrl/api/settings/general.php';
  static const String settingsNotifications = '$baseUrl/api/settings/notifications.php';
  static const String settingsPrivacy = '$baseUrl/api/settings/privacy.php';
  static const String settingsSupport = '$baseUrl/api/settings/support.php';
  
  // Common Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
