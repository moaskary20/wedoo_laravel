import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import 'web_api_service.dart';
import 'fallback_api_service.dart';
import 'direct_web_api_service.dart';
import 'simple_html_api_service.dart';
import 'ultimate_web_api_service.dart';

class ApiService {
  static final Dio _dio = Dio();
  
  static void init() {
    if (kIsWeb) {
      WebApiService.init();
      return;
    }
    
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = Duration(seconds: 30);
    _dio.options.receiveTimeout = Duration(seconds: 30);
    
    // إضافة interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers.addAll(ApiConfig.headers);
        print('Request: ${options.method} ${options.uri}');
        print('Headers: ${options.headers}');
        print('Data: ${options.data}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('Response: ${response.statusCode} ${response.requestOptions.uri}');
        print('Response Data: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('Error: ${error.message}');
        print('Error Response: ${error.response?.data}');
        handler.next(error);
      },
    ));
  }
  
  static Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    if (kIsWeb) {
      try {
        // محاولة UltimateWebApiService أولاً (XMLHttpRequest مع async: true)
        final result = await UltimateWebApiService.post(path, data: data);
        return Response(
          data: result,
          statusCode: 200,
          requestOptions: RequestOptions(path: path),
        );
      } catch (e) {
        print('UltimateWebApiService failed, trying SimpleHtmlApiService: $e');
        try {
          // محاولة SimpleHtmlApiService ثانياً
          final result = await SimpleHtmlApiService.post(path, data: data);
          return Response(
            data: result,
            statusCode: 200,
            requestOptions: RequestOptions(path: path),
          );
        } catch (e2) {
          print('SimpleHtmlApiService failed, trying DirectWebApiService: $e2');
          try {
            // محاولة DirectWebApiService ثالثاً
            final result = await DirectWebApiService.post(path, data: data);
            return Response(
              data: result,
              statusCode: 200,
              requestOptions: RequestOptions(path: path),
            );
          } catch (e3) {
            print('DirectWebApiService failed, trying WebApiService: $e3');
            try {
              // محاولة WebApiService رابعاً
              return await WebApiService.post(path, data: data);
            } catch (e4) {
              print('WebApiService failed, trying FallbackApiService: $e4');
              try {
                // استخدام FallbackApiService كبديل أخير
                final result = await FallbackApiService.post(path, data: data);
                return Response(
                  data: result,
                  statusCode: 200,
                  requestOptions: RequestOptions(path: path),
                );
              } catch (fallbackError) {
                print('All web methods failed: $fallbackError');
                rethrow;
              }
            }
          }
        }
      }
    }
    
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }
  
  static Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    if (kIsWeb) {
      try {
        // محاولة UltimateWebApiService أولاً (XMLHttpRequest مع async: true)
        final result = await UltimateWebApiService.get(path, queryParameters: queryParameters);
        return Response(
          data: result,
          statusCode: 200,
          requestOptions: RequestOptions(path: path),
        );
      } catch (e) {
        print('UltimateWebApiService failed, trying SimpleHtmlApiService: $e');
        try {
          // محاولة SimpleHtmlApiService ثانياً
          final result = await SimpleHtmlApiService.get(path, queryParameters: queryParameters);
          return Response(
            data: result,
            statusCode: 200,
            requestOptions: RequestOptions(path: path),
          );
        } catch (e2) {
          print('SimpleHtmlApiService failed, trying DirectWebApiService: $e2');
          try {
            // محاولة DirectWebApiService ثالثاً
            final result = await DirectWebApiService.get(path, queryParameters: queryParameters);
            return Response(
              data: result,
              statusCode: 200,
              requestOptions: RequestOptions(path: path),
            );
          } catch (e3) {
            print('DirectWebApiService failed, trying WebApiService: $e3');
            try {
              // محاولة WebApiService رابعاً
              return await WebApiService.get(path, queryParameters: queryParameters);
            } catch (e4) {
              print('WebApiService failed, trying FallbackApiService: $e4');
              try {
                // استخدام FallbackApiService كبديل أخير
                final result = await FallbackApiService.get(path, queryParameters: queryParameters);
                return Response(
                  data: result,
                  statusCode: 200,
                  requestOptions: RequestOptions(path: path),
                );
              } catch (fallbackError) {
                print('All web methods failed: $fallbackError');
                rethrow;
              }
            }
          }
        }
      }
    }
    
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }
  
  static Future<Response> put(String path, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }
  
  static Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }
}
