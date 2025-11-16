import 'package:comfortremote/models/user.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String? error;
  final User? user;

  AuthResponse(
      {required this.accessToken,
      required this.refreshToken,
      required this.user,
      this.error});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    if (json['error'] == null) {
      return AuthResponse(
          accessToken: json['access_token'],
          refreshToken: json['refresh_token'],
          user: User.fromJson(json['user']));
    } else {
      return AuthResponse(
          accessToken: "no access_token",
          refreshToken: "no refres_token",
          user: null,
          error: json['error']);
    }
  }
}
