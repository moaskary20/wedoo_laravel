<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>استعادة كلمة المرور - WeDoo</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            direction: rtl;
            text-align: right;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 600px;
            margin: 20px auto;
            background-color: #ffffff;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #ffffff;
            padding: 30px;
            text-align: center;
        }
        .header h1 {
            margin: 0;
            font-size: 28px;
            font-weight: bold;
        }
        .content {
            padding: 40px 30px;
        }
        .code-box {
            background-color: #f8f9fa;
            border: 2px dashed #667eea;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            margin: 30px 0;
        }
        .code {
            font-size: 36px;
            font-weight: bold;
            color: #667eea;
            letter-spacing: 8px;
            font-family: 'Courier New', monospace;
        }
        .message {
            color: #333333;
            font-size: 16px;
            line-height: 1.6;
            margin-bottom: 20px;
        }
        .warning {
            background-color: #fff3cd;
            border-right: 4px solid #ffc107;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
            color: #856404;
        }
        .footer {
            background-color: #f8f9fa;
            padding: 20px;
            text-align: center;
            color: #666666;
            font-size: 14px;
        }
        .button {
            display: inline-block;
            padding: 12px 30px;
            background-color: #667eea;
            color: #ffffff;
            text-decoration: none;
            border-radius: 5px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>WeDoo</h1>
            <p style="margin: 10px 0 0 0; font-size: 18px;">استعادة كلمة المرور</p>
        </div>
        
        <div class="content">
            <p class="message">
                مرحباً،
            </p>
            
            <p class="message">
                لقد تلقينا طلباً لاستعادة كلمة المرور لحسابك في WeDoo. استخدم الرمز التالي لإعادة تعيين كلمة المرور:
            </p>
            
            <div class="code-box">
                <div class="code">{{ $code }}</div>
            </div>
            
            <div class="warning">
                <strong>⚠️ تنبيه:</strong> هذا الرمز صالح لمدة 15 دقيقة فقط. إذا لم تطلب استعادة كلمة المرور، يرجى تجاهل هذا الإيميل.
            </div>
            
            <p class="message">
                إذا لم تطلب هذا الرمز، يمكنك تجاهل هذا الإيميل بأمان. كلمة المرور الخاصة بك لن تتغير.
            </p>
        </div>
        
        <div class="footer">
            <p>© {{ date('Y') }} WeDoo. جميع الحقوق محفوظة.</p>
            <p style="margin-top: 10px; font-size: 12px; color: #999999;">
                هذا إيميل تلقائي، يرجى عدم الرد عليه.
            </p>
        </div>
    </div>
</body>
</html>

