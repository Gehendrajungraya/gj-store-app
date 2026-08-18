import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../models/product.dart';
import '../models/banner_model.dart';
import '../models/category.dart';

class ApiService {
  static final http.Client _client = http.Client();

  static const Duration _timeout = Duration(seconds: 20);

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
    final cleanBase = AppConfig.apiBase.replaceAll(RegExp(r'/$'), '');
    final cleanPath = path.startsWith('/') ? path : '/$path';

    return Uri.parse('$cleanBase$cleanPath');
  }

  static Future<dynamic> get(String path) async {
    final uri = _uri(path);

    try {
      final response = await _client
          .get(
            uri,
            headers: await _headers(),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException catch (e) {
      throw NetworkException(
        'Internet connection or DNS problem. Please check your network.',
        e,
      );
    } on TimeoutException catch (e) {
      throw NetworkException(
        'The server took too long to respond. Please try again.',
        e,
      );
    } on http.ClientException catch (e) {
      throw NetworkException(
        'Unable to connect to the server.',
        e,
      );
    }
  }

  static Future<dynamic> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = _uri(path);

    try {
      final response = await _client
          .post(
            uri,
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException catch (e) {
      throw NetworkException(
        'Internet connection or DNS problem. Please check your network.',
        e,
      );
    } on TimeoutException catch (e) {
      throw NetworkException(
        'The server took too long to respond. Please try again.',
        e,
      );
    } on http.ClientException catch (e) {
      throw NetworkException(
        'Unable to connect to the server.',
        e,
      );
    }
  }

  static dynamic _handleResponse(http.Response response) {
    final status = response.statusCode;
    final body = response.body;

    if (status < 200 || status >= 300) {
      throw ApiException(status, body);
    }

    if (body.trim().isEmpty) {
      return {};
    }

    try {
      return jsonDecode(body);
    } on FormatException catch (e) {
      throw ApiException(
        status,
        'Invalid JSON response from server: $e',
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

    if (data is Map && data[key] is List) {
      return data[key] as List;
    }

    if (data is Map && data['data'] is List) {
      return data['data'] as List;
    }

    if (data is Map && data['items'] is List) {
      return data['items'] as List;
    }

    return const [];
  }

  static Future<List<Product>> products({
    String search = '',
    int? categoryId,
  }) async {
    final query = <String, String>{};

    if (search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }

    if (categoryId != null) {
      query['category'] = categoryId.toString();
    }

    final queryString = query.isEmpty
        ? ''
        : '?${query.entries.map((entry) {
            return '${Uri.encodeQueryComponent(entry.key)}='
                '${Uri.encodeQueryComponent(entry.value)}';
          }).join('&')}';

    final data = await get('/products$queryString');

    return _list(data, 'products')
        .map(
          (item) => Product.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static Future<List<StoreBanner>> banners() async {
    final data = await get('/banners');

    return _list(data, 'banners')
        .map(
          (item) => StoreBanner.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static Future<List<StoreCategory>> categories() async {
    final data = await get('/categories');

    return _list(data, 'categories')
        .map(
          (item) => StoreCategory.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    return Map<String, dynamic>.from(
      await post(
        '/auth/login',
        {
          'email': email,
          'password': password,
        },
      ),
    );
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    return Map<String, dynamic>.from(
      await post(
        '/auth/register',
        {
          'name': name,
          'email': email,
          'password': password,
        },
      ),
    );
  }

  static Future<dynamic> orders() => get('/orders');

  static Future<dynamic> licenses() => get('/licenses');

  static Future<dynamic> notifications() => get('/notifications');

  static Future<dynamic> wishlist() => get('/wishlist');

  static Future<Map<String, dynamic>> checkout(
    Map<String, dynamic> body,
  ) async {
    return Map<String, dynamic>.from(
      await post('/checkout', body),
    );
  }

  static void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final int status;
  final String body;

  ApiException(this.status, this.body);

  @override
  String toString() => 'API error $status: $body';
}

class NetworkException implements Exception {
  final String message;
  final Object? cause;

  NetworkException(this.message, [this.cause]);

  @override
  String toString() => message;
}
