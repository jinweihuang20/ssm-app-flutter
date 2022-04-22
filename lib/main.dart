// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:ssmflutter/Pages/LandingPage.dart';
import 'package:ssmflutter/Pages/QueryPage.dart';
import 'package:ssmflutter/SSMModule/emulator.dart' as ssm_emulator;
import 'package:ssmflutter/Pages/SettingPage.dart';
import 'dart:async';
import 'Pages/dataPage.dart';
import './drawer.dart';
import 'SSMModule/module.dart';
import 'SysSetting.dart';
import 'Pages/MainPage.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo -20220414',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: true,
      initialRoute: "/landing",
      routes: {
        '/landing': (context) => const LandingPage(),
        '/': (context) => const MainPage(),
      },
    );
  }
}
