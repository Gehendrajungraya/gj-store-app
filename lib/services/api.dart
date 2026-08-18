import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/product.dart';
import '../models/banner_model.dart';
import '../models/category.dart';

class ApiService {
  static Future<dynamic> get(String path, {Map<String,String>? headers}) async {
    final r = await http.get(Uri.parse('${AppConfig.apiBase}$path'), headers: headers);
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('API ${r.statusCode}: ${r.body}');
    }
    return jsonDecode(r.body);
  }

  static Future<List<Product>> products({String search=''}) async {
    final q = search.isEmpty ? '' : '?search=${Uri.encodeQueryComponent(search)}';
    final data = await get('/products$q');
    final list = data is List ? data : (data['products'] ?? data['data'] ?? []);
    return list.map<Product>((e)=>Product.fromJson(Map<String,dynamic>.from(e))).toList();
  }

  static Future<List<StoreBanner>> banners() async {
    final data = await get('/banners');
    final list = data is List ? data : (data['banners'] ?? data['data'] ?? []);
    return list.map<StoreBanner>((e)=>StoreBanner.fromJson(Map<String,dynamic>.from(e))).toList();
  }

  static Future<List<StoreCategory>> categories() async {
    final data = await get('/categories');
    final list = data is List ? data : (data['categories'] ?? data['data'] ?? []);
    return list.map<StoreCategory>((e)=>StoreCategory.fromJson(Map<String,dynamic>.from(e))).toList();
  }

  static Future<Map<String,dynamic>> login(String email, String password) async {
    final data = await get('/auth/login');
    // Replace with POST when your plugin's final auth endpoint/schema is confirmed.
    return Map<String,dynamic>.from(data);
  }
}
