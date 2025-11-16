import 'package:flutter/material.dart';

// Devices screen removed — placeholder kept to avoid missing imports
class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundDark = Color(0xFF101922);
    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Dispositivos (eliminado)', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('La pantalla de Dispositivos ha sido eliminada. Usa Inicio o Dashboard.', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
