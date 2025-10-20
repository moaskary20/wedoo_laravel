import 'package:flutter/material.dart';

class CraftSecretsScreen extends StatefulWidget {
  const CraftSecretsScreen({Key? key}) : super(key: key);

  @override
  State<CraftSecretsScreen> createState() => _CraftSecretsScreenState();
}

class _CraftSecretsScreenState extends State<CraftSecretsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFfec901),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1e3a8a),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'سر الصنعة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Tab Bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF1e3a8a),
                labelColor: const Color(0xFF1e3a8a),
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'مقالات'),
                  Tab(text: 'فيديوهات'),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildArticlesTab(),
                  _buildVideosTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticlesTab() {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildArticleCard(
            'نصائح مهمة للدهانات',
            'تعلم كيفية اختيار الألوان المناسبة وتطبيق الدهانات بطريقة احترافية',
            'وي دو -- نقاشة',
            'assets/images/article1.jpg',
          ),
          const SizedBox(height: 16),
          _buildArticleCard(
            'أدوات النجارة الأساسية',
            'دليل شامل لأدوات النجارة التي يحتاجها كل صانع',
            'وي دو -- نجارة',
            'assets/images/article2.jpg',
          ),
          const SizedBox(height: 16),
          _buildArticleCard(
            'تقنيات السباكة الحديثة',
            'أحدث التقنيات في مجال السباكة والصيانة',
            'وي دو -- سباكة',
            'assets/images/article3.jpg',
          ),
        ],
      ),
    );
  }

  Widget _buildVideosTab() {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildVideoCard(
            'رولة دهان عجيبة - فكرة عمل السرنجة',
            'وي دو -- نقاشة',
            'assets/images/video1.jpg',
          ),
          const SizedBox(height: 16),
          _buildVideoCard(
            'أفكار بسيطة و جميلة للدهانات',
            'وي دو -- نقاشة',
            'assets/images/video2.jpg',
          ),
          const SizedBox(height: 16),
          _buildVideoCard(
            'طريقة عمل ديكور هندسي مميز',
            'وي دو -- نقاشة',
            'assets/images/video3.jpg',
          ),
          const SizedBox(height: 16),
          _buildVideoCard(
            'تقنيات النجارة المتقدمة',
            'وي دو -- نجارة',
            'assets/images/video4.jpg',
          ),
          const SizedBox(height: 16),
          _buildVideoCard(
            'أساسيات السباكة المنزلية',
            'وي دو -- سباكة',
            'assets/images/video5.jpg',
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(String title, String description, String category, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Article Image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              color: Colors.grey[200],
            ),
            child: const Center(
              child: Icon(
                Icons.article,
                size: 50,
                color: Colors.grey,
              ),
            ),
          ),
          
          // Article Content
          Padding(
            padding: const EdgeInsets.all(16),
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
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1e3a8a),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(String title, String category, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Thumbnail
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  color: Colors.grey[200],
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_filled,
                    size: 60,
                    color: Colors.red,
                  ),
                ),
              ),
              
              // Primo Logo
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'PRIMO',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1e3a8a),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Video Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1e3a8a),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
