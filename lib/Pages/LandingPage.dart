// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    Widget img = Image.asset(
      'assets/landing.jpg',
      height: 200,
      width: 200,
    );
    List<Widget> showWidgets = [];
    var arg = ModalRoute.of(context)!.settings.arguments as String;

    if (arg == 'dev') {
      showWidgets = [
        img,
        const Text('Develop Mode', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        ElevatedButton(onPressed: _backToPreviousPage, child: const Text('back'))
      ];
    } else {
      showWidgets = [img];
      _startEntryTimer();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: showWidgets,
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 100,
        width: 200,
        child: Column(
          children: const [
            Text(
              "GPM",
              style: TextStyle(color: Color.fromARGB(255, 19, 70, 209), fontSize: 40, fontWeight: FontWeight.bold),
            ),
            Text(
              "2022 RC",
              style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    print('landing init');
  }

  void _startEntryTimer() {
    print(DateTime.now().toString());
    const timeout = const Duration(seconds: 3);
    Timer(timeout, () {
      print(DateTime.now().toString());
      Navigator.pushNamed(context, '/');
    });
  }

  void _backToPreviousPage() {
    Navigator.pop(context);
  }
}
