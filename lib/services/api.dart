import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../models/product.dart';
import '../models/banner_model.dart';
import '../models/category.dart';

class ApiService {
  static Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (AppConfig.useBearerToken) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Uri _uri(String path) {
    final base = AppConfig.apiBase.replaceAll(RegExp(r'/$'), '');
    final cleanPath = path.startsWith('/') ? path : '/$path';

    return Uri.parse('$base$cleanPath');
  }

  static Future<dynamic> get(String path) async {
    try {
      final uri = _uri(path);

      final response = await http
          .get(
            uri,
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          response.statusCode,
          response.body,
        );
      }

      if (response.body.trim().isEmpty) {
        return {};
      }

      return jsonDecode(response.body);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        0,
        'Network error: $e',
      );
    }
  }

  static Future<dynamic> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = _uri(path);

      final response = await http
          .post(
            uri,
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          response.statusCode,
          response.body,
        );
      }

      if (response.body.trim().isEmpty) {
        return {};
      }

      return jsonDecode(response.body);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        0,
        'Network error: $e',
      );
    }
  }

  static List<dynamic> _list(
    dynamic data,
    String key,
  ) {
    if (data is List) {
      return data;
    }

    if (data is Map) {
      if (data[key] is List) {
        return data[key] as List;
      }

      if (data['items'] is List) {
        return data['items'] as List;
      }

      if (data['data'] is List) {
        return data['data'] as List;
      }
    }

    return const [];
  }

  static Future<List<Product>> products({
    String search = '',
    int? categoryId,
  }) async {
    final params = <String, String>{};

    if (search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }

    if (categoryId != null) {
      params['category'] = categoryId.toString();
    }

    final query = params.isEmpty
        ? ''
        : '?${Uri(
            queryParameters: params,
          ).query}';

    final data = await get('/products$query');

    return _list(data, 'products')
        .map(
          (e) => Product.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  static Future<List<StoreBanner>> banners() async {
    final data = await get('/banners');

    return _list(data, 'banners')
        .map(
          (e) => StoreBanner.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  static Future<List<StoreCategory>> categories() async {
    final data = await get('/categories');

    return _list(data, 'categories')
        .map(
          (e) => StoreCategory.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final data = await post(
      '/auth/login',
      {
        'email': email,
        'password': password,
      },
    );

    return Map<String, dynamic>.from(data);
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final data = await post(
      '/auth/register',
      {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    return Map<String, dynamic>.from(data);
  }

  static Future<dynamic> orders() {
    return get('/orders');
  }

  static Future<dynamic> licenses() {
    return get('/licenses');
  }

  static Future<dynamic> notifications() {
    return get('/notifications');
  }

  static Future<dynamic> wishlist() {
    return get('/wishlist');
  }

  static Future<Map<String, dynamic>> checkout(
    Map<String, dynamic> body,
  ) async {
    final data = await post('/checkout', body);

    return Map<String, dynamic>.from(data);
  }
}

class ApiException implements Exception {
  final int status;
  final String body;

  ApiException(
    this.status,
    this.body,
  );

  @override
  String toString() {
    if (status == 0) {
      return body;
    }

    return 'API error $status: $body';
  }
}
