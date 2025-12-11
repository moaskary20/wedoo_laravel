# التحقق من PHP-FPM وإعادة التشغيل

## المشكلة
عند محاولة إعادة تشغيل PHP-FPM، تظهر رسالة أن الخدمة غير موجودة.

## الحلول

### 1. التحقق من اسم خدمة PHP-FPM

جرب الأوامر التالية للعثور على اسم الخدمة:

```bash
# البحث عن جميع خدمات PHP-FPM
sudo systemctl list-units | grep php
sudo systemctl list-units | grep fpm

# أو البحث في جميع الخدمات
sudo systemctl list-units --all | grep php
```

### 2. التحقق من حالة PHP-FPM

```bash
# التحقق من حالة PHP-FPM
sudo systemctl status php-fpm
sudo systemctl status php8.3-fpm
sudo systemctl status php-fpm8.3
```

### 3. إذا كانت الخدمة موجودة باسم مختلف

```bash
# جرب هذه الأسماء الشائعة:
sudo systemctl restart php-fpm
sudo systemctl restart php-fpm8.3
sudo systemctl restart php8.3-fpm
sudo systemctl restart php-fpm.service
```

### 4. إذا لم تكن PHP-FPM مثبتة

```bash
# تثبيت PHP-FPM
sudo apt update
sudo apt install php8.3-fpm -y

# تفعيل الخدمة
sudo systemctl enable php8.3-fpm
sudo systemctl start php8.3-fpm
```

### 5. التحقق من إعدادات Nginx

إذا كنت تستخدم Nginx، تأكد من أن الإعدادات تشير إلى PHP-FPM الصحيح:

```bash
# فحص إعدادات Nginx
sudo nano /etc/nginx/sites-available/default
# أو
sudo nano /etc/nginx/sites-available/wedoo_laravel
```

ابحث عن:
```nginx
fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
# أو
fastcgi_pass unix:/run/php/php8.3-fpm.sock;
```

### 6. إعادة تحميل Nginx بدلاً من PHP-FPM

إذا لم تكن PHP-FPM مثبتة كخدمة منفصلة، يمكنك إعادة تحميل Nginx:

```bash
sudo systemctl reload nginx
# أو
sudo systemctl restart nginx
```

### 7. التحقق من Socket PHP-FPM

```bash
# التحقق من وجود socket PHP-FPM
ls -la /var/run/php/
ls -la /run/php/

# إذا كان موجوداً، يمكنك إعادة تشغيله مباشرة
sudo killall -USR2 php-fpm8.3
```

### 8. حل بديل: مسح Cache فقط

إذا لم تكن PHP-FPM مثبتة كخدمة منفصلة، يمكنك فقط مسح Cache:

```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear
php artisan config:cache
```

هذا عادة ما يكون كافياً لتطبيق التغييرات.

## ملاحظة مهمة

إذا كنت تستخدم Apache بدلاً من Nginx، فعادة ما يكون PHP-FPM غير مطلوب. في هذه الحالة:

```bash
# إعادة تشغيل Apache
sudo systemctl restart apache2
```

## التحقق من أن كل شيء يعمل

بعد إعادة التشغيل أو مسح Cache:

```bash
# التحقق من Laravel
php artisan about

# التحقق من أن الموقع يعمل
curl -I http://localhost
```

