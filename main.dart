import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// ignore: unused_import
import 'models/email_summary.dart';
import 'repositories/email_repository.dart';
import 'screens/intelligence_feed_screen.dart';

/// Web Firebase config.
/// TODO: replace these with the real values from
/// Firebase Console > Project settings > Your apps > Web app
/// (or run `flutterfire configure` and use DefaultFirebaseOptions instead).
const FirebaseOptions _webOptions = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY',
  appId: 'YOUR_WEB_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);

bool get _webOptionsArePlaceholder => _webOptions.apiKey == 'YOUR_WEB_API_KEY';

class FirebaseStatus {
  const FirebaseStatus({
    required this.ready,
    this.usingPlaceholder = false,
    this.error,
  });

  final bool ready;
  final bool usingPlaceholder;
  final Object? error;
}

Future<FirebaseStatus> _initFirebase() async {
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(options: _webOptions);
      return FirebaseStatus(
        ready: true,
        usingPlaceholder: _webOptionsArePlaceholder,
      );
    }
    await Firebase.initializeApp();
    return const FirebaseStatus(ready: true);
  } catch (e) {
    debugPrint('Firebase init failed: $e');
    return FirebaseStatus(ready: false, error: e);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final status = await _initFirebase();
  runApp(OuraApp(status: status));
}

class OuraApp extends StatelessWidget {
  const OuraApp({super.key, required this.status});

  final FirebaseStatus status;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Oura',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      // Shows a warning strip on top when placeholder web config is used.
      builder: (context, child) {
        return Column(
          children: [
            if (status.ready && status.usingPlaceholder)
              const Material(
                color: Color(0xFFFFF4CE),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Firebase web config is a placeholder. '
                            'Add your real keys in main.dart to load data.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(child: child ?? const SizedBox.shrink()),
          ],
        );
      },
      // EmailRepository() touches Firestore, so only build it if Firebase is up.
      home: status.ready
          ? IntelligenceFeedScreen(repository: EmailRepository())
          : _FirebaseErrorScreen(error: status.error),
    );
  }
}

class _FirebaseErrorScreen extends StatelessWidget {
  const _FirebaseErrorScreen({this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 56, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  "Couldn't connect to Firebase",
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Check your Firebase web config in main.dart.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (error != null) ...[
                  const SizedBox(height: 16),
                  SelectableText(
                    '$error',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
