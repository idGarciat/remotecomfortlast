// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:comfortremote/models/auth_response.dart';
import 'package:comfortremote/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class FaceRecognitionScreen extends StatefulWidget {
  const FaceRecognitionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FaceRecognitionScreenState createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isProcessing = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    var status = await Permission.camera.request();

    if (status.isGranted) {
      _cameras = await availableCameras();

      CameraDescription? selectedCamera;

      for (var camera in _cameras!) {
        if (camera.lensDirection == CameraLensDirection.front) {
          selectedCamera = camera;
          break;
        }
      }

      selectedCamera ??= _cameras!.first;

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
      );

      await _controller!.initialize();

      if (mounted) setState(() {});
    } else {
      debugPrint("Permiso de cámara denegado");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Pause preview and stop any image stream before taking a picture to avoid
      // acquiring more ImageReader buffers than allowed by the platform.
      try {
        await _controller?.pausePreview();
      } catch (_) {}

      // Give the pipeline a small moment to release buffers. Use a slightly
      // longer delay on some devices where 100ms is not enough.
      await Future.delayed(const Duration(milliseconds: 300));

      // If an image stream was started elsewhere, stop it before taking a picture.
      // (This codebase does not use startImageStream, but keep for safety.)
      try {
        await _controller?.stopImageStream();
      } catch (_) {}

      final image = await _controller!.takePicture();
      final File imageFile = File(image.path);

      final recongnitionResult = await _authService.authenticateWithFoto(imageFile);

      _handleRecognitionResult(recongnitionResult);

      // delete temporary file to free buffers/storage (optional)
      try {
        if (await imageFile.exists()) await imageFile.delete();
      } catch (_) {}
    } catch (e) {
      debugPrint('Error al tomar foto: $e');
      // show an error dialog so the user knows something happened
      _showErrorDialog('Error al tomar la foto: $e');
    } finally {
      // Do NOT automatically resume preview here. Resuming immediately can
      // cause ImageReader buffer contention on some Android devices because
      // buffers are still being released by the pipeline. Instead resume when
      // the user explicitly closes dialogs or retries.
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _handleRecognitionResult(AuthResponse result) {
    if (result.error == null) {
      _showSuccessDialog(result.user!.name, result.user!.email);
    } else {
      _showErrorDialog(result.error ?? "Error en iniciar session");
    }
  }

  void _showSuccessDialog(String name, String? email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reconocimiento Exitoso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenido: $name'),
            Text('Email: ${email ?? ''}'),
            SizedBox(height: 10),
            Text(
              'Acceso permitido',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _goDashboard(context),
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _close(BuildContext context) {
    // Resume preview when closing error dialog so the camera can continue
    // delivering frames normally.
    try {
      _controller?.resumePreview();
    } catch (_) {}

    setState(() {
      _isProcessing = false;
    });
    Navigator.pop(context);
  }

  void _goDashboard(BuildContext context) {
    setState(() {
      _isProcessing = false;
    });
    Navigator.pop(context);
    Navigator.of(context).pushNamed('/dashboard-screen');
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error de Reconocimiento'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => _close(context),
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceGuide() {
    return Center(
      child: Container(
        width: 250,
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 3.0,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white, width: 3),
                    left: BorderSide(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white, width: 3),
                    right: BorderSide(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white, width: 3),
                    left: BorderSide(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white, width: 3),
                    right: BorderSide(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Coloque su rostro dentro del marco",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text(
                "Inicializando cámara...",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Reconocimiento facial"),
        backgroundColor: Color(0xFF101922),
        // foregroundColor: Colors.white,
      ),
      body: Stack(
        alignment: AlignmentGeometry.center,
        children: [
          Container(
            width: 250,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 3.0,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: CameraPreview(_controller!),
          ),
          _buildFaceGuide(),
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  Text(
                    "Para un mejor reconocimiento:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "• Buena iluminación\n• Rostro centrado\n• Sin gafas oscuras\n• Fondo neutro",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      'Procesando reconocimiento...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
