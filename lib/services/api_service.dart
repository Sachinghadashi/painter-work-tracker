// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

// class ApiService {
//   // Android emulator: 10.0.2.2
//   // Real device: replace with your laptop IP, for example: "http://192.168.1.5:5000"
//   static const String baseUrl = "http://10.80.219.233:5000";

//   static Map<String, String> get _headers =>
//       {"Content-Type": "application/json"};

//   // ---------- AUTH ----------

//   static Future<Map<String, dynamic>> register(
//       String name, String email, String password) async {
//     final res = await http.post(
//       Uri.parse("$baseUrl/auth/register"),
//       headers: _headers,
//       body: jsonEncode({"name": name, "email": email, "password": password}),
//     );
//     return jsonDecode(res.body);
//   }

//   static Future<Map<String, dynamic>> login(
//       String email, String password) async {
//     final res = await http.post(
//       Uri.parse("$baseUrl/auth/login"),
//       headers: _headers,
//       body: jsonEncode({"email": email, "password": password}),
//     );
//     return jsonDecode(res.body);
//   }

//   // ---------- WORK ----------

//   static Future<List<dynamic>> getWork(String userId) async {
//     final res = await http.get(Uri.parse("$baseUrl/work/$userId"));
//     final body = jsonDecode(res.body);
//     return body['work'] as List<dynamic>;
//   }

//   static Future<void> addWork(Map<String, dynamic> data) async {
//     await http.post(
//       Uri.parse("$baseUrl/work/add"),
//       headers: _headers,
//       body: jsonEncode(data),
//     );
//   }

//   static Future<void> deleteWork(String id) async {
//     await http.delete(
//       Uri.parse("$baseUrl/work/$id"),
//       headers: _headers,
//     );
//   }
// }


class ApiService {
  static const String baseUrl = "https://painter-backend-flask.onrender.com"; // emulator

  // Registration
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: _headers,
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );
    return jsonDecode(res.body);
  }

  // Login
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: _headers,
      body: jsonEncode({"email": email, "password": password}),
    );
    return jsonDecode(res.body);
  }

  // Fetch work history
  static Future<List<dynamic>> getWork(String userId) async {
    final res = await http.get(Uri.parse("$baseUrl/work/get/$userId"));
    return jsonDecode(res.body)["work"];
  }

  // Add work entry
  static Future addWork(Map<String, dynamic> data) async {
    await http.post(
      Uri.parse("$baseUrl/work/add"),
      headers: _headers,
      body: jsonEncode(data),
    );
  }

  // Delete entry
  static Future deleteWork(String id) async {
    await http.delete(
      Uri.parse("$baseUrl/work/delete/$id"),
    );
  }

  static Map<String, String> get _headers =>
      {"Content-Type": "application/json"};
}

