import 'package:flutter/material.dart';

// Manage devices screen removed — placeholder to avoid missing imports
class ManageDevicesScreen extends StatelessWidget {
  const ManageDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundDark = Color(0xFF101922);
    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(title: const Text('Gestionar dispositivos (eliminado)'), centerTitle: true),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Esta pantalla fue eliminada. Usa Inicio o Dashboard.', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
