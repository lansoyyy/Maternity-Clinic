import 'dart:html' hide VoidCallback;
import 'dart:ui_web' as ui;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'screens/auth/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register Google Maps iframe for web
  if (kIsWeb) {
    ui.platformViewRegistry.registerViewFactory(
      'google-maps-iframe',
      (int viewId) => IFrameElement()
        ..src =
            'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3861.0340427559783!2d120.9877!3d14.6043!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3397c9f8cdcd9a87%3A0x287d10347c1b31bc!2sVictory%20Lying-In%20Center!5e0!3m2!1sen!2sph!4v1700000000000'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true,
    );
  }

  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAHLEmv94h9MqjUEpjL7ik0L_CrWPjCJIs",
          authDomain: "maternity-clinic.firebaseapp.com",
          projectId: "maternity-clinic",
          storageBucket: "maternity-clinic.firebasestorage.app",
          messagingSenderId: "412859194071",
          appId: "1:412859194071:web:fd17423ba677c322f42e92"));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Victory Lying In - Maternity Clinic.',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE91E8C)),
        useMaterial3: true,
        fontFamily: 'Regular',
      ),
      home: const HomeScreen(),
    );
  }
}
