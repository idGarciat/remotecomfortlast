import 'package:flutter/material.dart';

// Device screens removed. This placeholder prevents missing-import errors
class DevicePanelScreen extends StatelessWidget {
  const DevicePanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundDark = Color(0xFF101922);
    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Dispositivos (eliminado)', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'La pantalla de Dispositivos ha sido eliminada del flujo. Usa Inicio o Dashboard.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

