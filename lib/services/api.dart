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
  String toString() {
    if (status == 0) {
      return body;
    }

    return 'API error $status: $body';
  }
}

class ApiService {
  static void _logRequest(String method, Uri uri, {bool logBody = false}) {
    debugPrint('API $method $uri');
    if (logBody) {
      debugPrint('API $method request body: [not logged for security reasons]');
    }
  }

  static void _logResponse(String method, Uri uri, int statusCode, String body) {
    debugPrint('API $method $uri -> $statusCode');

    if (uri.path.contains('/auth/') || uri.path.contains('/login') || uri.path.contains('/register')) {
      debugPrint('API $method auth response: [redacted to avoid logging credentials or tokens]');
      return;
    }

    final preview = body.trim();
    if (preview.isEmpty) {
      debugPrint('API $method response body: <empty>');
      return;
    }

    final safeBody = preview.length > 1200 ? '${preview.substring(0, 1200)}... (truncated)' : preview;
    debugPrint('API $method response body: $safeBody');
  }

  static Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (AppConfig.useBearerToken) {
      final token = await _getStoredToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Future<String?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConfig.authTokenKey)?.trim();
    return (token != null && token.isNotEmpty) ? token : null;
  }

  static Uri _uri(String path) {
    final base = AppConfig.apiBase.replaceAll(RegExp(r'/$'), '');
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$cleanPath');
  }

  static String _stringFromAny(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is Map) {
      for (final key in ['url', 'src', 'image', 'full', 'large', 'medium', 'thumbnail']) {
        final candidate = value[key];
        if (candidate != null && candidate.toString().trim().isNotEmpty) {
          return candidate.toString();
        }
      }
      return '';
    }

    if (value is List && value.isNotEmpty) {
      return _stringFromAny(value.first);
    }

    return value.toString();
  }

  static String _normalizeImageUrl(dynamic value) {
    final raw = _stringFromAny(value).trim();
    if (raw.isEmpty) {
      return '';
    }

    String normalized = raw;
    if (normalized.startsWith('//')) {
      normalized = 'https:$normalized';
    }

    if (normalized.startsWith('/')) {
      return Uri.parse(AppConfig.baseUrl).resolve(normalized).toString();
    }

    final uri = Uri.tryParse(normalized);
    if (uri != null && uri.isAbsolute) {
      return uri.toString();
    }

    return Uri.parse(AppConfig.baseUrl).resolve(normalized).toString();
  }

  static Map<String, dynamic> _normalizeRecord(
    Map<String, dynamic> entry,
    List<String> imageKeys,
  ) {
    final normalized = <String, dynamic>{};

    entry.forEach((key, value) {
      normalized[key] = value;
    });

    for (final key in imageKeys) {
      if (normalized.containsKey(key) && normalized[key] != null) {
        normalized[key] = _normalizeImageUrl(normalized[key]);
      }
    }

    for (final key in ['image', 'image_url', 'featured_image']) {
      if (normalized.containsKey(key) && normalized[key] != null) {
        normalized[key] = _normalizeImageUrl(normalized[key]);
      }
    }

    return normalized;
  }

  static String _mapNetworkError(
    Object error, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    final text = error.toString().toLowerCase();
    debugPrint('API error: $error');

    if (error is FriendlyException) return error.message;
    if (error is ApiException) return 'Request failed (${error.status}). Please try again.';
    if (text.contains('certificate_verify_failed') ||
        text.contains('handshakeerror') ||
        text.contains('handshake') ||
        text.contains('unable to get local issuer certificate')) {
      return 'Secure connection with the store server failed. Please try again later.';
    }
    if (text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('clientexception') ||
        text.contains('connection reset') ||
        text.contains('tls')) {
      return 'Unable to connect to the server. Please check your internet connection.';
    }
    if (text.contains('timeout')) {
      return 'The server is taking too long to respond. Please try again.';
    }
    if (text.contains('formatexception')) {
      return 'Something went wrong. Please try again.';
    }
    if (text.contains('login failed') ||
        text.contains('unauthorized') ||
        text.contains('forbidden')) {
      return 'Login failed. Please check your email and password.';
    }
    if (text.contains('no products') || text.contains('not found')) {
      return 'No products available right now.';
    }
    return fallback;
  }

  static Future<dynamic> get(String path) async {
    try {
      final uri = _uri(path);

      _logRequest('GET', uri);

      if (uri.scheme != 'https') {
        throw FriendlyException('Unable to connect to the server. Please check your internet connection.');
      }

      final response = await http
          .get(
            uri,
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 30));

      _logResponse('GET', uri, response.statusCode, response.body);

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
    } on HandshakeException catch (_) {
      debugPrint('API handshake failure for GET ${_uri(path)}');
      throw FriendlyException('Secure connection with the store server failed. Please try again later.');
    } on SocketException {
      throw FriendlyException('Unable to connect to the server. Please check your internet connection.');
    } on TimeoutException {
      throw FriendlyException('The server is taking too long to respond. Please try again.');
    } on FormatException {
      throw FriendlyException('Something went wrong. Please try again.');
    } on FriendlyException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (error) {
      throw FriendlyException(_mapNetworkError(error));
    }
  }

  static Future<dynamic> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = _uri(path);

      _logRequest('POST', uri, logBody: true);

      if (uri.scheme != 'https') {
        throw FriendlyException('Unable to connect to the server. Please check your internet connection.');
      }

      final response = await http
          .post(
            uri,
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      _logResponse('POST', uri, response.statusCode, response.body);

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
    } on HandshakeException catch (_) {
      debugPrint('API handshake failure for POST ${_uri(path)}');
      throw FriendlyException('Secure connection with the store server failed. Please try again later.');
    } on SocketException {
      throw FriendlyException('Unable to connect to the server. Please check your internet connection.');
    } on TimeoutException {
      throw FriendlyException('The server is taking too long to respond. Please try again.');
    } on FormatException {
      throw FriendlyException('Something went wrong. Please try again.');
    } on FriendlyException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (error) {
      throw FriendlyException(_mapNetworkError(error));
    }
  }

  static List<dynamic> _list(dynamic data, String key) {
    if (data is List) {
      return data;
    }

    if (data is Map) {
      final candidateKeys = [key, 'items', 'products', 'categories', 'banners', 'data'];
      for (final candidate in candidateKeys) {
        if (data[candidate] is List) {
          return data[candidate] as List;
        }
      }

      if (data['data'] is Map) {
        final innerData = data['data'] as Map;
        for (final candidate in [key, 'items', 'products', 'categories', 'banners']) {
          if (innerData[candidate] is List) {
            return innerData[candidate] as List;
          }
        }
      }
    }

    return const [];
  }

  static Future<List<Product>> products({String search = '', int? categoryId}) async {
    final qp = <String, String>{};
    if (search.trim().isNotEmpty) {
      qp['search'] = search.trim();
    }
    if (categoryId != null) {
      qp['category'] = categoryId.toString();
    }

    final query = qp.isEmpty
        ? ''
        : '?${qp.entries.map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&')}';

    final data = await get('/products$query');
    return _list(data, 'products')
        .map((e) {
          final item = e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{};
          return Product.fromJson(_normalizeRecord(item, ['image_url', 'image', 'featured_image']));
        })
        .toList();
  }

  static Future<List<StoreBanner>> banners() async {
    final data = await get('/banners');
    return _list(data, 'banners')
        .map((e) {
          final item = e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{};
          return StoreBanner.fromJson(_normalizeRecord(item, ['image_url', 'image']));
        })
        .toList();
  }

  static Future<List<StoreCategory>> categories() async {
    final data = await get('/categories');
    return _list(data, 'categories')
        .map((e) {
          final item = e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{};
          return StoreCategory.fromJson(_normalizeRecord(item, ['image_url', 'image']));
        })
        .toList();
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final path = AppConfig.loginPath ?? '/auth/login';
    final data = await post(path, {'email': email, 'password': password});
    return Map<String, dynamic>.from(data);
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final path = AppConfig.registerPath ?? '/auth/register';
    final data = await post(path, {'name': name, 'email': email, 'password': password});
    return Map<String, dynamic>.from(data);
  }

  static Future<dynamic> orders() async => get('/orders');

  static Future<dynamic> licenses() async => get('/licenses');

  static Future<dynamic> notifications() async => get('/notifications');

  static Future<dynamic> wishlist() async => get('/wishlist');

  static Future<Map<String, dynamic>> checkout(Map<String, dynamic> body) async {
    final data = await post('/checkout', body);
    return Map<String, dynamic>.from(data);
  }
}
