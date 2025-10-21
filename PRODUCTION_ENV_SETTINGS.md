# إعدادات البيئة للإنتاج

## 📋 متغيرات البيئة المطلوبة (.env)

```env
APP_NAME="Wedoo Admin Panel"
APP_ENV=production
APP_KEY=base64:YOUR_APP_KEY_HERE
APP_DEBUG=false
APP_URL=https://free-styel.store

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=wedoo_production
DB_USERNAME=wedoo_user
DB_PASSWORD=wedoo_password

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120
SESSION_DOMAIN=.free-styel.store
SESSION_SECURE=true
SESSION_HTTP_ONLY=true
SESSION_SAME_SITE=lax

MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=noreply@free-styel.store
MAIL_PASSWORD=your_email_password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS="noreply@free-styel.store"
MAIL_FROM_NAME="${APP_NAME}"

# CORS Settings
CORS_ALLOWED_ORIGINS=https://free-styel.store,https://www.free-styel.store,https://app.free-styel.store

# Security Settings
SANCTUM_STATEFUL_DOMAINS=free-styel.store,www.free-styel.store,app.free-styel.store
```

## 🔧 خطوات التطبيق

### 1. نسخ الملف
```bash
cp PRODUCTION_ENV_SETTINGS.md .env
```

### 2. تحديث القيم
- **APP_KEY**: `php artisan key:generate`
- **DB_PASSWORD**: كلمة مرور قاعدة البيانات
- **MAIL_PASSWORD**: كلمة مرور البريد الإلكتروني

### 3. تطبيق الإعدادات
```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
```
