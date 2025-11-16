import 'package:flutter/material.dart';

class FaceRecognitionConfigScreen extends StatefulWidget {
  const FaceRecognitionConfigScreen({super.key});

  @override
  State<FaceRecognitionConfigScreen> createState() => _FaceRecognitionConfigScreenState();
}

class _FaceRecognitionConfigScreenState extends State<FaceRecognitionConfigScreen> {
  bool enabled = true;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1173D4);
    const backgroundDark = Color(0xFF101922);

    return Scaffold(
      backgroundColor: backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                  ),
                  const Expanded(
                    child: Center(
                      child: Text('Reconocimiento facial', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 8),
              const Text('Configuración', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Estado row with switch
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withAlpha((0.03 * 255).round()), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Estado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text('Activar o desactivar el reconocimiento', style: TextStyle(color: Color(0xFF9CA3AF))),
                      ],
                    ),
                    Switch(
                      value: enabled,
                      activeThumbColor: primary,
                      onChanged: (v) => setState(() => enabled = v),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Gestionar rostros
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/face-manage'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white.withAlpha((0.03 * 255).round()), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gestionar rostros', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('Añadir o eliminar rostros', style: TextStyle(color: Color(0xFF9CA3AF))),
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Sensibilidad
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/face-sensitivity'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white.withAlpha((0.03 * 255).round()), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sensibilidad', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('Ajustar la sensibilidad del reconocimiento', style: TextStyle(color: Color(0xFF9CA3AF))),
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ),

              // Spacer to push content up if needed
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}
