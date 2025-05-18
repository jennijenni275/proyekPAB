import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:museglo/screens/welcome_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
<<<<<<< HEAD

  // CEK DULU SEBELUM INITIALIZE
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

=======
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
>>>>>>> 0323891053fa07a36762db5198662557cf48db98
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MuseGlo',
      theme: ThemeData.dark(),
      home: WelcomeScreen(),
<<<<<<< HEAD
    );
=======
   );
>>>>>>> 0323891053fa07a36762db5198662557cf48db98
  }
}