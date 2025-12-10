# أين تضع إعدادات Brevo؟

## الموقع: ملف `.env` على السيرفر

### الخطوات:

#### 1. الاتصال بالسيرفر:
```bash
ssh username@free-styel.store
```

#### 2. الانتقال إلى مجلد Laravel:
```bash
cd /var/www/wedoo_laravel/wedoo_admin_panel
```

#### 3. فتح ملف `.env`:
```bash
nano .env
# أو
vi .env
```

#### 4. إضافة إعدادات Brevo في نهاية الملف:

```env
# ============================================
# Brevo Email Configuration
# ============================================

# Mail Driver
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

# General Mail Settings
MAIL_HOST=smtp-relay.brevo.com
MAIL_PORT=587
MAIL_USERNAME=your-email@example.com
MAIL_PASSWORD=your-smtp-key-here
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@wedoo.com
MAIL_FROM_NAME=WeDoo
```

#### 5. حفظ الملف:
- في `nano`: اضغط `Ctrl + X` ثم `Y` ثم `Enter`
- في `vi`: اضغط `Esc` ثم اكتب `:wq` ثم `Enter`

#### 6. مسح Cache وإعادة بناء Config:
```bash
php artisan config:clear
php artisan cache:clear
php artisan config:cache
```

## كيفية الحصول على بيانات Brevo:

### 1. SMTP Key:
1. اذهب إلى [Brevo Dashboard](https://app.brevo.com)
2. سجل الدخول
3. اذهب إلى **SMTP & API** → **SMTP**
4. اضغط على **Generate new SMTP key**
5. انسخ الـ **SMTP Key** (يبدأ بـ `xsmtpib-...`)
6. ضعه في `BREVO_SMTP_PASSWORD` و `MAIL_PASSWORD`

### 2. SMTP Username:
- استخدم إيميل Brevo الخاص بك
- ضعه في `BREVO_SMTP_USERNAME` و `MAIL_USERNAME`

### 3. Sender Email:
- يجب أن يكون الإيميل في `BREVO_FROM_EMAIL` مفعّل في Brevo
- اذهب إلى **Senders & IP** في Brevo
- أضف الإيميل وقم بتفعيله

## مثال على ملف .env:

```env
APP_NAME=WeDoo
APP_ENV=production
APP_KEY=base64:...
APP_DEBUG=false
APP_URL=https://free-styel.store

# Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=wedoo_db
DB_USERNAME=wedoo_user
DB_PASSWORD=your-db-password

# Brevo Email Settings
MAIL_MAILER=brevo
MAIL_DRIVER=brevo
BREVO_SMTP_HOST=smtp-relay.brevo.com
BREVO_SMTP_PORT=587
BREVO_SMTP_USERNAME=contact@wedoo.com
BREVO_SMTP_PASSWORD=xsmtpib-1234567890abcdef
BREVO_ENCRYPTION=tls
BREVO_FROM_EMAIL=noreply@wedoo.com
BREVO_FROM_NAME=WeDoo
MAIL_FROM_ADDRESS=noreply@wedoo.com
MAIL_FROM_NAME=WeDoo
```

## ملاحظات مهمة:

1. **لا تضع مسافات** حول علامة `=` في ملف `.env`
2. **لا تستخدم علامات اقتباس** حول القيم
3. **تأكد من عدم وجود مسافات** في نهاية الأسطر
4. **SMTP Key** حساس - لا تشاركه مع أحد

## التحقق من الإعداد:

بعد إضافة الإعدادات، اختبر إرسال إيميل من التطبيق (نسيت كلمة السر).

إذا لم يصل الإيميل، تحقق من الـ logs:
```bash
tail -f storage/logs/laravel.log | grep -i mail
```

