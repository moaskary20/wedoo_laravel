import 'package:flutter/material.dart';

class AppExplanationScreen extends StatefulWidget {
  const AppExplanationScreen({super.key});

  @override
  State<AppExplanationScreen> createState() => _AppExplanationScreenState();
}

class _AppExplanationScreenState extends State<AppExplanationScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFfec901),
        appBar: AppBar(
          title: const Text(
            'شرح التطبيق',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.blue,
          elevation: 0,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // First Card - How to create a request
                  _buildExplanationCard(
                    'طريقة انشاء طلب',
                    'تعلم كيفية إنشاء طلب خدمة بسهولة',
                    Icons.build,
                    Colors.blue,
                    () => _showCreateRequestTutorial(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Second Card - How to choose the right craftsman
                  _buildExplanationCard(
                    'كيف تختار الصنايعي المناسب',
                    'نصائح لاختيار أفضل حرفي لخدمتك',
                    Icons.person_search,
                    Colors.green,
                    () => _showCraftsmanSelectionTutorial(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Additional explanation cards
                  _buildExplanationCard(
                    'كيفية التواصل مع الحرفي',
                    'طرق التواصل والتفاوض على الأسعار',
                    Icons.chat,
                    Colors.orange,
                    () => _showCommunicationTutorial(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildExplanationCard(
                    'تقييم الخدمة',
                    'كيفية تقييم جودة الخدمة المقدمة',
                    Icons.star,
                    Colors.purple,
                    () => _showRatingTutorial(),
                  ),
                  
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

  Widget _buildExplanationCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFffe480),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow icon
            Icon(
              Icons.arrow_back_ios,
              color: Colors.grey[600],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateRequestTutorial() {
    _showTutorialDialog(
      'طريقة انشاء طلب',
      [
        '1. اختر نوع الخدمة المطلوبة من القائمة',
        '2. املأ تفاصيل الطلب والموقع',
        '3. حدد الميزانية المتوقعة',
        '4. أرفق الصور إذا لزم الأمر',
        '5. اضغط على "إرسال الطلب"',
        '6. انتظر رد الحرفيين على طلبك',
      ],
    );
  }

  void _showCraftsmanSelectionTutorial() {
    _showTutorialDialog(
      'كيف تختار الصنايعي المناسب',
      [
        '1. راجع تقييمات الحرفيين السابقة',
        '2. قارن الأسعار المقدمة',
        '3. تحقق من خبرة الحرفي في المجال',
        '4. اقرأ التعليقات والمراجعات',
        '5. تأكد من توفر الحرفي في الوقت المطلوب',
        '6. تواصل مع الحرفي قبل التعاقد',
      ],
    );
  }

  void _showCommunicationTutorial() {
    _showTutorialDialog(
      'كيفية التواصل مع الحرفي',
      [
        '1. استخدم نظام الرسائل في التطبيق',
        '2. حدد موعد مناسب للزيارة',
        '3. ناقش تفاصيل العمل والأسعار',
        '4. تأكد من شروط الضمان',
        '5. احتفظ بسجل المحادثات',
        '6. استخدم التقييم بعد انتهاء العمل',
      ],
    );
  }

  void _showRatingTutorial() {
    _showTutorialDialog(
      'تقييم الخدمة',
      [
        '1. قيم جودة العمل المنجز',
        '2. قيم التزام الحرفي بالمواعيد',
        '3. قيم التعامل والاحترافية',
        '4. اكتب تعليق مفصل عن التجربة',
        '5. ارفق صور للعمل المنجز',
        '6. ساعد الآخرين بمراجعتك',
      ],
    );
  }

  void _showTutorialDialog(String title, List<String> steps) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: steps.map((step) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFFfec901),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '•',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'إغلاق',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
              Icons.message,
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
