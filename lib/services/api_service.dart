import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<List<User>> fetchUsers({String? token}) async {
    final uri = Uri.parse('$baseUrl/api/users/');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);
      if (decoded is List) {
        final users = decoded.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
        // Filter out soft-deleted users (deleted_at not null)
        return users.where((u) => u.deletedAt == null).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to fetch users: ${resp.statusCode} ${resp.body}');
    }
  }

  Future<User> updateUser(int id, {String? name, String? email, String? token}) async {
    final uri = Uri.parse('$baseUrl/api/users/$id');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      if (name != null) 'name': name,
      if (email != null) 'email': email,
    });

    final resp = await http.put(uri, headers: headers, body: body);
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) {
        return User.fromJson(decoded);
      } else if (decoded is List && decoded.isNotEmpty) {
        return User.fromJson(decoded.first as Map<String, dynamic>);
      } else {
        throw Exception('Unexpected response format from update');
      }
    } else {
      throw Exception('Failed to update user: ${resp.statusCode} ${resp.body}');
    }
  }
}