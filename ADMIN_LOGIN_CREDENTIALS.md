# بيانات الدخول للـ Admin Panel

## 🎯 إنشاء مستخدم مدير

### الطريقة السريعة:
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel
php artisan make:filament-user
```

### البيانات المطلوبة:
- **Name**: Admin User
- **Email**: admin@free-styel.store
- **Password**: Admin123!@#

## 🔐 بيانات الدخول النهائية

### بعد إنشاء المستخدم:
- **الرابط**: https://free-styel.store/admin
- **البريد الإلكتروني**: admin@free-styel.store
- **كلمة المرور**: Admin123!@#

## 🚀 إنشاء مستخدم يدوياً

### باستخدام Tinker:
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel
php artisan tinker
```

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

## 🎯 النتيجة

بعد إنشاء المستخدم:
- **Admin Panel**: https://free-styel.store/admin
- **البريد الإلكتروني**: admin@free-styel.store
- **كلمة المرور**: Admin123!@#

**النظام جاهز للاستخدام! 🚀**
