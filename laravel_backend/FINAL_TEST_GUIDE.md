# 🧪 دليل الاختبار النهائي - بعد النشر

## 📋 **قائمة الاختبارات المطلوبة:**

### **1. اختبار OPTIONS Preflight:**
```bash
curl -X OPTIONS "https://free-styel.store/api/auth/login.php" \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v
```

**النتيجة المتوقعة:**
```json
{
  "status": "OK",
  "message": "CORS preflight successful",
  "method": "OPTIONS",
  "timestamp": 1761018000
}
```

### **2. اختبار تسجيل الدخول:**
```bash
curl -X POST "https://free-styel.store/api/auth/login.php" \
  -H "Content-Type: application/json" \
  -d '{"phone":"01000690805","password":"askary20"}' \
  -v
```

**النتيجة المتوقعة:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "مستخدم تجريبي",
    "phone": "01000690805",
    "email": "demo@example.com",
    "user_type": "customer",
    "governorate": "تونس",
    "city": "تونس العاصمة",
    "district": "المركز",
    "membership_code": "558206",
    "status": "active",
    "access_token": "token_...",
    "refresh_token": "refresh_...",
    "login_time": "2025-10-21 03:40:00"
  },
  "message": "Login successful",
  "timestamp": 1761018000
}
```

### **3. اختبار التسجيل:**
```bash
curl -X POST "https://free-styel.store/api/auth/register.php" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","phone":"01234567890","email":"test@example.com","password":"password123","user_type":"customer","governorate":"تونس","city":"تونس العاصمة","district":"المركز"}' \
  -v
```

**النتيجة المتوقعة:**
```json
{
  "success": true,
  "data": {
    "id": 1234,
    "name": "Test User",
    "phone": "01234567890",
    "email": "test@example.com",
    "user_type": "customer",
    "governorate": "تونس",
    "city": "تونس العاصمة",
    "district": "المركز",
    "membership_code": "WED123456",
    "access_token": "token_...",
    "refresh_token": "refresh_...",
    "created_at": "2025-10-21 03:40:00",
    "status": "active"
  },
  "message": "User registered successfully",
  "timestamp": 1761018000
}
```

### **4. اختبار عدد الصنايعية:**
```bash
curl -X GET "https://free-styel.store/api/craftsman/count.php?category_id=5" -v
```

**النتيجة المتوقعة:**
```json
{
  "success": true,
  "data": {
    "category_id": 5,
    "count": 20
  },
  "message": "Craftsman count retrieved successfully"
}
```

### **5. اختبار أنواع المهام:**
```bash
curl -X GET "https://free-styel.store/api/task-types/index.php?category_id=3" -v
```

**النتيجة المتوقعة:**
```json
{
  "success": true,
  "data": [
    {
      "id": 6,
      "name": "نقل أثاث",
      "name_en": "Furniture Moving",
      "category_id": 3,
      "category_name": "النقل والخدمات اللوجستية",
      "description": "نقل الأثاث والممتلكات",
      "icon": "fas fa-truck",
      "color": "#fff3e0",
      "price_range": "100-300 دينار تونسي",
      "duration": "2-4 ساعات",
      "difficulty": "medium",
      "status": "active",
      "created_at": "2024-01-06",
      "image": "https://via.placeholder.com/300x200/fff3e0/000000?text=نقل+أثاث"
    },
    {
      "id": 7,
      "name": "نقل سريع",
      "name_en": "Express Delivery",
      "category_id": 3,
      "category_name": "النقل والخدمات اللوجستية",
      "description": "نقل سريع للطرود والوثائق",
      "icon": "fas fa-shipping-fast",
      "color": "#e8f5e8",
      "price_range": "20-50 دينار تونسي",
      "duration": "30-60 دقيقة",
      "difficulty": "easy",
      "status": "active",
      "created_at": "2024-01-07",
      "image": "https://via.placeholder.com/300x200/e8f5e8/000000?text=نقل+سريع"
    },
    {
      "id": 8,
      "name": "نقل طويل المدى",
      "name_en": "Long Distance Moving",
      "category_id": 3,
      "category_name": "النقل والخدمات اللوجستية",
      "description": "نقل لمسافات طويلة",
      "icon": "fas fa-route",
      "color": "#f3e5f5",
      "price_range": "200-500 دينار تونسي",
      "duration": "4-8 ساعات",
      "difficulty": "hard",
      "status": "active",
      "created_at": "2024-01-08",
      "image": "https://via.placeholder.com/300x200/f3e5f5/000000?text=نقل+طويل"
    }
  ],
  "message": "Task types retrieved successfully"
}
```

---

## 🎯 **اختبار التطبيق:**

### **1. تشغيل التطبيق:**
```bash
cd /media/mohamed/3E16609616605147/wedoo2/handyman_app
flutter run -d chrome
```

### **2. اختبار تسجيل الدخول:**
- فتح التطبيق
- الانتقال لشاشة تسجيل الدخول
- إدخال البيانات: `01000690805` / `askary20`
- النقر على "تسجيل الدخول"
- **النتيجة المتوقعة:** نجاح تسجيل الدخول والانتقال للشاشة التالية

### **3. اختبار التسجيل:**
- الانتقال لشاشة التسجيل
- ملء جميع البيانات المطلوبة
- النقر على "إنشاء حساب"
- **النتيجة المتوقعة:** نجاح التسجيل والانتقال لشاشة تسجيل الدخول

### **4. اختبار أنواع المهام:**
- الانتقال لشاشة الفئات
- اختيار "النقل والخدمات اللوجستية"
- **النتيجة المتوقعة:** ظهور 3 أنواع مهام (نقل أثاث، نقل سريع، نقل طويل المدى)

---

## ✅ **علامات النجاح:**

1. **لا توجد أخطاء CORS في console**
2. **تسجيل الدخول يعمل بنجاح**
3. **التسجيل يعمل بنجاح**
4. **أنواع المهام تظهر بشكل صحيح**
5. **عدد الصنايعية يظهر بشكل صحيح**

---

## 🔧 **في حالة الفشل:**

### **1. التحقق من الملفات:**
```bash
ls -la /var/www/wedoo_laravel/public/api/auth/
```

### **2. مراجعة سجلات الأخطاء:**
```bash
tail -f /var/log/apache2/error.log
```

### **3. اختبار الاتصال:**
```bash
ping free-styel.store
```

### **4. إعادة النشر:**
```bash
# نسخ الملفات مرة أخرى
scp auth-login-options-fixed.php root@vmi2704354.contaboserver.net:/var/www/wedoo_laravel/public/api/auth/login.php
scp auth-register-options-fixed.php root@vmi2704354.contaboserver.net:/var/www/wedoo_laravel/public/api/auth/register.php
```

---

## 🎉 **النتيجة النهائية:**

بعد النشر الناجح والاختبار، سيعمل التطبيق بشكل مثالي مع السيرفر الخارجي `https://free-styel.store/` بدون أي مشاكل! 🚀
