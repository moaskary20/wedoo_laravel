# 🔧 دليل حل مشاكل الاتصال

## 🚨 **المشكلة الحالية:**
التطبيق المحمول يظهر خطأ "خطأ في الاتصال بالخادم" عند تسجيل الدخول.

## ✅ **الحلول المطبقة:**

### **1. تحديث إعدادات API:**
- ✅ تم تحديث `handyman_app/lib/config/api_config.dart`
- ✅ تم تغيير `baseUrl` من `https://free-styel.store` إلى `http://localhost:8000`
- ✅ تم تحديث جميع API endpoints

### **2. إعداد Laravel Backend:**
- ✅ تم تثبيت Laravel Sanctum للمصادقة
- ✅ تم تكوين CORS للسماح بالاتصال من `localhost:3000`
- ✅ تم إنشاء المستخدم المطلوب: `mo.askary@gmail.com` / `askary20`

### **3. اختبار النظام:**
- ✅ Laravel server يعمل على `http://localhost:8000`
- ✅ Flutter يعمل على `http://localhost:3000`
- ✅ API يعمل بشكل مثالي

## 🔍 **خطوات التشخيص:**

### **1. تحقق من حالة الخوادم:**
```bash
# تحقق من Laravel server
ss -tlnp | grep :8000

# تحقق من Flutter
ss -tlnp | grep :3000
```

### **2. اختبار API:**
```bash
# اختبار تسجيل الدخول
curl -s "http://localhost:8000/api/auth/login" -X POST -H "Content-Type: application/json" -d '{"email":"mo.askary@gmail.com","password":"askary20"}' | jq '.success'
```

### **3. اختبار Flutter:**
```bash
# تحقق من أن Flutter يعمل
curl -s "http://localhost:3000" | head -5
```

## 🛠️ **الحلول المقترحة:**

### **الحل 1: إعادة تشغيل Flutter**
```bash
# إيقاف Flutter
pkill -f "flutter run"

# تنظيف Flutter
cd handyman_app && flutter clean

# إعادة تشغيل Flutter
flutter run -d chrome --web-port=3000
```

### **الحل 2: تحقق من إعدادات CORS**
```bash
# تحقق من إعدادات CORS
cat wedoo_admin_panel/config/cors.php
```

### **الحل 3: اختبار API مباشرة**
```bash
# اختبار API مع Origin header
curl -s "http://localhost:8000/api/auth/login" -X POST -H "Content-Type: application/json" -H "Origin: http://localhost:3000" -d '{"email":"mo.askary@gmail.com","password":"askary20"}'
```

## 📱 **كيفية الاستخدام:**

### **1. التطبيق المحمول:**
```
افتح المتصفح وانتقل إلى: http://localhost:3000
سجل الدخول بـ: mo.askary@gmail.com / askary20
```

### **2. Admin Panel:**
```
افتح المتصفح وانتقل إلى: http://localhost:8000/admin/login
سجل الدخول بـ: admin@wedoo.com / admin123
```

## 🎯 **النتيجة المتوقعة:**

بعد تطبيق الحلول، يجب أن يعمل التطبيق المحمول بشكل مثالي مع:
- ✅ تسجيل الدخول يعمل
- ✅ عرض البيانات من Laravel Backend
- ✅ عدم وجود أخطاء اتصال

## 🚨 **إذا استمرت المشكلة:**

1. **تحقق من Console في المتصفح** (F12) لرؤية الأخطاء
2. **تحقق من Network tab** لرؤية طلبات API
3. **تأكد من أن Laravel server يعمل** على المنفذ 8000
4. **تأكد من أن Flutter يعمل** على المنفذ 3000

**النظام جاهز للعمل!** 🚀
