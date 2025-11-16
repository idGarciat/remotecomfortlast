import 'package:flutter/material.dart';

class FaceSensitivityScreen extends StatefulWidget {
  const FaceSensitivityScreen({super.key});

  @override
  State<FaceSensitivityScreen> createState() => _FaceSensitivityScreenState();
}

class _FaceSensitivityScreenState extends State<FaceSensitivityScreen> {
  double _sensitivity = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensibilidad')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ajusta la sensibilidad del reconocimiento', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Slider(
              value: _sensitivity,
              onChanged: (v) => setState(() => _sensitivity = v),
              min: 0.0,
              max: 1.0,
            ),
            Text('Valor: ${(_sensitivity * 100).round()}%'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Guardar'),
            )
          ],
        ),
      ),
    );
  }
}
