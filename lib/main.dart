import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:login_signup_auth/views/splash/splash_view.dart';

Future onBackgroundFcmMessage(RemoteMessage msg) async {
  print(msg.notification!.title);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (Platform.isAndroid) {
    // ignore: deprecated_member_use
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }

  FirebaseMessaging.onBackgroundMessage(onBackgroundFcmMessage);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Email and Password",
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none),
            fillColor: Colors.blue.shade100,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 18,
            )),
      ),
      home: const SplashView(),
    );
  }
}
