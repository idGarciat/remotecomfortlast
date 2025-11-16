import 'package:comfortremote/models/auth_response.dart';
import 'package:comfortremote/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SessionManager {
  static const String _keyToken = 'access_token';
  static const String _refreshToken = 'refresh_token';
  static const String _keyUser = 'user';

  Future<void> saveSession(AuthResponse auth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, auth.accessToken);
    await prefs.setString(_refreshToken, auth.refreshToken);
    await prefs.setString(_keyUser, json.encode({
      'id': auth.user?.id,
      'name': auth.user?.name,
      'email': auth.user?.email,
    }));
  }

  Future<AuthResponse?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    final refreshToken = prefs.getString(_refreshToken);
    final userStr = prefs.getString(_keyUser);

    if (token != null && refreshToken != null && userStr != null) {
      final userJson = json.decode(userStr);
      return AuthResponse(
        accessToken: token,
        refreshToken: refreshToken,
        user: User.fromJson(userJson),
      );
    }
    return null;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }
}
