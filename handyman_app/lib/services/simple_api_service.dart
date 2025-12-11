import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class SimpleApiService {
  static final Dio _dio = Dio();
  
  static void init() {
    // Use direct API calls for all platforms
    // Don't set baseUrl to allow both full URLs and relative paths
    _dio.options.connectTimeout = Duration(seconds: 30);
    _dio.options.receiveTimeout = Duration(seconds: 30);
    
    // إضافة interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Use web-specific headers for web platform
        options.headers.addAll(kIsWeb ? ApiConfig.webHeaders : ApiConfig.headers);
        
        // Add authentication token if available
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          print('Error getting auth token: $e');
        }
        
        print('🚀 Simple API Request: ${options.method} ${options.uri}');
        print('📦 Simple API Data: ${options.data}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ Simple API Response: ${response.statusCode} ${response.requestOptions.uri}');
        print('📦 Simple API Response Data: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('❌ Simple API Error: ${error.message}');
        print('📦 Simple API Error Response: ${error.response?.data}');
        handler.next(error);
      },
    ));
  }
  
  static Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    try {
      // إذا كان path يبدأ بـ http:// أو https://، استخدمه مباشرة
      // وإلا استخدم baseUrl + path
      final url = path.startsWith('http://') || path.startsWith('https://')
          ? path
          : '${ApiConfig.baseUrl}$path';
      
      print('🚀 Simple API: محاولة POST');
      print('   📍 Path: $path');
      print('   🌐 Full URL: $url');
      print('   📦 Data: $data');
      
      // Use Dio without baseUrl to avoid conflicts
      final dio = Dio();
      dio.options.connectTimeout = Duration(seconds: 30);
      dio.options.receiveTimeout = Duration(seconds: 30);
      
      // Add headers
      final headers = kIsWeb ? ApiConfig.webHeaders : ApiConfig.headers;
      
      // Add auth token if available
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      } catch (e) {
        print('Error getting auth token: $e');
      }
      
      final response = await dio.post(
        url,
        data: data,
        options: Options(
          headers: headers,
          // Allow 400 and 422 status codes as valid responses (they may contain useful error messages)
          validateStatus: (status) {
            return status != null && status < 500; // Allow all status codes < 500
          },
        ),
      );
      
      print('✅ Simple API: نجح POST $url');
      print('   📦 Response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Simple API: فشل POST $path');
      print('   🔴 Error: $e');
      if (e is DioException && e.response != null) {
        print('   📦 Error Response: ${e.response?.statusCode} - ${e.response?.data}');
      }
      rethrow;
    }
  }
  
  static Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      // إذا كان path يبدأ بـ http:// أو https://، استخدمه مباشرة
      // وإلا استخدم baseUrl + path
      final url = path.startsWith('http://') || path.startsWith('https://')
          ? path
          : '${ApiConfig.baseUrl}$path';
      
      print('🚀 Simple API: محاولة GET $url');
      final response = await _dio.get(url, queryParameters: queryParameters);
      print('✅ Simple API: نجح GET $url');
      return response;
    } catch (e) {
      print('❌ Simple API: فشل GET $path - $e');
      rethrow;
    }
  }

  static Future<Response> put(String path, {Map<String, dynamic>? data}) async {
    try {
      print('🚀 Simple API: محاولة PUT $path');
      final response = await _dio.put(path, data: data);
      print('✅ Simple API: نجح PUT $path');
      return response;
    } catch (e) {
      print('❌ Simple API: فشل PUT $path - $e');
      rethrow;
    }
  }

  static Future<Response> delete(String path) async {
    try {
      print('🚀 Simple API: محاولة DELETE $path');
      final response = await _dio.delete(path);
      print('✅ Simple API: نجح DELETE $path');
      return response;
    } catch (e) {
      print('❌ Simple API: فشل DELETE $path - $e');
      rethrow;
    }
  }
}
