import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class FallbackApiService {
  static Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    if (!kIsWeb) {
      throw Exception('FallbackApiService is only for web platform');
    }
    
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$path');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'WedooApp/1.0 (Flutter Web)',
        'Origin': 'https://free-styel.store',
      };
      
      print('Fallback Request: POST $url');
      print('Fallback Headers: $headers');
      print('Fallback Data: $data');
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      
      print('Fallback Response: ${response.statusCode}');
      print('Fallback Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Fallback Error: $e');
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (!kIsWeb) {
      throw Exception('FallbackApiService is only for web platform');
    }
    
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$path');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'WedooApp/1.0 (Flutter Web)',
        'Origin': 'https://free-styel.store',
      };
      
      print('Fallback Request: GET $url');
      print('Fallback Headers: $headers');
      
      final response = await http.get(
        url,
        headers: headers,
      );
      
      print('Fallback Response: ${response.statusCode}');
      print('Fallback Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Fallback Error: $e');
      rethrow;
    }
  }
}
