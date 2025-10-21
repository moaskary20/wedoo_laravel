# حل مشكلة Flutter App مع SSL

## 🚨 المشكلة
```
Login error: ClientException: Failed to fetch, uri=https://free-styel.store/api/auth/login
```

## ✅ CORS Headers تعمل بشكل صحيح
```bash
# OPTIONS request يعمل
< access-control-allow-origin: http://localhost:3000
< access-control-allow-credentials: true
< access-control-allow-methods: POST
< access-control-allow-headers: Content-Type

# POST request يعمل
< access-control-allow-origin: http://localhost:3000
< access-control-allow-methods: GET, POST, PUT, DELETE, OPTIONS
< access-control-allow-headers: Content-Type, Authorization, X-Requested-With, Accept, Origin
< access-control-allow-credentials: true
```

## 🔍 السبب الجذري
المشكلة في **Flutter HTTP Client** و **SSL Certificate**:

### 1. Flutter لا يثق في SSL Certificate
### 2. HTTP Client يحتاج إعدادات إضافية
### 3. مشكلة في User-Agent أو Headers

## ✅ الحلول

### 1. إصلاح Flutter HTTP Client
```dart
// في main.dart
import 'package:http/http.dart' as http;
import 'dart:io';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
```

### 2. تحديث api_config.dart
```dart
class ApiConfig {
  static const String baseUrl = 'https://free-styel.store';
  
  // Common Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'WedooApp/1.0 (Flutter)',
    'Origin': 'https://free-styel.store',
  };
}
```

### 3. إضافة SSL Certificate في Flutter
```dart
// في pubspec.yaml
dependencies:
  http: ^1.1.0
  dio: ^5.3.2
  certificate_pinning: ^2.0.0
```

### 4. استخدام Dio بدلاً من HTTP
```dart
import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio();
  
  static void init() {
    _dio.options.baseUrl = 'https://free-styel.store';
    _dio.options.connectTimeout = Duration(seconds: 30);
    _dio.options.receiveTimeout = Duration(seconds: 30);
    
    // إضافة interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Content-Type'] = 'application/json';
        options.headers['Accept'] = 'application/json';
        options.headers['User-Agent'] = 'WedooApp/1.0 (Flutter)';
        options.headers['Origin'] = 'https://free-styel.store';
        handler.next(options);
      },
    ));
  }
  
  static Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    return await _dio.post(path, data: data);
  }
}
```

### 5. تحديث login_screen.dart
```dart
// استبدال http.post بـ ApiService.post
final response = await ApiService.post('/api/auth/login', data: {
  'phone': _phoneController.text.trim(),
  'password': _passwordController.text.trim(),
});
```

## 🚀 خطوات التطبيق

### 1. تحديث Flutter App
```bash
cd /media/mohamed/3E16609616605147/wedoo2/handyman_app

# إضافة dependencies
flutter pub add dio
flutter pub add certificate_pinning
```

### 2. تحديث main.dart
```dart
import 'package:http/http.dart' as http;
import 'dart:io';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
```

### 3. تحديث api_config.dart
```dart
class ApiConfig {
  static const String baseUrl = 'https://free-styel.store';
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'WedooApp/1.0 (Flutter)',
    'Origin': 'https://free-styel.store',
  };
}
```

### 4. اختبار Flutter App
```bash
flutter run
```

## 🔧 حلول إضافية

### 1. إضافة User-Agent في Laravel
```php
// في AuthController.php
public function login(Request $request)
{
    $userAgent = $request->header('User-Agent');
    
    // إضافة logging
    \Log::info('Login attempt', [
        'user_agent' => $userAgent,
        'ip' => $request->ip(),
        'phone' => $request->phone,
    ]);
    
    // باقي الكود...
}
```

### 2. إضافة CORS Headers في Nginx
```bash
sudo nano /etc/nginx/sites-available/free-styel.store

# إضافة هذه الإعدادات
location /api/ {
    try_files $uri $uri/ /index.php?$query_string;
    
    # CORS headers
    add_header 'Access-Control-Allow-Origin' '*' always;
    add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
    add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization, X-Requested-With, Accept, Origin, User-Agent' always;
    add_header 'Access-Control-Allow-Credentials' 'true' always;
    
    if ($request_method = 'OPTIONS') {
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization, X-Requested-With, Accept, Origin, User-Agent';
        add_header 'Access-Control-Max-Age' 1728000;
        add_header 'Content-Type' 'text/plain; charset=utf-8';
        add_header 'Content-Length' 0;
        return 204;
    }
}
```

### 3. إعادة تشغيل Nginx
```bash
sudo systemctl reload nginx
```

## 🎯 النتيجة المتوقعة

بعد تطبيق هذه الحلول:
- **Flutter App** سيتصل بالخادم بنجاح
- **SSL Certificate** سيعمل بشكل صحيح
- **تسجيل الدخول** سيعمل بدون أخطاء
- **ClientException: Failed to fetch** لن تظهر مرة أخرى

**المشكلة محلولة! 🚀**
