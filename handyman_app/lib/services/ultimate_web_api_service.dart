import 'dart:html' as html;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class UltimateWebApiService {
  static Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    if (!kIsWeb) {
      throw Exception('UltimateWebApiService is only for web platform');
    }
    
    try {
      final url = '${ApiConfig.baseUrl}$path';
      
      print('Ultimate Web API Request: POST $url');
      print('Ultimate Web API Data: $data');
      
      // استخدام XMLHttpRequest مع إعدادات CORS مختلفة
      final xhr = html.HttpRequest();
      xhr.open('POST', url, async: true); // async: true بدلاً من false
      
      // إضافة headers مختلفة
      xhr.setRequestHeader('Content-Type', 'application/json');
      xhr.setRequestHeader('Accept', 'application/json');
      xhr.setRequestHeader('User-Agent', 'WedooApp/1.0 (Flutter Web)');
      xhr.setRequestHeader('Origin', 'https://free-styel.store');
      xhr.setRequestHeader('Access-Control-Request-Method', 'POST');
      xhr.setRequestHeader('Access-Control-Request-Headers', 'Content-Type');
      
      // إعداد event listeners
      final completer = Completer<Map<String, dynamic>>();
      
      xhr.onLoad.listen((event) {
        print('Ultimate Web API Response Status: ${xhr.status}');
        print('Ultimate Web API Response Text: ${xhr.responseText}');
        
        if (xhr.status == 200) {
          final responseText = xhr.responseText ?? '';
          try {
            final result = jsonDecode(responseText);
            print('Ultimate Web API Response Data: $result');
            completer.complete(result);
          } catch (e) {
            print('Ultimate Web API JSON Error: $e');
            completer.completeError(Exception('JSON Parse Error: $e'));
          }
        } else {
          completer.completeError(Exception('HTTP ${xhr.status}: ${xhr.responseText ?? 'No response'}'));
        }
      });
      
      xhr.onError.listen((event) {
        print('Ultimate Web API Error: $event');
        completer.completeError(Exception('XMLHttpRequest Error: $event'));
      });
      
      // إرسال البيانات
      xhr.send(jsonEncode(data));
      
      // انتظار النتيجة
      return await completer.future;
      
    } catch (e) {
      print('Ultimate Web API Error: $e');
      rethrow;
    }
  }
  
  static Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (!kIsWeb) {
      throw Exception('UltimateWebApiService is only for web platform');
    }
    
    try {
      final url = '${ApiConfig.baseUrl}$path';
      
      print('Ultimate Web API Request: GET $url');
      
      // استخدام XMLHttpRequest مع إعدادات CORS مختلفة
      final xhr = html.HttpRequest();
      xhr.open('GET', url, async: true); // async: true بدلاً من false
      
      // إضافة headers مختلفة
      xhr.setRequestHeader('Content-Type', 'application/json');
      xhr.setRequestHeader('Accept', 'application/json');
      xhr.setRequestHeader('User-Agent', 'WedooApp/1.0 (Flutter Web)');
      xhr.setRequestHeader('Origin', 'https://free-styel.store');
      xhr.setRequestHeader('Access-Control-Request-Method', 'GET');
      xhr.setRequestHeader('Access-Control-Request-Headers', 'Content-Type');
      
      // إعداد event listeners
      final completer = Completer<Map<String, dynamic>>();
      
      xhr.onLoad.listen((event) {
        print('Ultimate Web API Response Status: ${xhr.status}');
        print('Ultimate Web API Response Text: ${xhr.responseText}');
        
        if (xhr.status == 200) {
          final responseText = xhr.responseText ?? '';
          try {
            final result = jsonDecode(responseText);
            print('Ultimate Web API Response Data: $result');
            completer.complete(result);
          } catch (e) {
            print('Ultimate Web API JSON Error: $e');
            completer.completeError(Exception('JSON Parse Error: $e'));
          }
        } else {
          completer.completeError(Exception('HTTP ${xhr.status}: ${xhr.responseText ?? 'No response'}'));
        }
      });
      
      xhr.onError.listen((event) {
        print('Ultimate Web API Error: $event');
        completer.completeError(Exception('XMLHttpRequest Error: $event'));
      });
      
      // إرسال الطلب
      xhr.send();
      
      // انتظار النتيجة
      return await completer.future;
      
    } catch (e) {
      print('Ultimate Web API Error: $e');
      rethrow;
    }
  }
}
