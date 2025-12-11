# إصلاح خطأ Undefined variable $errors في صفحة إعدادات Brevo

## المشكلة
عند محاولة حفظ إعدادات Brevo على السيرفر الخارجي، يظهر الخطأ:
```
ErrorException: Undefined variable $errors
```

## الحل

### 1. تحديث الملفات على السيرفر

#### أ. تحديث `app/Filament/Pages/BrevoSettings.php`

في دالة `save()`، أضف try-catch للتعامل مع validation errors:

```php
public function save(): void
{
    try {
        $data = $this->form->getState();
    } catch (\Illuminate\Validation\ValidationException $e) {
        // Filament handles validation errors automatically
        return;
    }
    
    // باقي الكود...
}
```

#### ب. التأكد من أن `resources/views/filament/pages/brevo-settings.blade.php` لا يحتوي على استخدام `$errors`

يجب أن يكون الملف بهذا الشكل:

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

**ملاحظة:** لا تستخدم `@if ($errors->any())` في Blade template لأن Filament يتعامل مع الأخطاء تلقائياً.

### 2. خطوات التطبيق على السيرفر

```bash
# 1. الانتقال إلى مجلد المشروع
cd /var/www/wedoo_laravel/wedoo_admin_panel

# 2. سحب آخر التحديثات من GitHub
git pull origin main

# 3. مسح Cache
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear

# 4. إعادة بناء Cache
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 5. إعادة تشغيل PHP-FPM (إذا لزم الأمر)
sudo systemctl restart php8.2-fpm
# أو
sudo service php8.2-fpm restart
```

### 3. التحقق من الصلاحيات

تأكد من أن ملف `.env` قابل للكتابة:

```bash
chmod 644 .env
chown www-data:www-data .env
```

### 4. التحقق من Logs

إذا استمرت المشكلة، تحقق من Laravel logs:

```bash
tail -f storage/logs/laravel.log
```

## ملاحظات مهمة

1. **Filament يتعامل مع الأخطاء تلقائياً:** لا حاجة لاستخدام `$errors` في Blade templates عند استخدام Filament Forms.

2. **Validation:** Filament Forms تقوم بالتحقق من صحة البيانات تلقائياً عند استدعاء `getState()`.

3. **Cache:** بعد أي تغيير في الكود، يجب مسح Cache دائماً.

4. **Permissions:** تأكد من أن Laravel لديه صلاحيات الكتابة على ملف `.env`.

## إذا استمرت المشكلة

1. تحقق من إصدار Filament:
   ```bash
   composer show filament/filament
   ```

2. تأكد من أن جميع التبعيات محدثة:
   ```bash
   composer update
   ```

3. تحقق من أن Livewire يعمل بشكل صحيح:
   ```bash
   php artisan livewire:discover
   ```
