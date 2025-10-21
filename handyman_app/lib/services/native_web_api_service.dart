import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class NativeWebApiService {
  static Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    if (!kIsWeb) {
      throw Exception('NativeWebApiService is only for web platform');
    }
    
    try {
      final url = '${ApiConfig.baseUrl}$path';
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'WedooApp/1.0 (Flutter Web)',
        'Origin': 'https://free-styel.store',
      };
      
      print('Native Web Request: POST $url');
      print('Native Web Headers: $headers');
      print('Native Web Data: $data');
      
      // استخدام fetch API مباشرة
      final response = await html.window.fetch(
        url,
        html.RequestInit(
          method: 'POST',
          headers: headers,
          body: jsonEncode(data),
        ),
      );
      
      print('Native Web Response Status: ${response.status}');
      
      if (response.status == 200) {
        final responseText = await response.text();
        print('Native Web Response Body: $responseText');
        return jsonDecode(responseText);
      } else {
        final errorText = await response.text();
        print('Native Web Error Response: $errorText');
        throw Exception('HTTP ${response.status}: $errorText');
      }
    } catch (e) {
      print('Native Web Error: $e');
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (!kIsWeb) {
      throw Exception('NativeWebApiService is only for web platform');
    }
    
    try {
      final url = '${ApiConfig.baseUrl}$path';
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'WedooApp/1.0 (Flutter Web)',
        'Origin': 'https://free-styel.store',
      };
      
      print('Native Web Request: GET $url');
      print('Native Web Headers: $headers');
      
      // استخدام fetch API مباشرة
      final response = await html.window.fetch(
        url,
        html.RequestInit(
          method: 'GET',
          headers: headers,
        ),
      );
      
      print('Native Web Response Status: ${response.status}');
      
      if (response.status == 200) {
        final responseText = await response.text();
        print('Native Web Response Body: $responseText');
        return jsonDecode(responseText);
      } else {
        final errorText = await response.text();
        print('Native Web Error Response: $errorText');
        throw Exception('HTTP ${response.status}: $errorText');
      }
    } catch (e) {
      print('Native Web Error: $e');
      rethrow;
    }
  }
}
