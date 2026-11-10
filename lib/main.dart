import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:oura/screens/intelligence_feed_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization note: $e");
  }

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B57D0)),
        useMaterial3: true,
      ),
      home: const IntelligenceFeedScreen(),
    );
  }
}