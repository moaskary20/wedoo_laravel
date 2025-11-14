# دليل إنشاء مستخدم مدير للـ Laravel Admin Panel

## 🎯 إنشاء مستخدم مدير جديد

### 1. إنشاء مستخدم مدير عبر Artisan
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel

# إنشاء مستخدم مدير جديد
php artisan make:filament-user
```

### 2. إدخال البيانات المطلوبة
عند تشغيل الأمر، سيطلب منك:
```
Name: Admin User
Email: admin@free-styel.store
Password: [أدخل كلمة مرور قوية]
```

### 3. مثال كامل
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel
php artisan make:filament-user

# سيظهر:
# Name: Admin User
# Email: admin@free-styel.store  
# Password: Admin123!@#
# Password (confirmation): Admin123!@#
```

## 🔧 إنشاء مستخدم مدير يدوياً

### 1. إنشاء Seeder للمدير
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel
php artisan make:seeder AdminUserSeeder
```

### 2. تعديل AdminUserSeeder
```php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    public function run(): void
    {
        User::create([
            'name' => 'Admin User',
            'email' => 'admin@free-styel.store',
            'password' => Hash::make('Admin123!@#'),
            'phone' => '01234567890',
            'user_type' => 'admin',
            'status' => 'active',
            'email_verified_at' => now(),
        ]);
    }
}
```

### 3. تشغيل الـ Seeder
```bash
php artisan db:seed --class=AdminUserSeeder
```

## 🚀 إنشاء مستخدم مدير مباشر

### 1. استخدام Tinker
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel
php artisan tinker
```

### 2. إنشاء المستخدم في Tinker
```php
use App\Models\User;
use Illuminate\Support\Facades\Hash;

User::create([
    'name' => 'Admin User',
    'email' => 'admin@free-styel.store',
    'password' => Hash::make('Admin123!@#'),
    'phone' => '01234567890',
    'user_type' => 'admin',
    'status' => 'active',
    'email_verified_at' => now(),
]);

exit
```

## 🔐 بيانات الدخول الافتراضية

### بعد إنشاء المستخدم:
- **الرابط**: https://free-styel.store/admin
- **البريد الإلكتروني**: admin@free-styel.store
- **كلمة المرور**: Admin123!@#

## 🛡️ تأمين كلمة المرور

### 1. كلمة مرور قوية
```
Admin123!@#  # مثال جيد
MySecurePass2024!  # مثال آخر
```

### 2. تغيير كلمة المرور بعد الدخول
1. ادخل إلى Admin Panel
2. اذهب إلى Settings
3. غير كلمة المرور

## 🔍 اختبار الدخول

### 1. اختبار الـ Admin Panel
```bash
# افتح المتصفح واذهب إلى:
https://free-styel.store/admin
```

### 2. اختبار API
```bash
# اختبار تسجيل الدخول عبر API
curl -X POST https://free-styel.store/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"01234567890","password":"Admin123!@#"}'
```

## 🚨 استكشاف الأخطاء

### 1. خطأ "User not found"
```bash
# تأكد من وجود المستخدم
php artisan tinker
User::where('email', 'admin@free-styel.store')->first();
```

### 2. خطأ "Invalid credentials"
```bash
# إعادة تعيين كلمة المرور
php artisan tinker
$user = User::where('email', 'admin@free-styel.store')->first();
$user->password = Hash::make('Admin123!@#');
$user->save();
```

### 3. خطأ "Access denied"
```bash
# تأكد من أن user_type = 'admin'
php artisan tinker
$user = User::where('email', 'admin@free-styel.store')->first();
$user->user_type = 'admin';
$user->save();
```

## 📱 إنشاء مستخدمين إضافيين

### 1. إنشاء صانعي
```bash
php artisan tinker

User::create([
    'name' => 'أحمد السباك',
    'email' => 'ahmed@example.com',
    'password' => Hash::make('password'),
    'phone' => '01234567890',
    'user_type' => 'craftsman',
    'category_id' => 1, // السباكة
    'governorate' => 'القاهرة',
    'city' => 'مدينة نصر',
    'status' => 'active',
]);
```

### 2. إنشاء عملاء
```bash
php artisan tinker

User::create([
    'name' => 'محمد الحريف',
    'email' => 'customer@example.com',
    'password' => Hash::make('password'),
    'phone' => '01234567891',
    'user_type' => 'customer',
    'governorate' => 'الجيزة',
    'city' => 'الدقي',
    'status' => 'active',
]);
```

## 🎯 النتيجة النهائية

بعد إنشاء المستخدم المدير:
- **Admin Panel**: https://free-styel.store/admin
- **البريد الإلكتروني**: admin@free-styel.store
- **كلمة المرور**: Admin123!@#

### الميزات المتاحة:
- إدارة المستخدمين
- إدارة الكاتيجري
- إدارة المحادثات
- إدارة الطلبات
- إدارة الإشعارات
- إدارة التقييمات

**النظام جاهز للاستخدام! 🚀**
