# 🔧 تفعيل CORS - تعليمات شاملة

## 📋 الملفات المطلوب رفعها:

### 1. ملفات API مع CORS:
- **`auth-login-cors.php`** → `/var/www/wedoo_laravel/public/api/auth/login.php`
- **`auth-register-cors.php`** → `/var/www/wedoo_laravel/public/api/auth/register.php`

### 2. ملف .htaccess:
- **`.htaccess-cors`** → `/var/www/wedoo_laravel/public/api/.htaccess`

## 🚀 خطوات التفعيل:

### 1. رفع ملفات API:
```bash
# الاتصال بالسيرفر
ssh root@vmi2704354.contaboserver.net

# إنشاء مجلد auth
mkdir -p /var/www/wedoo_laravel/public/api/auth

# إنشاء ملف login.php مع CORS
cat > /var/www/wedoo_laravel/public/api/auth/login.php << 'EOF'
<?php
// CORS Headers - محسنة
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin, X-Requested-With, X-Custom-Header');
header('Access-Control-Max-Age: 86400');
header('Content-Type: application/json; charset=utf-8');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);

// Validate required fields
$required_fields = ['phone', 'password'];
foreach ($required_fields as $field) {
    if (!isset($input[$field])) {
        echo json_encode([
            'success' => false, 
            'message' => "Missing required field: $field",
            'error_code' => 'MISSING_FIELD'
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
}

// Sample users data
$users = [
    [
        'id' => 1,
        'name' => 'مستخدم تجريبي',
        'phone' => '01000690805',
        'password' => 'askary20',
        'email' => 'demo@example.com',
        'user_type' => 'customer',
        'governorate' => 'تونس',
        'city' => 'تونس العاصمة',
        'district' => 'المركز',
        'membership_code' => '558206',
        'status' => 'active'
    ],
    [
        'id' => 2,
        'name' => 'أحمد محمد',
        'phone' => '01234567890',
        'password' => 'password123',
        'email' => 'ahmed@example.com',
        'user_type' => 'customer',
        'governorate' => 'تونس',
        'city' => 'تونس العاصمة',
        'district' => 'الحي الإداري',
        'membership_code' => 'WED123456',
        'status' => 'active'
    ]
];

// Find user by phone and password
$user = null;
foreach ($users as $u) {
    if ($u['phone'] === $input['phone'] && $u['password'] === $input['password']) {
        $user = $u;
        break;
    }
}

if ($user) {
    // Generate tokens
    $access_token = 'token_' . uniqid() . '_' . time();
    $refresh_token = 'refresh_' . uniqid() . '_' . time();
    
    // Remove password from response
    unset($user['password']);
    
    // Add tokens
    $user['access_token'] = $access_token;
    $user['refresh_token'] = $refresh_token;
    $user['login_time'] = date('Y-m-d H:i:s');
    
    echo json_encode([
        'success' => true,
        'data' => $user,
        'message' => 'Login successful',
        'timestamp' => time()
    ], JSON_UNESCAPED_UNICODE);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid phone number or password',
        'error_code' => 'INVALID_CREDENTIALS'
    ], JSON_UNESCAPED_UNICODE);
}
?>
EOF

# إنشاء ملف register.php مع CORS
cat > /var/www/wedoo_laravel/public/api/auth/register.php << 'EOF'
<?php
// CORS Headers - محسنة
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin, X-Requested-With, X-Custom-Header');
header('Access-Control-Max-Age: 86400');
header('Content-Type: application/json; charset=utf-8');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);

// Validate required fields
$required_fields = ['name', 'phone', 'email', 'password', 'user_type', 'governorate', 'city', 'district'];
foreach ($required_fields as $field) {
    if (!isset($input[$field])) {
        echo json_encode([
            'success' => false, 
            'message' => "Missing required field: $field",
            'error_code' => 'MISSING_FIELD'
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }
}

// Validate phone number format
if (!preg_match('/^01[0-9]{9}$/', $input['phone'])) {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid phone number format',
        'error_code' => 'INVALID_PHONE'
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

// Validate email format
if (!filter_var($input['email'], FILTER_VALIDATE_EMAIL)) {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid email format',
        'error_code' => 'INVALID_EMAIL'
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

// Simulate user registration
$user_id = rand(1000, 9999);
$membership_code = 'WED' . rand(100000, 999999);
$access_token = 'token_' . uniqid() . '_' . time();
$refresh_token = 'refresh_' . uniqid() . '_' . time();

// Simulate successful registration
$user_data = [
    'id' => $user_id,
    'name' => $input['name'],
    'phone' => $input['phone'],
    'email' => $input['email'],
    'user_type' => $input['user_type'],
    'governorate' => $input['governorate'],
    'city' => $input['city'],
    'district' => $input['district'],
    'membership_code' => $membership_code,
    'access_token' => $access_token,
    'refresh_token' => $refresh_token,
    'created_at' => date('Y-m-d H:i:s'),
    'status' => 'active'
];

echo json_encode([
    'success' => true,
    'data' => $user_data,
    'message' => 'User registered successfully',
    'timestamp' => time()
], JSON_UNESCAPED_UNICODE);
?>
EOF
```

### 2. إنشاء ملف .htaccess:
```bash
# إنشاء ملف .htaccess في مجلد API
cat > /var/www/wedoo_laravel/public/api/.htaccess << 'EOF'
# CORS Headers for API
<IfModule mod_headers.c>
    # Enable CORS for all origins
    Header always set Access-Control-Allow-Origin "*"
    Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    Header always set Access-Control-Allow-Headers "Content-Type, Authorization, Accept, Origin, X-Requested-With, X-Custom-Header"
    Header always set Access-Control-Max-Age "86400"
    
    # Handle preflight OPTIONS requests
    RewriteEngine On
    RewriteCond %{REQUEST_METHOD} OPTIONS
    RewriteRule ^(.*)$ $1 [R=200,L]
</IfModule>

# Enable PHP error reporting for debugging
php_flag display_errors On
php_value error_reporting "E_ALL"

# Set default charset
AddDefaultCharset UTF-8

# Enable compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/plain
    AddOutputFilterByType DEFLATE text/html
    AddOutputFilterByType DEFLATE text/xml
    AddOutputFilterByType DEFLATE text/css
    AddOutputFilterByType DEFLATE application/xml
    AddOutputFilterByType DEFLATE application/xhtml+xml
    AddOutputFilterByType DEFLATE application/rss+xml
    AddOutputFilterByType DEFLATE application/javascript
    AddOutputFilterByType DEFLATE application/x-javascript
    AddOutputFilterByType DEFLATE application/json
</IfModule>

# Cache control for API responses
<FilesMatch "\.(php)$">
    Header set Cache-Control "no-cache, no-store, must-revalidate"
    Header set Pragma "no-cache"
    Header set Expires "0"
</FilesMatch>
EOF
```

### 3. تعيين الصلاحيات:
```bash
chmod 644 /var/www/wedoo_laravel/public/api/auth/login.php
chmod 644 /var/www/wedoo_laravel/public/api/auth/register.php
chmod 644 /var/www/wedoo_laravel/public/api/.htaccess
```

## 🧪 اختبار CORS:

### اختبار تسجيل الدخول:
```bash
curl -X POST "https://free-styel.store/api/auth/login.php" \
  -H "Content-Type: application/json" \
  -H "Origin: https://free-styel.store" \
  -d '{"phone":"01000690805","password":"askary20"}' \
  -v
```

### اختبار التسجيل:
```bash
curl -X POST "https://free-styel.store/api/auth/register.php" \
  -H "Content-Type: application/json" \
  -H "Origin: https://free-styel.store" \
  -d '{"name":"أحمد محمد","phone":"01234567890","email":"ahmed@example.com","password":"password123","user_type":"customer","governorate":"تونس","city":"تونس العاصمة","district":"المركز"}' \
  -v
```

### اختبار OPTIONS (Preflight):
```bash
curl -X OPTIONS "https://free-styel.store/api/auth/login.php" \
  -H "Origin: https://free-styel.store" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v
```

## ✅ النتيجة المتوقعة:

بعد تفعيل CORS:
- ✅ **CORS Headers** تظهر في الاستجابة
- ✅ **OPTIONS requests** تعمل بشكل صحيح
- ✅ **التطبيق** يمكنه الاتصال بالسيرفر
- ✅ **لا توجد أخطاء CORS** في المتصفح

## 🔧 CORS Headers المضافة:

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization, Accept, Origin, X-Requested-With, X-Custom-Header
Access-Control-Max-Age: 86400
Content-Type: application/json; charset=utf-8
```

---
**تاريخ الإنشاء:** 2025-10-21  
**الحالة:** جاهز للرفع
