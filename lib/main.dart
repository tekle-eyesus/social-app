import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:socialapp/auth/auth.dart';
import 'package:socialapp/firebase_options.dart';
import 'package:socialapp/screens/profile_screen.dart';
import 'package:socialapp/screens/users_screen.dart';
import 'package:socialapp/theme/dark_mode.dart';
import 'package:socialapp/theme/light_mode.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthUser(),
      theme: lightMode,
      darkTheme: darkMode,
      routes: {
        "/usersScreen": (context) => const UsersScreen(),
        "/profileScreen": (context) => const ProfileScreen(),
        "/postScreen": (context) => const ProfileScreen(),
      },
    );
  }
}
