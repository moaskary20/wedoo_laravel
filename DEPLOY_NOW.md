# 🚀 نشر فوري - حل مشكلة OPTIONS

## 📋 **المشكلة:**
السيرفر يقرأ JSON فقط (وهذا ممتاز للأمان)، لكن ملفات `auth/login.php` و `auth/register.php` لا تتعامل مع OPTIONS preflight requests.

## 🔧 **الحل الفوري:**

### **1. الاتصال بالسيرفر:**
```bash
ssh root@vmi2704354.contaboserver.net
```

### **2. الانتقال للمجلد:**
```bash
cd /var/www/wedoo_laravel/public/api
mkdir -p auth
```

### **3. نسخ احتياطي:**
```bash
cp auth/login.php auth/login.php.backup
cp auth/register.php auth/register.php.backup
```

### **4. رفع الملفات المحدثة:**
```bash
# من جهازك المحلي، نفذ:
scp auth-login-options-fixed.php root@vmi2704354.contaboserver.net:/var/www/wedoo_laravel/public/api/auth/login.php
scp auth-register-options-fixed.php root@vmi2704354.contaboserver.net:/var/www/wedoo_laravel/public/api/auth/register.php
```

### **5. تعيين الصلاحيات:**
```bash
chmod 644 /var/www/wedoo_laravel/public/api/auth/login.php
chmod 644 /var/www/wedoo_laravel/public/api/auth/register.php
```

### **6. اختبار فوري:**
```bash
curl -X OPTIONS "https://free-styel.store/api/auth/login.php" \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v
```

## ✅ **النتيجة المتوقعة:**
```json
{
  "status": "OK",
  "message": "CORS preflight successful",
  "method": "OPTIONS",
  "timestamp": 1761018000
}
```

## 🎯 **بعد النشر:**
التطبيق سيعمل بشكل مثالي مع السيرفر الخارجي! 🚀

---

## 📁 **الملفات المطلوبة:**
- ✅ `auth-login-options-fixed.php` - جاهز للنشر
- ✅ `auth-register-options-fixed.php` - جاهز للنشر

## 🎉 **النتيجة النهائية:**
بعد النشر، سيعمل التطبيق بشكل مثالي مع `https://free-styel.store/` بدون أي مشاكل CORS!
