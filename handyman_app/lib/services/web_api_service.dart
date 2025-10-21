import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class WebApiService {
  static final Dio _dio = Dio();
  
  static void init() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = Duration(seconds: 30);
    _dio.options.receiveTimeout = Duration(seconds: 30);
    
    // إعدادات خاصة بـ Flutter Web
    _dio.options.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'WedooApp/1.0 (Flutter Web)',
      'Origin': 'https://free-styel.store',
    });
    
    // إضافة interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('Web Request: ${options.method} ${options.uri}');
        print('Web Headers: ${options.headers}');
        print('Web Data: ${options.data}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('Web Response: ${response.statusCode} ${response.requestOptions.uri}');
        print('Web Response Data: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('Web Error: ${error.message}');
        print('Web Error Response: ${error.response?.data}');
        handler.next(error);
      },
    ));
  }
  
  static Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      print('Web API Error: $e');
      rethrow;
    }
  }
  
  static Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      print('Web API Error: $e');
      rethrow;
    }
  }
}
