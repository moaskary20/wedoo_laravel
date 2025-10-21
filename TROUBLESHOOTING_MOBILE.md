# 🔧 دليل استكشاف الأخطاء - التطبيق المحمول

## ✅ **الوضع الحالي:**

### **1. Laravel Server:**
- ✅ يعمل على: `http://127.0.0.1:8000`
- ✅ API يعمل بشكل صحيح
- ✅ تسجيل الدخول يعمل

### **2. المحاكي:**
- ✅ يعمل على: `emulator-5554`
- ✅ متصل ويعمل

### **3. التطبيق:**
- ✅ يعمل على المحاكي
- ✅ متصل بـ Laravel Backend

---

## 🚨 **إذا واجهت مشاكل:**

### **1. خطأ "No supported devices found":**
```bash
# إعادة تشغيل المحاكي
flutter emulators --launch Medium_Phone_API_36.0

# انتظار 30 ثانية ثم التحقق
sleep 30 && flutter devices
```

### **2. خطأ "Connection error":**
```bash
# التحقق من Laravel server
ps aux | grep "php artisan serve" | grep -v grep

# إذا لم يعمل، شغله
cd wedoo_admin_panel && php artisan serve --host=127.0.0.1 --port=8000
```

### **3. خطأ "Failed to fetch":**
```bash
# اختبار API
curl -s "http://localhost:8000/api/auth/login" -X POST -H "Content-Type: application/json" -d '{"email":"mo.askary@gmail.com","password":"askary20"}' | jq '.success'

# يجب أن يعطي: true
```

### **4. التطبيق لا يظهر على المحاكي:**
```bash
# إعادة تشغيل التطبيق
cd handyman_app && flutter run -d emulator-5554
```

---

## 🔍 **خطوات التشخيص:**

### **الخطوة 1: التحقق من المحاكي**
```bash
flutter devices
# يجب أن يظهر: sdk gphone64 x86 64 (mobile) • emulator-5554
```

### **الخطوة 2: التحقق من Laravel**
```bash
curl -s "http://localhost:8000/api/auth/login" -X POST -H "Content-Type: application/json" -d '{"email":"mo.askary@gmail.com","password":"askary20"}' | jq '.success'
# يجب أن يعطي: true
```

### **الخطوة 3: التحقق من التطبيق**
```bash
ps aux | grep "flutter run" | grep -v grep
# يجب أن يظهر عملية flutter run
```

---

## 🎯 **الحلول السريعة:**

### **إذا كان المحاكي لا يعمل:**
```bash
# إعادة تشغيل المحاكي
flutter emulators --launch Medium_Phone_API_36.0
```

### **إذا كان Laravel لا يعمل:**
```bash
# إعادة تشغيل Laravel
cd wedoo_admin_panel && php artisan serve --host=127.0.0.1 --port=8000
```

### **إذا كان التطبيق لا يعمل:**
```bash
# إعادة تشغيل التطبيق
cd handyman_app && flutter run -d emulator-5554
```

---

## 📱 **كيفية الاستخدام:**

### **1. افتح المحاكي:**
- يجب أن ترى نافذة المحاكي
- التطبيق يجب أن يظهر تلقائياً

### **2. سجل الدخول:**
```
البريد الإلكتروني: mo.askary@gmail.com
كلمة المرور: askary20
```

### **3. إذا لم يعمل:**
- تأكد من أن المحاكي يعمل
- تأكد من أن Laravel server يعمل
- أعد تشغيل التطبيق

---

## 🎉 **النتيجة المتوقعة:**

**التطبيق يجب أن يعمل على المحاكي بدون أخطاء!**

- ✅ **المحاكي يعمل** ويظهر التطبيق
- ✅ **تسجيل الدخول يعمل** بدون أخطاء
- ✅ **البيانات تظهر** من Laravel Backend
- ✅ **جميع الميزات تعمل** بشكل مثالي

**إذا استمرت المشكلة، جرب الحلول أعلاه!** 🔧
