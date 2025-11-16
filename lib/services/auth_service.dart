import 'dart:convert';
import 'dart:io';
import 'package:comfortremote/models/auth_response.dart';
import 'package:comfortremote/models/session_mannager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final _baseUrl = dotenv.env['API_URL'];

  Future<AuthResponse> authenticateWithFoto(File imageFile) async {
    try {
      var request =
          http.MultipartRequest("POST", Uri.parse('$_baseUrl/recongnition'));

      request.files.add(await http.MultipartFile.fromPath(
          'file', imageFile.path,
          filename: 'face_foto.jpg'));
      request.headers["Accept"] = 'application/json';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final auth = AuthResponse.fromJson(responseData);

        await SessionManager().saveSession(auth);
        return auth;
      } else {
        final responseData = json.decode(response.body);
        return AuthResponse.fromJson(responseData);
      }
    } catch (e) {
      debugPrint('Error en sendPhotoForRecognition: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}
