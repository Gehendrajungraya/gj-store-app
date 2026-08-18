import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/product.dart';
import '../models/banner_model.dart';
import '../models/category.dart';

class ApiService {
  static Future<Map<String,String>> _headers() async {
    final h = <String,String>{'Accept':'application/json','Content-Type':'application/json'};
    if (AppConfig.useBearerToken) {
      final p = await SharedPreferences.getInstance();
      final token = p.getString('auth_token');
      if (token != null && token.isNotEmpty) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  static Future<dynamic> get(String path) async {
    final r = await http.get(Uri.parse('${AppConfig.apiBase}$path'), headers: await _headers());
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw ApiException(r.statusCode, r.body);
    }
    return r.body.isEmpty ? {} : jsonDecode(r.body);
  }

  static Future<dynamic> post(String path, Map<String,dynamic> body) async {
    final r = await http.post(Uri.parse('${AppConfig.apiBase}$path'),
      headers: await _headers(), body: jsonEncode(body));
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw ApiException(r.statusCode, r.body);
    }
    return r.body.isEmpty ? {} : jsonDecode(r.body);
  }

  static List<dynamic> _list(dynamic data, String key) {
    if (data is List) return data;
    if (data is Map && data[key] is List) return data[key] as List;
    if (data is Map && data['data'] is List) return data['data'] as List;
    return const [];
  }

  static Future<List<Product>> products({String search='', int? categoryId}) async {
    final qp = <String,String>{};
    if (search.trim().isNotEmpty) qp['search']=search.trim();
    if (categoryId != null) qp['category']=categoryId.toString();
    final q = qp.isEmpty ? '' : '?${qp.entries.map((e)=>'${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&')}';
    final data = await get('/products$q');
    return _list(data,'products').map((e)=>Product.fromJson(Map<String,dynamic>.from(e))).toList();
  }

  static Future<List<StoreBanner>> banners() async {
    final data = await get('/banners');
    return _list(data,'banners').map((e)=>StoreBanner.fromJson(Map<String,dynamic>.from(e))).toList();
  }

  static Future<List<StoreCategory>> categories() async {
    final data = await get('/categories');
    return _list(data,'categories').map((e)=>StoreCategory.fromJson(Map<String,dynamic>.from(e))).toList();
  }

  static Future<Map<String,dynamic>> login(String email, String password) async =>
      Map<String,dynamic>.from(await post('/auth/login', {'email':email,'password':password}));

  static Future<Map<String,dynamic>> register(String name,String email,String password) async =>
      Map<String,dynamic>.from(await post('/auth/register', {'name':name,'email':email,'password':password}));

  static Future<dynamic> orders() => get('/orders');
  static Future<dynamic> licenses() => get('/licenses');
  static Future<dynamic> notifications() => get('/notifications');
  static Future<dynamic> wishlist() => get('/wishlist');

  static Future<Map<String,dynamic>> checkout(Map<String,dynamic> body) async =>
      Map<String,dynamic>.from(await post('/checkout', body));
}

class ApiException implements Exception {
  final int status; final String body;
  ApiException(this.status,this.body);
  @override String toString()=> 'API error $status';
}
