# Wedoo - تطبيق الخدمات اليدوية

تطبيق شامل للخدمات اليدوية والصنايع في تونس

## 🎯 نظرة عامة

Wedoo هو تطبيق موبايل متكامل يربط العملاء بالصنايع ومقدمي الخدمات اليدوية في تونس. يوفر التطبيق منصة سهلة وآمنة لطلب الخدمات وإدارة الطلبات.

## 📱 المميزات الرئيسية

### للعملاء
- ✅ **تسجيل الدخول** - نظام مصادقة آمن
- ✅ **تصفح الخدمات** - تصنيفات متنوعة للخدمات
- ✅ **طلب الخدمات** - إنشاء طلبات مفصلة
- ✅ **تتبع الطلبات** - متابعة حالة الطلبات
- ✅ **المحادثات** - التواصل مع الصنايع
- ✅ **التقييمات** - تقييم الخدمات المقدمة
- ✅ **البرومو كود** - أكواد خصم حصرية
- ✅ **المحلات والمعارض** - تصفح المحلات التجارية

### للصنايع
- ✅ **تسجيل الحساب** - إنشاء حساب صانيع
- ✅ **استقبال الطلبات** - إدارة الطلبات الواردة
- ✅ **المحادثات** - التواصل مع العملاء
- ✅ **إدارة الملف الشخصي** - تحديث البيانات
- ✅ **التقييمات** - بناء السمعة المهنية

## 🏗️ البنية التقنية

### تطبيق الموبايل (Flutter)
```
handyman_app/
├── lib/
│   ├── main.dart
│   └── screens/
│       ├── login_screen.dart
│       ├── demo_location_screen.dart
│       ├── main_screen.dart
│       ├── category_grid_screen.dart
│       ├── category_detail_screen.dart
│       ├── service_request_form.dart
│       ├── shops_exhibitions_screen.dart
│       ├── shop_detail_screen.dart
│       ├── shop_rating_screen.dart
│       ├── settings_screen.dart
│       ├── edit_profile_screen.dart
│       ├── notifications_screen.dart
│       ├── conversations_screen.dart
│       ├── contact_us_screen.dart
│       ├── my_orders_screen.dart
│       ├── app_explanation_screen.dart
│       ├── terms_of_use_screen.dart
│       ├── promo_code_screen.dart
│       ├── craft_secrets_screen.dart
│       └── registration/
│           ├── phone_input_screen.dart
│           ├── membership_type_screen.dart
│           ├── customer_registration_screen.dart
│           ├── craftsman_category_screen.dart
│           ├── craftsman_registration_screen.dart
│           └── location_selection_screen.dart
├── assets/
│   ├── images/
│   │   └── app_icon.png
│   └── fonts/
│       └── Cairo/
└── pubspec.yaml
```

### Backend API (PHP)
```
handyman_backend/
├── public/
│   ├── api/
│   │   ├── index.php
│   │   ├── auth/
│   │   │   └── login.php
│   │   ├── users/
│   │   │   └── index.php
│   │   ├── orders/
│   │   │   └── index.php
│   │   ├── shops/
│   │   │   └── index.php
│   │   ├── ratings/
│   │   │   └── index.php
│   │   ├── chat/
│   │   │   └── index.php
│   │   ├── promo-codes/
│   │   │   └── index.php
│   │   └── profile/
│   │       └── index.php
│   └── admin_panel/
│       ├── login.php
│       ├── dashboard.php
│       ├── users.php
│       ├── orders.php
│       ├── shops.php
│       ├── craftsmen.php
│       ├── categories.php
│       ├── ratings.php
│       ├── promo-codes.php
│       ├── notifications.php
│       └── settings.php
```

## 🚀 التثبيت والتشغيل

### 1. متطلبات النظام
- **Flutter SDK** 3.0+
- **PHP** 8.2+
- **Composer** (اختياري)
- **Git**

### 2. تثبيت التطبيق

#### تطبيق الموبايل
```bash
cd handyman_app
flutter pub get
flutter run
```

#### Backend API
```bash
cd handyman_backend
php -S localhost:8000
```

### 3. الوصول للتطبيق

#### تطبيق الموبايل
- **Android:** `flutter run` أو بناء APK
- **iOS:** `flutter run` (يتطلب Xcode)
- **Web:** `flutter run -d web`

#### Admin Panel
- **الرابط:** http://free-styel.store/admin_panel/
- **المستخدم:** mo.askary@gmail.com
- **كلمة المرور:** askary20

#### API
- **Base URL:** http://free-styel.store/api/
- **Documentation:** http://free-styel.store/api/README.md

## 📊 المميزات التقنية

### تطبيق Flutter
- ✅ **Material Design** - تصميم حديث ومتجاوب
- ✅ **RTL Support** - دعم كامل للعربية
- ✅ **State Management** - إدارة الحالة المتقدمة
- ✅ **API Integration** - تكامل مع Backend
- ✅ **Local Storage** - تخزين محلي آمن
- ✅ **Image Picker** - اختيار الصور
- ✅ **Google Maps** - خرائط تفاعلية
- ✅ **Push Notifications** - إشعارات فورية

### Backend PHP
- ✅ **RESTful API** - API منظم ومتوافق
- ✅ **CORS Support** - دعم تطبيقات الموبايل
- ✅ **Session Management** - إدارة الجلسات
- ✅ **Data Validation** - التحقق من البيانات
- ✅ **Error Handling** - معالجة الأخطاء
- ✅ **Admin Panel** - لوحة تحكم شاملة

### Admin Panel
- ✅ **Bootstrap 5** - تصميم متجاوب
- ✅ **Arabic RTL** - واجهة عربية كاملة
- ✅ **Real-time Updates** - تحديثات فورية
- ✅ **Advanced Search** - بحث متقدم
- ✅ **Data Export** - تصدير البيانات
- ✅ **User Management** - إدارة المستخدمين

## 🔧 التكوين

### متغيرات البيئة
```bash
# API Base URL
API_BASE_URL=http://free-styel.store/api

# Admin Panel
ADMIN_EMAIL=mo.askary@gmail.com
ADMIN_PASSWORD=askary20

# Google Maps API
GOOGLE_MAPS_API_KEY=AIzaSyAYx3NYuaW2KfRt28bdfC-g37i9B-6rVgA
```

### إعدادات قاعدة البيانات
```php
// في ملفات PHP
$host = 'localhost';
$dbname = 'wedoo_db';
$username = 'root';
$password = '';
```

## 📱 الصفحات الرئيسية

### 1. تسجيل الدخول
- مصادقة آمنة
- حفظ الجلسة
- إعادة تعيين كلمة المرور

### 2. الشاشة الرئيسية
- تصفح الخدمات
- البحث السريع
- الإشعارات
- الملف الشخصي

### 3. طلب الخدمة
- اختيار نوع الخدمة
- وصف المشكلة
- تحديد الموقع
- رفع الصور
- اختيار الصانيع

### 4. المحلات والمعارض
- تصفح المحلات
- عرض التفاصيل
- التقييمات
- الموقع والاتصال

### 5. الإعدادات
- الملف الشخصي
- الإشعارات
- البرومو كود
- المحادثات
- اتصل بنا

## 🔐 الأمان

### تطبيق الموبايل
- ✅ **HTTPS** - تشفير البيانات
- ✅ **Token Authentication** - مصادقة بالرموز
- ✅ **Input Validation** - التحقق من المدخلات
- ✅ **Secure Storage** - تخزين آمن

### Backend
- ✅ **SQL Injection Protection** - حماية من SQL Injection
- ✅ **XSS Protection** - حماية من XSS
- ✅ **CSRF Protection** - حماية من CSRF
- ✅ **Session Security** - أمان الجلسات

## 📈 الإحصائيات

### المستخدمين
- العملاء المسجلين
- الصنايع المسجلين
- المحلات المسجلة
- الطلبات المكتملة

### الطلبات
- الطلبات الجديدة
- الطلبات قيد التنفيذ
- الطلبات المكتملة
- الطلبات الملغية

### التقييمات
- متوسط التقييمات
- عدد التقييمات
- التقييمات الموافق عليها
- التقييمات المرفوضة

## 🚀 التطوير المستقبلي

### المميزات المخططة
- [ ] **دفع إلكتروني** - دفع آمن عبر الإنترنت
- [ ] **تتبع GPS** - تتبع موقع الصانيع
- [ ] **دردشة صوتية** - مكالمات صوتية
- [ ] **تقييمات متقدمة** - تقييمات مفصلة
- [ ] **تقارير شاملة** - تقارير مفصلة
- [ ] **دعم متعدد اللغات** - دعم الفرنسية والإنجليزية

### التحسينات التقنية
- [ ] **قاعدة بيانات MySQL** - قاعدة بيانات حقيقية
- [ ] **Redis Cache** - تخزين مؤقت سريع
- [ ] **CDN** - شبكة توصيل المحتوى
- [ ] **Load Balancing** - توزيع الأحمال
- [ ] **Monitoring** - مراقبة الأداء

## 📞 الدعم والاتصال

### معلومات الاتصال
- **البريد الإلكتروني:** mo.askary@gmail.com
- **الموقع:** http://free-styel.store
- **GitHub:** [رابط المشروع]

### الدعم التقني
- **API Documentation:** http://free-styel.store/api/README.md
- **Admin Panel Guide:** http://free-styel.store/admin_panel/README.md
- **Flutter Documentation:** https://flutter.dev/docs

## 📄 الترخيص

هذا المشروع مرخص تحت رخصة MIT. راجع ملف LICENSE للتفاصيل.

## 🤝 المساهمة

نرحب بالمساهمات! يرجى قراءة دليل المساهمة قبل إرسال Pull Request.

---

**Wedoo** - ربط الصنايع بالعملاء في تونس 🇹🇳# wedoo_laravel
