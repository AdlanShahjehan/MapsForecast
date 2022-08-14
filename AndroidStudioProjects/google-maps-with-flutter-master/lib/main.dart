import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import '/screens/auth_screen.dart';
import 'package:device_preview/device_preview.dart';
import 'screens/current_location_screen.dart';
import '/screens/current_location_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ignore: deprecated_member_use
  SystemChrome.setEnabledSystemUIOverlays([]);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp();

  runApp(DevicePreview(
    enabled: false,
    builder: (context) => const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Auth Application',
        theme: ThemeData(
            primarySwatch: Colors.orange,
            backgroundColor: Colors.white,
            // ignore: deprecated_member_use
            accentColor:  const Color.fromRGBO(38, 166, 154, 1),
            // ignore: deprecated_member_use
            accentColorBrightness: Brightness.dark,
            buttonTheme: ButtonTheme.of(context).copyWith(
                buttonColor: const Color.fromRGBO(77, 182, 172  , 1),
                textTheme: ButtonTextTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ))),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }
            if (userSnapshot.hasData) {
              return const CurrentLocationScreen();
            }
            return const AuthScreen();
          },
        ));
  }
}
