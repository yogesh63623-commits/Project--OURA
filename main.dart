import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/intelligence_feed_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const OuraApp());
}

class OuraApp extends StatelessWidget {
  const OuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Oura',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: const IntelligenceFeedScreen(),
    );
  }
}
