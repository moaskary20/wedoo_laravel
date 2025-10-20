import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatefulWidget {
  const TermsOfUseScreen({super.key});

  @override
  State<TermsOfUseScreen> createState() => _TermsOfUseScreenState();
}

class _TermsOfUseScreenState extends State<TermsOfUseScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFfec901),
        appBar: AppBar(
          title: const Text(
            'سياسة الاستخدام',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.blue,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Terms content
                  _buildTermsContent(),
                  
                  const SizedBox(height: 100), // Space for floating button
                ],
              ),
            ),
            
            // Floating Help Button
            Positioned(
              left: 20,
              top: 100,
              child: _buildFloatingHelpButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Center(
            child: Text(
              'شروط وأحكام استخدام التطبيق',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 20),
          
          const Text(
            'آخر تحديث: ديسمبر 2024',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 30),
          
          // Section 1
          _buildSection(
            '1. قبول الشروط',
            'باستخدامك لهذا التطبيق، فإنك توافق على الالتزام بشروط وأحكام الاستخدام هذه. إذا كنت لا توافق على هذه الشروط، يرجى عدم استخدام التطبيق.',
          ),
          
          // Section 2
          _buildSection(
            '2. وصف الخدمة',
            'تطبيق "الصنايع" هو منصة رقمية تربط بين العملاء والحرفيين المهرة لتقديم خدمات الصيانة والإصلاح. نهدف إلى تسهيل عملية العثور على الحرفيين المناسبين وتقديم خدمات عالية الجودة.',
          ),
          
          // Section 3
          _buildSection(
            '3. التسجيل والحساب',
            '• يجب أن تكون 18 عاماً أو أكثر لاستخدام التطبيق\n• يجب تقديم معلومات صحيحة ودقيقة عند التسجيل\n• أنت مسؤول عن الحفاظ على سرية حسابك وكلمة المرور\n• يجب إبلاغنا فوراً عن أي استخدام غير مصرح به لحسابك',
          ),
          
          // Section 4
          _buildSection(
            '4. استخدام التطبيق',
            '• يمكنك استخدام التطبيق للأغراض القانونية فقط\n• لا يجوز استخدام التطبيق لأي نشاط غير قانوني أو ضار\n• يجب احترام حقوق الملكية الفكرية\n• لا يجوز محاولة اختراق أو تعطيل التطبيق',
          ),
          
          // Section 5
          _buildSection(
            '5. الخدمات والمدفوعات',
            '• الأسعار المعروضة في التطبيق قد تتغير دون إشعار مسبق\n• المدفوعات تتم عبر طرق آمنة ومعتمدة\n• يمكن إلغاء الطلبات وفقاً للشروط المحددة\n• نحتفظ بالحق في رفض أو إلغاء أي طلب',
          ),
          
          // Section 6
          _buildSection(
            '6. خصوصية البيانات',
            '• نحن نلتزم بحماية خصوصيتك وبياناتك الشخصية\n• يتم جمع البيانات الضرورية فقط لتقديم الخدمة\n• لا نشارك بياناتك الشخصية مع أطراف ثالثة دون موافقتك\n• يمكنك مراجعة سياسة الخصوصية للحصول على تفاصيل أكثر',
          ),
          
          // Section 7
          _buildSection(
            '7. مسؤولية المستخدم',
            '• أنت مسؤول عن دقة المعلومات المقدمة\n• يجب التعامل مع الحرفيين باحترام ومهنية\n• لا يجوز إساءة استخدام النظام أو التلاعب به\n• يجب الإبلاغ عن أي مشاكل أو انتهاكات',
          ),
          
          // Section 8
          _buildSection(
            '8. مسؤولية التطبيق',
            '• نحن نسعى لتقديم أفضل الخدمات الممكنة\n• لا نتحمل مسؤولية الأضرار الناتجة عن استخدام التطبيق\n• نحتفظ بالحق في تعديل أو إيقاف الخدمة\n• نعمل على حل النزاعات بطريقة عادلة',
          ),
          
          // Section 9
          _buildSection(
            '9. تعديل الشروط',
            'نحتفظ بالحق في تعديل هذه الشروط في أي وقت. سيتم إشعار المستخدمين بأي تغييرات مهمة. استمرار استخدام التطبيق بعد التعديلات يعني الموافقة على الشروط الجديدة.',
          ),
          
          // Section 10
          _buildSection(
            '10. إنهاء الخدمة',
            'يمكن لأي من الطرفين إنهاء هذه الاتفاقية في أي وقت. نحتفظ بالحق في تعليق أو إنهاء حسابك في حالة انتهاك هذه الشروط.',
          ),
          
          // Section 11
          _buildSection(
            '11. القانون المطبق',
            'تخضع هذه الشروط للقوانين المحلية. أي نزاعات ستتم تسويتها من خلال المحاكم المختصة.',
          ),
          
          // Section 12
          _buildSection(
            '12. التواصل معنا',
            'لأي استفسارات أو شكاوى، يمكنك التواصل معنا عبر:\n• البريد الإلكتروني: support@handyman.com\n• الهاتف: 01234567890\n• العنوان: القاهرة، مصر',
          ),
          
          const SizedBox(height: 30),
          
          // Agreement checkbox
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFffe480),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[300]!),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'باستخدامك لهذا التطبيق، فإنك تؤكد أنك قد قرأت وفهمت هذه الشروط والأحكام ووافقت عليها.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingHelpButton() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('مساعدة'),
            backgroundColor: Colors.green,
          ),
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.help_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(height: 2),
            const Text(
              'مساعدة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
