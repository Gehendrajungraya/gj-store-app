import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../models/banner_model.dart';
import '../models/category.dart';
import '../models/product.dart';

class ApiService {
  static Future<Map<String, String>> _headers() async {
    final h = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (AppConfig.useBearerToken) {
      final token = await _getStoredToken();
      if (token != null && token.isNotEmpty) {
        h['Authorization'] = 'Bearer $token';
      }
    }
    return h;
  }

  static Future<String?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConfig.authTokenKey)?.trim();
    return (token != null && token.isNotEmpty) ? token : null;
  }

  static String _mapNetworkError(Object error, {String fallback = 'Something went wrong. Please try again.'}) {
    final text = error.toString().toLowerCase();
    debugPrint('API error: $error');

    if (error is FriendlyException) return error.message;
    if (text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('clientexception') ||
        text.contains('connection reset') ||
        text.contains('tls') ||
        text.contains('handshake')) {
      return 'Unable to connect to the server. Please check your internet connection.';
    }
    if (text.contains('timeout')) {
      return 'The server is taking too long to respond. Please try again.';
    }
    if (text.contains('formatexception')) {
      return 'Something went wrong. Please try again.';
    }
    if (text.contains('login failed') || text.contains('unauthorized') || text.contains('forbidden')) {
      return 'Login failed. Please check your email and password.';
    }
    if (text.contains('no products') || text.contains('not found')) {
      return 'No products available right now.';
    }
    return fallback;
  }

  static Future<dynamic> get(String path) async {
    try {
      final baseUrl = AppConfig.apiBase;
      final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      final cleanPath = path.startsWith('/') ? path : '/$path';
      final uri = Uri.parse('$cleanBase$cleanPath');

      if (uri.scheme != 'https') {
        throw FriendlyException('Unable to connect to the server. Please check your internet connection.');
      }

      final response = await http.get(uri, headers: await _headers()).timeout(const Duration(seconds: 30));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw FriendlyException('Something went wrong. Please try again.');
      }
      return response.body.isEmpty ? {} : jsonDecode(response.body);
    } on SocketException {
      throw FriendlyException('Unable to connect to the server. Please check your internet connection.');
    } on TimeoutException {
      throw FriendlyException('The server is taking too long to respond. Please try again.');
    } on FormatException {
      throw FriendlyException('Something went wrong. Please try again.');
    } catch (error) {
      throw FriendlyException(_mapNetworkError(error));
    }
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final baseUrl = AppConfig.apiBase;
      final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      final cleanPath = path.startsWith('/') ? path : '/$path';
      final uri = Uri.parse('$cleanBase$cleanPath');

      if (uri.scheme != 'https') {
        throw FriendlyException('Unable to connect to the server. Please check your internet connection.');
      }

      final response = await http.post(uri, headers: await _headers(), body: jsonEncode(body)).timeout(const Duration(seconds: 30));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw FriendlyException('Something went wrong. Please try again.');
      }
      return response.body.isEmpty ? {} : jsonDecode(response.body);
    } on SocketException {
      throw FriendlyException('Unable to connect to the server. Please check your internet connection.');
    } on TimeoutException {
      throw FriendlyException('The server is taking too long to respond. Please try again.');
    } on FormatException {
      throw FriendlyException('Something went wrong. Please try again.');
    } catch (error) {
      throw FriendlyException(_mapNetworkError(error));
    }
  }

  static List<dynamic> _list(dynamic data, String key) {
    if (data is List) return data;
    if (data is Map) {
      if (data['items'] is List) return data['items'] as List;
      if (data[key] is List) return data[key] as List;
      if (data['products'] is List) return data['products'] as List;
      if (data['categories'] is List) return data['categories'] as List;
      if (data['banners'] is List) return data['banners'] as List;
      if (data['data'] is List) return data['data'] as List;
      if (data['data'] is Map) {
        final innerData = data['data'];
        if (innerData['items'] is List) return innerData['items'] as List;
      }
    }
    return const [];
  }

  static Future<List<Product>> products({String search = '', int? categoryId}) async {
    final qp = <String, String>{};
    if (search.trim().isNotEmpty) qp['search'] = search.trim();
    if (categoryId != null) qp['category'] = categoryId.toString();
    final q = qp.isEmpty
        ? ''
        : '?${qp.entries.map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&')}';
    final data = await get('/products$q');
    return _list(data, 'products')
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<List<StoreBanner>> banners() async {
    final data = await get('/banners');
    return _list(data, 'banners')
        .map((e) => StoreBanner.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<List<StoreCategory>> categories() async {
    final data = await get('/categories');
    return _list(data, 'categories')
        .map((e) => StoreCategory.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final path = AppConfig.loginPath;
    if (path == null || path.isEmpty) {
      throw FriendlyException('Login is currently unavailable. Please try again later.');
    }
    return Map<String, dynamic>.from(await post(path, {'email': email, 'password': password}));
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final path = AppConfig.registerPath;
    if (path == null || path.isEmpty) {
      throw FriendlyException('Registration is currently unavailable. Please try again later.');
    }
    return Map<String, dynamic>.from(await post(path, {'name': name, 'email': email, 'password': password}));
  }

  static Future<dynamic> orders() => get('/orders');
  static Future<dynamic> licenses() => get('/licenses');
  static Future<dynamic> notifications() => get('/notifications');
  static Future<dynamic> wishlist() => get('/wishlist');

  static Future<Map<String, dynamic>> checkout(Map<String, dynamic> body) async =>
      Map<String, dynamic>.from(await post('/checkout', body));
}

class FriendlyException implements Exception {
  final String message;
  FriendlyException(this.message);
  @override
  String toString() => message;
}

class ApiException implements Exception {
  final int status;
  final String body;
  ApiException(this.status, this.body);
  @override
  String toString() => 'API error $status';
}
