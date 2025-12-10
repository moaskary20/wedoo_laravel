# إصلاح خطأ BrevoSettings

## الخطأ:
```
TypeError: Filament\Forms\ComponentContainer::model(): Argument #1 ($model) must be of type Illuminate\Database\Eloquent\Model|string|null, array given, called in /var/www/wedoo_laravel/wedoo_admin_panel/app/Filament/Pages/BrevoSettings.php on line 183
```

## السبب:
السيرفر يعمل بنسخة قديمة من الكود تحتوي على `->model($this->data)` الذي تم إزالته في التحديثات الأخيرة.

## الحل:

### 1. سحب التحديثات من GitHub:
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel
git pull origin main
```

### 2. مسح Cache:
```bash
php artisan route:clear
php artisan config:clear
php artisan cache:clear
php artisan optimize:clear
composer dump-autoload
```

### 3. التحقق من الملف:
تأكد من أن السطر 183 في `app/Filament/Pages/BrevoSettings.php` لا يحتوي على `->model()`:

```php
// يجب أن يكون:
            ->statePath('data')
            ->columns(2);
    }

// وليس:
            ->statePath('data')
            ->columns(2)
            ->model($this->data);  // ❌ هذا خطأ
    }
```

## إذا استمرت المشكلة:

### التحقق من الملف مباشرة:
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel
grep -n "->model" app/Filament/Pages/BrevoSettings.php
```

إذا ظهرت أي نتائج، قم بحذف السطر الذي يحتوي على `->model($this->data)`.

### أو استبدل الملف بالكامل:
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel
git checkout HEAD -- app/Filament/Pages/BrevoSettings.php
```

