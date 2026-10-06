import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'tela_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Localization Itaperuna",
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,

        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 116, 163, 187),
        ),

        scaffoldBackgroundColor:
            const Color.fromARGB(255, 215, 226, 236),
      ),

      // PRIMEIRA TELA DO APLICATIVO
      home: const TelaLogin(),
    );
  }
}