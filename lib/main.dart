// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:veterinaryapp/route_generator.dart';
import 'package:flutter/material.dart';

import 'client/screens/home_screen.dart';
import 'login/ui/signin.dart';

// http override for internet
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
            name: 'doctor',
            options: const FirebaseOptions(
                apiKey: 'AIzaSyANH7im66Rnlpg5SFL4gNLVZ36NE1DYCN8',
                appId: '1:605580059155:android:75273d10eb6e8db9d215e6',
                messagingSenderId: '605580059155',
                projectId: 'doctorapp-6e8f4',
                storageBucket: 'gs://doctorapp-6e8f4.appspot.com'))
        .whenComplete(() {
      if (kDebugMode) {
        print("completedAppInitialize");
      }
    });
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          // textTheme:
          //     GoogleFonts.varelaRoundTextTheme(Theme.of(context).textTheme),
          ),
      onGenerateRoute: RouteGenerator.generateRoute,
      // initialRoute: SignInPage(),

      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 3),
      () => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, anotherAnimation) {
            return FirebaseAuth.instance.currentUser == null
                ? SignInPage()
                : HomeScreen();
          },
          transitionDuration: Duration(milliseconds: 2000),
          transitionsBuilder: (context, animation, anotherAnimation, child) {
            animation =
                CurvedAnimation(parent: animation, curve: Curves.easeInOutCirc);
            return SlideTransition(
              // scale: animation,
              position: Tween(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
                  .animate(animation),
              child: child,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            "assets/images/pets.jpg",
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black87,
            BlendMode.darken,
          ),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            Text(
              'VETCONSULTPEDIA',
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 35,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 60,
            ),
            CircularProgressIndicator(),
            SizedBox(
              height: 20,
            ),
            Text(
              "Loading",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                decoration: TextDecoration.none,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
