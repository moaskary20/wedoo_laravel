import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class SimpleApiService {
  static final Dio _dio = Dio();
  
  static void init() {
    // Use proxy for web platform to avoid CORS issues
    if (kIsWeb) {
      // For web, use relative path to proxy
      _dio.options.baseUrl = '';
    } else {
      _dio.options.baseUrl = ApiConfig.baseUrl;
    }
    _dio.options.connectTimeout = Duration(seconds: 30);
    _dio.options.receiveTimeout = Duration(seconds: 30);
    
    // إضافة interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Use web-specific headers for web platform
        options.headers.addAll(kIsWeb ? ApiConfig.webHeaders : ApiConfig.headers);
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
      print('🚀 Simple API: محاولة POST $path');
      // For web, prepend proxy path
      final actualPath = kIsWeb ? 'proxy.php$path' : path;
      final response = await _dio.post(actualPath, data: data);
      print('✅ Simple API: نجح POST $path');
      return response;
    } catch (e) {
      print('❌ Simple API: فشل POST $path - $e');
      rethrow;
    }
  }
  
  static Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      print('🚀 Simple API: محاولة GET $path');
      // For web, prepend proxy path
      final actualPath = kIsWeb ? 'proxy.php$path' : path;
      final response = await _dio.get(actualPath, queryParameters: queryParameters);
      print('✅ Simple API: نجح GET $path');
      return response;
    } catch (e) {
      print('❌ Simple API: فشل GET $path - $e');
      rethrow;
    }
  }

  static Future<Response> put(String path, {Map<String, dynamic>? data}) async {
    try {
      print('🚀 Simple API: محاولة PUT $path');
      // For web, prepend proxy path
      final actualPath = kIsWeb ? 'proxy.php$path' : path;
      final response = await _dio.put(actualPath, data: data);
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
      // For web, prepend proxy path
      final actualPath = kIsWeb ? 'proxy.php$path' : path;
      final response = await _dio.delete(actualPath);
      print('✅ Simple API: نجح DELETE $path');
      return response;
    } catch (e) {
      print('❌ Simple API: فشل DELETE $path - $e');
      rethrow;
    }
  }
}
