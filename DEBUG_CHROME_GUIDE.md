# 🔍 دليل مراقبة الأخطاء - Chrome

## ✅ **الوضع الحالي:**

### **1. Laravel Server:**
- ✅ يعمل على: `http://127.0.0.1:8000`
- ✅ API يعمل بشكل صحيح
- ✅ تسجيل الدخول يعمل

### **2. Flutter App على Chrome:**
- ✅ يعمل على: `http://localhost:3000` (أو رقم port آخر)
- ✅ يمكن مراقبة الأخطاء في Developer Tools

---

## 🚀 **كيفية مراقبة الأخطاء:**

### **1. افتح التطبيق في Chrome:**
```
افتح المتصفح وانتقل إلى: http://localhost:3000
(أو الرقم الذي يظهر في Terminal)
```

### **2. افتح Developer Tools:**
```
اضغط F12 أو Ctrl+Shift+I
انتقل إلى تبويب "Console"
```

### **3. راقب الأخطاء:**
```
ستظهر جميع الأخطاء في Console
ابحث عن أخطاء "Failed to fetch" أو "Connection error"
```

### **4. راقب Network Tab:**
```
انتقل إلى تبويب "Network"
جرب تسجيل الدخول
راقب طلبات API
```

---

## 🔧 **خطوات التشخيص:**

### **الخطوة 1: التحقق من Laravel**
```bash
# اختبار API
curl -s "http://localhost:8000/api/auth/login" -X POST -H "Content-Type: application/json" -d '{"email":"mo.askary@gmail.com","password":"askary20"}' | jq '.success'

# يجب أن يعطي: true
```

### **الخطوة 2: التحقق من التطبيق**
```bash
# التحقق من أن التطبيق يعمل
ps aux | grep "flutter run" | grep -v grep

# يجب أن يظهر عملية flutter run
```

### **الخطوة 3: مراقبة الأخطاء في Chrome**
```
1. افتح http://localhost:3000
2. اضغط F12
3. انتقل إلى Console
4. جرب تسجيل الدخول
5. راقب الأخطاء
```

---

## 🚨 **الأخطاء الشائعة:**

### **1. خطأ "Failed to fetch":**
```
السبب: Laravel server لا يعمل
الحل: cd wedoo_admin_panel && php artisan serve --host=127.0.0.1 --port=8000
```

### **2. خطأ "Connection refused":**
```
السبب: Laravel server لا يعمل على localhost
الحل: تأكد من أن Laravel يعمل على 127.0.0.1:8000
```

### **3. خطأ "CORS":**
```
السبب: مشكلة في CORS settings
الحل: تم إصلاحها في config/cors.php
```

### **4. خطأ "404 Not Found":**
```
السبب: API route غير موجود
الحل: تأكد من أن routes/api.php يحتوي على المسار
```

---

## 📱 **كيفية الاستخدام:**

### **1. افتح التطبيق:**
```
افتح المتصفح وانتقل إلى: http://localhost:3000
```

### **2. سجل الدخول:**
```
البريد الإلكتروني: mo.askary@gmail.com
كلمة المرور: askary20
```

### **3. راقب الأخطاء:**
```
اضغط F12 → Console
راقب الأخطاء أثناء تسجيل الدخول
```

---

## 🎯 **الحلول السريعة:**

### **إذا كان Laravel لا يعمل:**
```bash
cd wedoo_admin_panel && php artisan serve --host=127.0.0.1 --port=8000
```

### **إذا كان التطبيق لا يعمل:**
```bash
cd handyman_app && flutter run -d chrome
```

### **إذا كان API لا يعمل:**
```bash
curl -s "http://localhost:8000/api/auth/login" -X POST -H "Content-Type: application/json" -d '{"email":"mo.askary@gmail.com","password":"askary20"}' | jq '.success'
```

---

## 🎉 **النتيجة المتوقعة:**

**التطبيق يجب أن يعمل على Chrome بدون أخطاء!**

- ✅ **Laravel server يعمل** على localhost:8000
- ✅ **التطبيق يعمل** على Chrome
- ✅ **تسجيل الدخول يعمل** بدون أخطاء
- ✅ **جميع الميزات تعمل** بشكل مثالي

**راقب الأخطاء في Developer Tools!** 🔍
