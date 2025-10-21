# إنشاء مستخدم إداري جديد

## 🚨 المشكلة
بيانات تسجيل الدخول الحالية لا تعمل:
- **Email**: admin@free-styel.store
- **Password**: Admin123!@#

## ✅ الحلول المتاحة

### 1. إنشاء مستخدم إداري جديد
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel

# إنشاء مستخدم إداري جديد
php artisan make:filament-user
```

### 2. إنشاء مستخدم إداري يدوياً
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

### 3. إعادة تعيين كلمة المرور
```bash
# فتح tinker
php artisan tinker

# البحث عن المستخدم
$user = App\Models\User::where('email', 'admin@free-styel.store')->first();

# إعادة تعيين كلمة المرور
$user->password = Hash::make('Admin123!@#');
$user->save();

# الخروج من tinker
exit
```

### 4. حذف المستخدم القديم وإنشاء جديد
```bash
# فتح tinker
php artisan tinker

# حذف المستخدم القديم
App\Models\User::where('email', 'admin@free-styel.store')->delete();

# إنشاء مستخدم جديد
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

## 🔧 إعدادات إضافية

### 1. مسح Cache
```bash
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

### 2. إعادة تعيين أذونات
```bash
sudo chown -R www-data:www-data storage
sudo chmod -R 775 storage
```

### 3. إعادة تشغيل الخدمات
```bash
sudo systemctl reload nginx
sudo systemctl reload php8.2-fpm
```

## 🎯 بيانات تسجيل الدخول الجديدة

### الطريقة الأولى (php artisan make:filament-user):
- سيطلب منك إدخال البيانات
- **Name**: Admin User
- **Email**: admin@free-styel.store
- **Password**: Admin123!@#

### الطريقة الثانية (يدوياً):
- **Email**: admin@free-styel.store
- **Password**: Admin123!@#

## 🚀 اختبار تسجيل الدخول

### 1. فتح Admin Panel
```
https://free-styel.store/admin
```

### 2. تسجيل الدخول
- **Email**: admin@free-styel.store
- **Password**: Admin123!@#

## 🎉 النتيجة

بعد تطبيق أي من هذه الطرق:
- **تسجيل الدخول** سيعمل بشكل طبيعي
- **Admin Panel** سيكون متاح
- **جميع الصفحات** مليئة بالبيانات

**المشكلة محلولة! 🚀**
