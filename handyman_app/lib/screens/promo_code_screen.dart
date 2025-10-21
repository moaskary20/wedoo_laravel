import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class PromoCodeScreen extends StatefulWidget {
  const PromoCodeScreen({super.key});

  @override
  State<PromoCodeScreen> createState() => _PromoCodeScreenState();
}

class _PromoCodeScreenState extends State<PromoCodeScreen> {
  final TextEditingController _promoCodeController = TextEditingController();
  String _membershipCode = '558206';
  int _affiliatedFriends = 5;
  bool _isLoading = false;
  
  // Backend configuration - Using ApiConfig

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  Future<void> _confirmPromoCode() async {
    if (_promoCodeController.text.trim().isEmpty) {
      _showErrorSnackBar('يرجى إدخال كود البرومو');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // For development - simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate confirming promo code in admin panel
      print('Confirming promo code: ${_promoCodeController.text} in admin panel');
      
      // TODO: Uncomment when backend is ready
      /*
      // Real API call to confirm promo code
      final response = await http.post(
        Uri.parse('$_baseUrl$_promoCodeEndpoint/confirm'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await _getUserToken()}',
        },
        body: jsonEncode({
          'promo_code': _promoCodeController.text.trim(),
          'user_id': await _getUserId(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _showSuccessSnackBar('تم تأكيد الكود: ${_promoCodeController.text}');
          _promoCodeController.clear();
        } else {
          _showErrorSnackBar(data['message'] ?? 'كود البرومو غير صحيح');
        }
      } else {
        _showErrorSnackBar('خطأ في تأكيد كود البرومو');
      }
      */

      // Simulate checking if promo code exists
      String enteredCode = _promoCodeController.text.trim();
      
      // Simulate valid promo codes (in real app, this would come from backend)
      List<String> validPromoCodes = ['PROMO123', 'DISCOUNT50', 'WELCOME20', 'SAVE10'];
      
      if (validPromoCodes.contains(enteredCode)) {
        _showSuccessSnackBar('تم قبول الكود');
        _promoCodeController.clear();
      } else {
        _showErrorSnackBar('لا يوجد هذا الكود');
      }

    } catch (e) {
      _showErrorSnackBar('خطأ في تأكيد كود البرومو');
      print('Error confirming promo code: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _copyMembershipCode() async {
    try {
      // Copy to clipboard
      Clipboard.setData(ClipboardData(text: _membershipCode));
      
      // Log sharing activity in admin panel
      print('User shared membership code: $_membershipCode in admin panel');
      
      // TODO: Uncomment when backend is ready
      /*
      // Real API call to log sharing activity
      final response = await http.post(
        Uri.parse('$_baseUrl$_membershipCodeEndpoint/share'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await _getUserToken()}',
        },
        body: jsonEncode({
          'membership_code': _membershipCode,
          'user_id': await _getUserId(),
          'action': 'share',
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _showSuccessSnackBar('تم نسخ كود العضوية');
        }
      }
      */

      _showSuccessSnackBar('تم نسخ كود العضوية');

    } catch (e) {
      _showErrorSnackBar('خطأ في نسخ كود العضوية');
      print('Error copying membership code: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFfec901),
        appBar: AppBar(
          title: const Text(
            'البرومو كود',
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
                  
                  // Promo Code Input Section
                  _buildPromoCodeSection(),
                  
                  const SizedBox(height: 40),
                  
                  // Membership Code Section
                  _buildMembershipCodeSection(),
                  
                  const SizedBox(height: 100), // Space for floating button
                ],
              ),
            ),
            
            // Floating Help Button
            Positioned(
              left: 20,
              top: 200,
              child: _buildFloatingHelpButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'هل لديك برومو كود ؟',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 20),
        
        Row(
          children: [
            // Promo Code Input Field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFffe480),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _promoCodeController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'أدخل البرومو كود',
                    hintStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.content_copy, color: Colors.grey),
                      onPressed: () {
                        // Paste functionality
                        Clipboard.getData('text/plain').then((data) {
                          if (data != null && data.text != null) {
                            _promoCodeController.text = data.text!;
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Confirm Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: _isLoading ? null : _confirmPromoCode,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'تأكيد',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMembershipCodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'كود العضوية الخاص بك هو',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 15),
        
        // Membership Code Display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFffe480),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _membershipCode,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.content_copy, color: Colors.grey),
                onPressed: _copyMembershipCode,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Share Instruction
        const Text(
          'شاركه مع الاصدقاء لتستفيدوا جميعاً بهدايا وي دو',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Affiliated Friends Count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الاصدقاء المنتسبين لي .. ( $_affiliatedFriends )',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.blue),
                onPressed: _shareMembershipCode,
              ),
            ],
          ),
        ),
      ],
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
              Icons.share,
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

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // For development - simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate loading user data from admin panel
      print('Loading user membership code and affiliate stats from admin panel');
      
      // TODO: Uncomment when backend is ready
      /*
      // Real API call to get user membership code
      final membershipResponse = await http.get(
        Uri.parse('$_baseUrl$_membershipCodeEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await _getUserToken()}',
        },
      );

      if (membershipResponse.statusCode == 200) {
        final membershipData = jsonDecode(membershipResponse.body);
        if (membershipData['success'] == true) {
          setState(() {
            _membershipCode = membershipData['membership_code'] ?? '558206';
          });
        }
      }

      // Real API call to get affiliate stats
      final affiliateResponse = await http.get(
        Uri.parse('$_baseUrl$_affiliateStatsEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await _getUserToken()}',
        },
      );

      if (affiliateResponse.statusCode == 200) {
        final affiliateData = jsonDecode(affiliateResponse.body);
        if (affiliateData['success'] == true) {
          setState(() {
            _affiliatedFriends = affiliateData['affiliated_friends'] ?? 5;
          });
        }
      }
      */

    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _shareMembershipCode() async {
    try {
      // Log sharing activity in admin panel
      print('User shared membership code: $_membershipCode in admin panel');
      
      // TODO: Uncomment when backend is ready
      /*
      // Real API call to log sharing activity
      final response = await http.post(
        Uri.parse('$_baseUrl$_membershipCodeEndpoint/share'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await _getUserToken()}',
        },
        body: jsonEncode({
          'membership_code': _membershipCode,
          'user_id': await _getUserId(),
          'action': 'share',
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _showSuccessSnackBar('تم مشاركة كود العضوية');
        }
      }
      */

      _showSuccessSnackBar('تم مشاركة كود العضوية في الـ admin panel');

    } catch (e) {
      _showErrorSnackBar('خطأ في مشاركة كود العضوية');
      print('Error sharing membership code: $e');
    }
  }

  Future<void> _generateNewMembershipCode() async {
    try {
      // For development - simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate generating new membership code in admin panel
      print('Generating new membership code in admin panel');
      
      // TODO: Uncomment when backend is ready
      /*
      // Real API call to generate new membership code
      final response = await http.post(
        Uri.parse('$_baseUrl$_membershipCodeEndpoint/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await _getUserToken()}',
        },
        body: jsonEncode({
          'user_id': await _getUserId(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _membershipCode = data['new_membership_code'];
          });
          _showSuccessSnackBar('تم إنشاء كود عضوية جديد');
        }
      }
      */

      // Simulate generating new code
      setState(() {
        _membershipCode = '${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      });
      _showSuccessSnackBar('تم إنشاء كود عضوية جديد في الـ admin panel');

    } catch (e) {
      _showErrorSnackBar('خطأ في إنشاء كود عضوية جديد');
      print('Error generating new membership code: $e');
    }
  }

  Future<void> _viewAffiliateStats() async {
    try {
      // For development - simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate loading affiliate stats from admin panel
      print('Loading affiliate stats from admin panel');
      
      // TODO: Uncomment when backend is ready
      /*
      // Real API call to get affiliate stats
      final response = await http.get(
        Uri.parse('$_baseUrl$_affiliateStatsEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await _getUserToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Show detailed stats dialog
          _showAffiliateStatsDialog(data['stats']);
        }
      }
      */

      // Simulate showing stats
      _showAffiliateStatsDialog({
        'total_referrals': _affiliatedFriends,
        'active_referrals': 3,
        'total_earnings': 150.0,
        'pending_earnings': 50.0,
      });

    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل إحصائيات الإحالة');
      print('Error loading affiliate stats: $e');
    }
  }

  void _showAffiliateStatsDialog(Map<String, dynamic> stats) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('إحصائيات الإحالة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatRow('إجمالي الإحالات', '${stats['total_referrals']}'),
              _buildStatRow('الإحالات النشطة', '${stats['active_referrals']}'),
              _buildStatRow('إجمالي الأرباح', '${stats['total_earnings']} دينار'),
              _buildStatRow('الأرباح المعلقة', '${stats['pending_earnings']} دينار'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? '1';
  }

  Future<String> _getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
