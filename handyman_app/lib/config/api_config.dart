class ApiConfig {
  static const String baseUrl = 'https://free-styel.store';
  static const String webProxyUrl = 'proxy.php';

  // API Endpoints
  static const String taskTypes = '$baseUrl/api/task-types/index';
  static const String ordersCreate = '$baseUrl/api/orders/create';
  static const String ordersList = '$baseUrl/api/orders/list';
  static const String ordersAssigned = '$baseUrl/api/orders/assigned';
  static const String craftsmanCount = '$baseUrl/api/craftsman/count';
  static const String craftsmanNearby = '$baseUrl/api/craftsman/nearby';
  static const String authLogin = '$baseUrl/api/auth/login';
  static const String authRegister = '$baseUrl/api/auth/register';
  static const String authForgotPassword = '$baseUrl/api/auth/forgot-password';
  static const String authVerifyResetCode =
      '$baseUrl/api/auth/verify-reset-code';
  static const String authResetPassword = '$baseUrl/api/auth/reset-password';
  static const String userProfile = '$baseUrl/api/users/profile';
  static const String userUpdate = '$baseUrl/api/users/update';
  static const String notificationsList = '$baseUrl/api/notifications/list';
  static const String notificationsSend = '$baseUrl/api/notifications/send';
  static const String chatList = '$baseUrl/api/chat/list';
  static const String chatMessages = '$baseUrl/api/chat/messages';
  static const String chatSend = '$baseUrl/api/chat/send';
  static const String promoVerify = '$baseUrl/api/promo/verify';
  static const String shopsList = '$baseUrl/api/shops/list';
  static const String shopsShow = '$baseUrl/api/shops/show';
  static const String shopsRate = '$baseUrl/api/shops/rate';
  static const String categoriesList = '$baseUrl/api/categories/list';
  static const String settingsGeneral = '$baseUrl/api/settings/general';
  static const String settingsNotifications =
      '$baseUrl/api/settings/notifications';
  static const String settingsPrivacy = '$baseUrl/api/settings/privacy';
  static const String settingsSupport = '$baseUrl/api/settings/support';
  static const String reviewsCreate = '$baseUrl/api/reviews/create';
  static String reviewsCanReview(int orderId) => '$baseUrl/api/reviews/can-review/$orderId';
  static String reviewsGetByOrder(int orderId) => '$baseUrl/api/reviews/order/$orderId';
  static String reviewsGetByCraftsman(int craftsmanId) => '$baseUrl/api/reviews/craftsman/$craftsmanId';

  // Common Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'WedooApp/1.0 (Flutter)',
    'Origin': 'https://free-styel.store',
  };

  // Web-specific headers (for CORS compatibility)
  static Map<String, String> get webHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'WedooApp/1.0 (Flutter Web)',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers':
        'Content-Type, Authorization, Accept, Origin, X-Requested-With',
  };

  static String orderInvite(int orderId) =>
      '$baseUrl/api/orders/$orderId/invite';
  static String orderAccept(int orderId) =>
      '$baseUrl/api/orders/$orderId/accept';
  static String orderReject(int orderId) =>
      '$baseUrl/api/orders/$orderId/reject';
}
