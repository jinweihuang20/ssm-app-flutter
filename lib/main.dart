// ignore_for_file: avoid_print, non_constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ssmflutter/Pages/LandingPage.dart';
import 'Pages/MainPage.dart';
import 'package:wakelock/wakelock.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Wakelock.enable();
  //延遲開啟APP -> 讓Splash Page 停久一點。
  Timer(Duration(seconds: 2), () {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo -20220414',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Color.fromARGB(255, 32, 32, 32), selectedItemColor: Colors.blue),
          backgroundColor: Colors.black,
          primaryColor: Colors.black,
          brightness: Brightness.dark),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: true,
      initialRoute: "/",
      routes: {
        '/landing': (context) => const LandingPage(),
        '/': (context) => const MainPage(),
      },
    );
  }
}
