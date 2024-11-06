import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lolcheck/firebase_options.dart';
import 'package:lolcheck/page/LoginPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material Login Page',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true, // Material 3 적용
      ),
      home: LoginPage(),
    );
  }
}
