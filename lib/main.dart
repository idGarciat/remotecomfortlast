import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/auth/login_screen.dart';
import 'screens/face/face_recognition_screen.dart';
import 'screens/face/face_recognition_config_screen.dart';
import 'screens/face/face_manage_screen.dart';
import 'screens/face/face_sensitivity_screen.dart';
import 'screens/main_screen.dart';
import 'screens/users/users_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1173D4);
    const backgroundDark = Color(0xFF101922);

    return MaterialApp(
      title: 'Comfort Remote',
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(primary: primaryColor),
        scaffoldBackgroundColor: backgroundDark,
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent, elevation: 0),
        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(backgroundColor: primaryColor),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Inter'),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/face': (context) => const FaceRecognitionScreen(),
        '/face-config': (context) => const FaceRecognitionConfigScreen(),
        '/face-manage': (context) => const FaceManageScreen(),
        '/face-sensitivity': (context) => const FaceSensitivityScreen(),
        '/dashboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          int initial = 0;
          if (args is int) initial = args;
          return MainScreen(initialIndex: initial);
        },
        // Separate route for the standalone Dashboard UI converted from HTML
        '/dashboard-screen': (context) => const DashboardScreen(),
        '/users': (context) => const UsersScreen(),
      },
    );
  }
}
