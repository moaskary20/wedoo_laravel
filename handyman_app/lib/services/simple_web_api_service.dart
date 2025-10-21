import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class SimpleWebApiService {
  static Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    if (!kIsWeb) {
      throw Exception('SimpleWebApiService is only for web platform');
    }
    
    try {
      final url = '${ApiConfig.baseUrl}$path';
      
      print('Simple Web Request: POST $url');
      print('Simple Web Data: $data');
      
      // استخدام fetch API مباشرة بدون RequestInit
      final response = await html.window.fetch(
        url,
        html.RequestInit(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'WedooApp/1.0 (Flutter Web)',
            'Origin': 'https://free-styel.store',
          },
          body: jsonEncode(data),
        ),
      );
      
      print('Simple Web Response Status: ${response.status}');
      
      if (response.status == 200) {
        final responseText = await response.text();
        print('Simple Web Response Body: $responseText');
        return jsonDecode(responseText);
      } else {
        final errorText = await response.text();
        print('Simple Web Error Response: $errorText');
        throw Exception('HTTP ${response.status}: $errorText');
      }
    } catch (e) {
      print('Simple Web Error: $e');
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (!kIsWeb) {
      throw Exception('SimpleWebApiService is only for web platform');
    }
    
    try {
      final url = '${ApiConfig.baseUrl}$path';
      
      print('Simple Web Request: GET $url');
      
      // استخدام fetch API مباشرة بدون RequestInit
      final response = await html.window.fetch(
        url,
        html.RequestInit(
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'User-Agent': 'WedooApp/1.0 (Flutter Web)',
            'Origin': 'https://free-styel.store',
          },
        ),
      );
      
      print('Simple Web Response Status: ${response.status}');
      
      if (response.status == 200) {
        final responseText = await response.text();
        print('Simple Web Response Body: $responseText');
        return jsonDecode(responseText);
      } else {
        final errorText = await response.text();
        print('Simple Web Error Response: $errorText');
        throw Exception('HTTP ${response.status}: $errorText');
      }
    } catch (e) {
      print('Simple Web Error: $e');
      rethrow;
    }
  }
}
