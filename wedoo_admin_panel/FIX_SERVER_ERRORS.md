# إصلاح خطأ Undefined variable $errors على السيرفر

## الخطوات السريعة على السيرفر

```bash
# 1. الاتصال بالسيرفر
ssh root@144.91.106.22

# 2. الانتقال إلى مجلد المشروع
cd /var/www/wedoo_laravel/wedoo_admin_panel

# 3. سحب آخر التحديثات
git pull origin main

# 4. مسح جميع الـ Cache
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear

# 5. إعادة بناء Cache
php artisan config:cache
php artisan route:cache

# 6. التحقق من الصلاحيات
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
```

## إذا استمرت المشكلة

### 1. التحقق من الملفات

```bash
# التحقق من ملف Blade template
cat resources/views/filament/pages/brevo-settings.blade.php

# يجب ألا يحتوي على $errors
# إذا كان يحتوي، احذفه
```

### 2. التحقق من ملف BrevoSettings.php

```bash
# فحص الملف
cat app/Filament/Pages/BrevoSettings.php | grep -A 5 "public function save"
```

### 3. إعادة تحميل Nginx

```bash
sudo systemctl reload nginx
```

### 4. التحقق من Logs

```bash
tail -f storage/logs/laravel.log
```

## الحل البديل: تحديث الملفات يدوياً

إذا لم يعمل `git pull`، قم بتحديث الملفات يدوياً:

### ملف Blade Template

```bash
nano resources/views/filament/pages/brevo-settings.blade.php
```

يجب أن يكون المحتوى:

```blade
<x-filament-panels::page>
    <form wire:submit="save">
        {{ $this->form }}
        
        <div class="flex justify-end gap-4 mt-6">
            <x-filament::button 
                type="button" 
                color="info" 
                wire:click="testEmail" 
                wire:confirm="هل تريد إرسال إيميل تجريبي؟"
                icon="heroicon-o-paper-airplane">
                اختبار الإيميل
            </x-filament::button>
            <x-filament::button type="submit" color="success" icon="heroicon-o-check">
                حفظ الإعدادات
            </x-filament::button>
        </div>
    </form>
</x-filament-panels::page>
```

### ملف BrevoSettings.php

تأكد من أن دالة `save()` تبدأ بهذا:

```php
public function save(): void
{
    // Validate form data first
    $data = $this->form->getState();
    
    // باقي الكود...
}
```

**ملاحظة:** لا تستخدم `try-catch` حول `getState()` لأن Filament يتعامل مع الأخطاء تلقائياً.

