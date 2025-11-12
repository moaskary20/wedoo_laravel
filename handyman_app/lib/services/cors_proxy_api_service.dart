import 'dart:html' as html;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class CorsProxyApiService {
  // استخدام CORS Proxy للتعامل مع مشاكل CORS
  static const String corsProxyUrl = 'https://api.allorigins.win/raw?url=';
  
  static Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    if (!kIsWeb) {
      throw Exception('CorsProxyApiService is only for web platform');
    }
    
    try {
      final targetUrl = '${ApiConfig.baseUrl}$path';
      final url = '$corsProxyUrl${Uri.encodeComponent(targetUrl)}';
      
      print('🔍 CORS Proxy API Request: POST $url');
      print('🔍 CORS Proxy API Data: $data');
      print('🔍 CORS Proxy API Headers: Content-Type: application/json, Accept: application/json, User-Agent: WedooApp/1.0 (Flutter Web), Origin: https://free-styel.store, X-Requested-With: XMLHttpRequest');
      
      // استخدام XMLHttpRequest مع CORS Proxy
      final xhr = html.HttpRequest();
      xhr.open('POST', url, async: true);
      
      // إضافة headers
      xhr.setRequestHeader('Content-Type', 'application/json');
      xhr.setRequestHeader('Accept', 'application/json');
      xhr.setRequestHeader('User-Agent', 'WedooApp/1.0 (Flutter Web)');
      xhr.setRequestHeader('Origin', 'https://free-styel.store');
      xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
      
      // إعداد event listeners
      final completer = Completer<Map<String, dynamic>>();
      
      xhr.onLoad.listen((event) {
        print('✅ CORS Proxy API Response Status: ${xhr.status}');
        print('✅ CORS Proxy API Response Text: ${xhr.responseText}');
        print('✅ CORS Proxy API Response Headers: ${xhr.getAllResponseHeaders()}');
        
        if (xhr.status == 200) {
          final responseText = xhr.responseText ?? '';
          try {
            final result = jsonDecode(responseText);
            print('✅ CORS Proxy API Response Data: $result');
            completer.complete(result);
          } catch (e) {
            print('❌ CORS Proxy API JSON Error: $e');
            completer.completeError(Exception('JSON Parse Error: $e'));
          }
        } else {
          print('❌ CORS Proxy API HTTP Error: ${xhr.status} - ${xhr.responseText ?? 'No response'}');
          completer.completeError(Exception('HTTP ${xhr.status}: ${xhr.responseText ?? 'No response'}'));
        }
      });
      
      xhr.onError.listen((event) {
        print('❌ CORS Proxy API Error: $event');
        print('❌ CORS Proxy API Error Type: ${event.type}');
        print('❌ CORS Proxy API Error Target: ${event.target}');
        completer.completeError(Exception('XMLHttpRequest Error: $event'));
      });
      
      // إرسال البيانات
      xhr.send(jsonEncode(data));
      
      // انتظار النتيجة
      return await completer.future;
      
    } catch (e) {
      print('CORS Proxy API Error: $e');
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (!kIsWeb) {
      throw Exception('CorsProxyApiService is only for web platform');
    }
    
    try {
      final targetUrl = '${ApiConfig.baseUrl}$path';
      final url = '$corsProxyUrl${Uri.encodeComponent(targetUrl)}';
      
      print('CORS Proxy API Request: GET $url');
      
      // استخدام XMLHttpRequest مع CORS Proxy
      final xhr = html.HttpRequest();
      xhr.open('GET', url, async: true);
      
      // إضافة headers
      xhr.setRequestHeader('Content-Type', 'application/json');
      xhr.setRequestHeader('Accept', 'application/json');
      xhr.setRequestHeader('User-Agent', 'WedooApp/1.0 (Flutter Web)');
      xhr.setRequestHeader('Origin', 'https://free-styel.store');
      xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
      
      // إعداد event listeners
      final completer = Completer<Map<String, dynamic>>();
      
      xhr.onLoad.listen((event) {
        print('✅ CORS Proxy API Response Status: ${xhr.status}');
        print('✅ CORS Proxy API Response Text: ${xhr.responseText}');
        print('✅ CORS Proxy API Response Headers: ${xhr.getAllResponseHeaders()}');
        
        if (xhr.status == 200) {
          final responseText = xhr.responseText ?? '';
          try {
            final result = jsonDecode(responseText);
            print('✅ CORS Proxy API Response Data: $result');
            completer.complete(result);
          } catch (e) {
            print('❌ CORS Proxy API JSON Error: $e');
            completer.completeError(Exception('JSON Parse Error: $e'));
          }
        } else {
          print('❌ CORS Proxy API HTTP Error: ${xhr.status} - ${xhr.responseText ?? 'No response'}');
          completer.completeError(Exception('HTTP ${xhr.status}: ${xhr.responseText ?? 'No response'}'));
        }
      });
      
      xhr.onError.listen((event) {
        print('❌ CORS Proxy API Error: $event');
        print('❌ CORS Proxy API Error Type: ${event.type}');
        print('❌ CORS Proxy API Error Target: ${event.target}');
        completer.completeError(Exception('XMLHttpRequest Error: $event'));
      });
      
      // إرسال الطلب
      xhr.send();
      
      // انتظار النتيجة
      return await completer.future;
      
    } catch (e) {
      print('CORS Proxy API Error: $e');
      rethrow;
    }
  }
}
