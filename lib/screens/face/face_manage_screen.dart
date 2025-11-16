import 'package:flutter/material.dart';

class FaceManageScreen extends StatelessWidget {
  const FaceManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar rostros'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Aquí podrás añadir o eliminar rostros (placeholder).', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Añadir rostro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
