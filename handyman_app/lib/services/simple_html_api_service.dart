import 'dart:html' as html;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class SimpleHtmlApiService {
  static Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    if (!kIsWeb) {
      throw Exception('SimpleHtmlApiService is only for web platform');
    }
    
    try {
      final url = '${ApiConfig.baseUrl}$path';
      
      print('Simple HTML API Request: POST $url');
      print('Simple HTML API Data: $data');
      
      // استخدام XMLHttpRequest مباشرة
      final xhr = html.HttpRequest();
      xhr.open('POST', url, async: false);
      
      // إضافة headers
      xhr.setRequestHeader('Content-Type', 'application/json');
      xhr.setRequestHeader('Accept', 'application/json');
      xhr.setRequestHeader('User-Agent', 'WedooApp/1.0 (Flutter Web)');
      xhr.setRequestHeader('Origin', 'https://free-styel.store');
      
      // إرسال البيانات
      xhr.send(jsonEncode(data));
      
      print('Simple HTML API Response Status: ${xhr.status}');
      print('Simple HTML API Response Text: ${xhr.responseText}');
      
      if (xhr.status == 200) {
        final result = jsonDecode(xhr.responseText);
        print('Simple HTML API Response Data: $result');
        return result;
      } else {
        throw Exception('HTTP ${xhr.status}: ${xhr.responseText}');
      }
    } catch (e) {
      print('Simple HTML API Error: $e');
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (!kIsWeb) {
      throw Exception('SimpleHtmlApiService is only for web platform');
    }
    
    try {
      final url = '${ApiConfig.baseUrl}$path';
      
      print('Simple HTML API Request: GET $url');
      
      // استخدام XMLHttpRequest مباشرة
      final xhr = html.HttpRequest();
      xhr.open('GET', url, async: false);
      
      // إضافة headers
      xhr.setRequestHeader('Content-Type', 'application/json');
      xhr.setRequestHeader('Accept', 'application/json');
      xhr.setRequestHeader('User-Agent', 'WedooApp/1.0 (Flutter Web)');
      xhr.setRequestHeader('Origin', 'https://free-styel.store');
      
      // إرسال الطلب
      xhr.send();
      
      print('Simple HTML API Response Status: ${xhr.status}');
      print('Simple HTML API Response Text: ${xhr.responseText}');
      
      if (xhr.status == 200) {
        final result = jsonDecode(xhr.responseText);
        print('Simple HTML API Response Data: $result');
        return result;
      } else {
        throw Exception('HTTP ${xhr.status}: ${xhr.responseText}');
      }
    } catch (e) {
      print('Simple HTML API Error: $e');
      rethrow;
    }
  }
}
