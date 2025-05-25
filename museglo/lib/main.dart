import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:museglo/screens/welcome_screen.dart';
import 'firebase_options.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MuseGlo',
          theme: ThemeData.light().copyWith(
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          darkTheme: ThemeData.dark().copyWith(
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          themeMode: mode,
          home: const WelcomeScreen(),
        );
      },
    );
  }
}
