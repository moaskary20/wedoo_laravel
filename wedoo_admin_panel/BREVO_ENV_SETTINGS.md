# إعدادات Brevo في ملف .env

## أضف هذه الإعدادات في ملف `.env` على السيرفر:

```env
# ============================================
# Brevo Email Configuration
# ============================================

# Mail Driver (استخدم brevo أو smtp)
MAIL_MAILER=brevo
MAIL_DRIVER=brevo

# Brevo SMTP Settings
BREVO_SMTP_HOST=smtp-relay.brevo.com
BREVO_SMTP_PORT=587
BREVO_SMTP_USERNAME=your-email@example.com
BREVO_SMTP_PASSWORD=your-smtp-key-here
BREVO_ENCRYPTION=tls

# From Address (يجب أن يكون نفس الإيميل المسجل في Brevo)
BREVO_FROM_EMAIL=noreply@wedoo.com
BREVO_FROM_NAME=WeDoo

# General Mail Settings (يمكن استخدامها بدلاً من Brevo settings)
MAIL_HOST=smtp-relay.brevo.com
MAIL_PORT=587
MAIL_USERNAME=your-email@example.com
MAIL_PASSWORD=your-smtp-key-here
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@wedoo.com
MAIL_FROM_NAME=WeDoo

# App URL (مهم للإيميلات)
APP_URL=https://free-styel.store
```

## كيفية الحصول على بيانات Brevo:

### 1. SMTP Key من Brevo:
1. سجل الدخول إلى [Brevo Dashboard](https://app.brevo.com)
2. اذهب إلى **SMTP & API** → **SMTP**
3. اضغط على **Generate new SMTP key**
4. انسخ الـ **SMTP Key** (يبدأ بـ `xsmtpib-...`)
5. ضع هذا الـ key في `BREVO_SMTP_PASSWORD` و `MAIL_PASSWORD`

### 2. SMTP Username:
- استخدم إيميل Brevo الخاص بك في `BREVO_SMTP_USERNAME` و `MAIL_USERNAME`

### 3. Sender Email:
- يجب أن يكون الإيميل في `BREVO_FROM_EMAIL` و `MAIL_FROM_ADDRESS` مفعّل في Brevo
- اذهب إلى **Senders & IP** في Brevo وقم بتفعيل الإيميل

## بعد إضافة الإعدادات:

```bash
# على السيرفر
cd /var/www/wedoo_laravel/wedoo_admin_panel

# مسح Cache
php artisan config:clear
php artisan cache:clear

# إعادة بناء Config
php artisan config:cache
```

## اختبار الإعداد:

بعد إضافة الإعدادات، اختبر إرسال إيميل من التطبيق (نسيت كلمة السر).

## استكشاف الأخطاء:

إذا لم يصل الإيميل، تحقق من:
1. الـ logs: `tail -f storage/logs/laravel.log`
2. SMTP Key صحيح
3. Sender Email مفعّل في Brevo
4. Port و Encryption صحيحين (587 + tls)

