import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1173D4);
    const backgroundDark = Color(0xFF101922);

    return Scaffold(
      backgroundColor: backgroundDark,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // AppBar-like row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      const Text('Smart Home', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          // Inicio de sesión alternativo: ir directo a la pantalla principal
                          Navigator.of(context).pushReplacementNamed('/dashboard', arguments: 0);
                        },
                        icon: const Icon(Icons.help_outline),
                        color: Colors.grey,
                      )
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Bienvenido', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 8),
                          Text('Control del hogar', style: TextStyle(color: Colors.grey[400])),
                          const SizedBox(height: 24),

                          // Face recognition button centered
                          SizedBox(height: 24),
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(60),
                                onTap: () {
                                  Navigator.of(context).pushNamed('/face');
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white24),
                                    color: primary.withAlpha((0.12 * 255).round()),
                                  ),
                                  alignment: Alignment.center,
                                    child: const Icon(Icons.face_rounded, color: Colors.white, size: 56),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('By continuing, you agree to our Terms of Service and Privacy Policy',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),

            
          ],
        ),
      ),
    );
  }
}
