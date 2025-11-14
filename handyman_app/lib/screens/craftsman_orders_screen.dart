import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:handyman_app/l10n/app_localizations.dart';

import '../config/api_config.dart';
import 'conversations_screen.dart';

class CraftsmanOrdersScreen extends StatefulWidget {
  const CraftsmanOrdersScreen({super.key});

  @override
  State<CraftsmanOrdersScreen> createState() => _CraftsmanOrdersScreenState();
}

class _CraftsmanOrdersScreenState extends State<CraftsmanOrdersScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<Map<String, String>?> _buildAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null || token.isEmpty) return null;
    final headers = Map<String, String>.from(ApiConfig.headers);
    headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final headers = await _buildAuthHeaders();
      if (headers == null) {
        setState(() {
          _errorMessage = 'يرجى تسجيل الدخول مرة أخرى';
          _isLoading = false;
        });
        return;
      }

      final response = await http
          .get(Uri.parse(ApiConfig.ordersAssigned), headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> raw = data['data'] ?? [];
          setState(() {
            _orders = raw
                .map<Map<String, dynamic>>(
                    (item) => Map<String, dynamic>.from(item))
                .toList();
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'فشل تحميل الطلبات';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'فشل تحميل الطلبات (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في الاتصال: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _respondToOrder(int orderId, bool accept) async {
    final headers = await _buildAuthHeaders();
    if (headers == null) {
      setState(() {
        _errorMessage = 'يرجى تسجيل الدخول مرة أخرى';
      });
      return;
    }

    final uri = Uri.parse(
      accept ? ApiConfig.orderAccept(orderId) : ApiConfig.orderReject(orderId),
    );

    try {
      final response =
          await http.post(uri, headers: headers).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        await _fetchOrders();
        if (accept && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.dataSavedSuccessfully,
              ),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'لم يتم تحديث الطلب (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ أثناء تحديث الطلب: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.myOrders,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _orders.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noOrders ?? 'لا توجد طلبات حالياً',
                        style: const TextStyle(fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchOrders,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          return _buildOrderCard(order);
                        },
                      ),
                    ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _errorMessage ?? 'حدث خطأ',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _fetchOrders,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final l10n = AppLocalizations.of(context)!;
    final status = (order['craftsman_status'] ?? order['status'] ?? '').toString();
    final waitingResponse = status == 'waiting_response';
    final accepted = status == 'accepted';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order['title'] ?? l10n.service,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (order['customer_name'] != null) ...[
              const SizedBox(height: 4),
              Text(
                '${_localizedText('العميل', 'Client')}: ${order['customer_name']}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
            const SizedBox(height: 8),
            Text(order['description'] ?? ''),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_pin, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(order['location'] ?? ''),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _mapStatusLabel(status),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: accepted ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            if (waitingResponse) _buildActionButtons(order),
            if (accepted) ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ConversationsScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text(_localizedText('افتح المحادثة', 'Ouvrir la discussion')),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _respondToOrder(order['id'], true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(_localizedText('أوافق', 'Accepter')),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _respondToOrder(order['id'], false),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: Text(_localizedText('أرفض', 'Refuser')),
          ),
        ),
      ],
    );
  }

  String _mapStatusLabel(String status) {
    switch (status) {
      case 'waiting_response':
        return _localizedText('بانتظار موافقتك', 'En attente de votre réponse');
      case 'accepted':
        return _localizedText('تم قبول الطلب', 'Commande acceptée');
      case 'rejected':
        return _localizedText('تم رفض الطلب', 'Commande refusée');
      default:
        return _localizedText('حالة الطلب غير معروفة', 'Statut inconnu');
    }
  }

  String _localizedText(String ar, String fr) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? ar : fr;
  }
}

