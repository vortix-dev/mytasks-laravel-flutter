import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'https://api-mytasks.x10.mx/api';
  static final storage = FlutterSecureStorage();

  // تسجيل الدخول
  static Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await storage.write(key: 'token', value: data['access_token']);
      return true;
    }

    return false;
  }

  // تسجيل حساب جديد
  static Future<bool> register(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    final url = Uri.parse('$baseUrl/register');

    final response = await http.post(
      url,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      },
    );

    return response.statusCode == 200;
  }

  // جلب التوكن من التخزين الآمن
  static Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  // جلب المهام
  static Future<List> fetchTasks() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/tasks');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    }

    return [];
  }

  // إضافة مهمة
  static Future<Map<String, dynamic>?> addTask(String task) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/tasks');

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token'},
      body: {'task': task},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    }

    return null;
  }

  // تحديث مهمة
  static Future<bool> updateTask(int id, String taskText) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/tasks-up/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'task': taskText}),
    );

    return response.statusCode == 200;
  }

  // حذف مهمة
  static Future<bool> deleteTask(int id) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/tasks/$id');

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }

  // تسجيل الخروج
  static Future<void> logout() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/logout');

    await http.post(url, headers: {'Authorization': 'Bearer $token'});
    await storage.delete(key: 'token');
  }
}
