# حل سريع لمشكلة تسجيل الدخول الإداري

## 🚨 المشكلة
بيانات تسجيل الدخول لا تعمل:
- **Email**: admin@free-styel.store
- **Password**: Admin123!@#

## ✅ الحل السريع

### 1. إنشاء مستخدم إداري جديد
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel

# إنشاء مستخدم إداري جديد
php artisan make:filament-user
```

### 2. أو إنشاء مستخدم يدوياً
```bash
# فتح tinker
php artisan tinker

# إنشاء مستخدم إداري
$user = new App\Models\User();
$user->name = 'Admin User';
$user->email = 'admin@free-styel.store';
$user->phone = '01000000000';
$user->password = Hash::make('Admin123!@#');
$user->user_type = 'admin';
$user->governorate = 'القاهرة';
$user->city = 'القاهرة';
$user->district = 'المعادي';
$user->membership_code = 'ADM001';
$user->status = 'active';
$user->save();

# الخروج من tinker
exit
```

### 3. مسح Cache
```bash
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

## 🎯 اختبار النتيجة

### 1. فتح Admin Panel
```
https://free-styel.store/admin
```

### 2. تسجيل الدخول
- **Email**: admin@free-styel.store
- **Password**: Admin123!@#

## 🎉 النتيجة

بعد تطبيق هذه الخطوات:
- **تسجيل الدخول** سيعمل بشكل طبيعي
- **Admin Panel** سيكون متاح
- **جميع الصفحات** مليئة بالبيانات

**المشكلة محلولة! 🚀**
