// ignore_for_file: avoid_print

import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'Pages/SettingPage.dart';
import 'main.dart';
import 'Pages/QueryPage.dart';

class DrawerWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DrawerWidget();
}

class _DrawerWidget extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      semanticLabel: "test",
      backgroundColor: Colors.white,
      elevation: 1.2,
      child: ListView(
        children: [
          ElevatedButton.icon(
            label: const Text('HOME'),
            icon: const Icon(Icons.home),
            onPressed: goHomePage,
            style: _menuButtonStyle(),
          ),
          ElevatedButton.icon(
            label: const Text('歷史資料查詢'),
            icon: const Icon(Icons.query_builder),
            onPressed: goQueryPage,
            style: _menuButtonStyle(),
          ),
          ElevatedButton.icon(
            label: const Text('Setting'),
            icon: const Icon(Icons.settings),
            onPressed: goSettingPage,
            style: _menuButtonStyle(),
          ),
        ],
      ),
    );
  }

  void goSettingPage() {
    Navigator.pop(context);
    Navigator.pushNamed(context, 'settings');
  }

  void goHomePage() {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyApp()));
  }

  ButtonStyle _menuButtonStyle() {
    return ButtonStyle(
        alignment: Alignment.centerLeft,
        backgroundColor: MaterialStateProperty.all(Colors.white),
        foregroundColor: MaterialStateProperty.all(Colors.grey),
        shadowColor: MaterialStateProperty.all(Colors.grey));
  }

  void goQueryPage() {
    Navigator.pop(context);
    Navigator.pushNamed(context, 'query');
  }
}
