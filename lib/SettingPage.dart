import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';

import 'SettingPage/ItemTitle.dart';
import 'SettingPage/ItemContainer.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPage();
}

class _SettingPage extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting'),
      ),
      body: Column(
        children: [
          const Text(
            'APP Information',
            textAlign: TextAlign.left,
          ),
          Card(
              child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Version'),
                  Text('V123.23232.123'),
                ],
              ),
            ],
          )),
          const Text('外觀與樣式'),
          Card(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('APP 主題樣式'),
                    DropdownButton(
                      value: appTheme,
                      onChanged: appThemeChange,
                      items: const [
                        DropdownMenuItem(
                          child: Text('Dark'),
                          value: 'dark',
                        ),
                        DropdownMenuItem(
                          child: Text('Light'),
                          value: 'light',
                        )
                      ],
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('APP 主題樣式'),
                    DropdownButton(
                      value: appTheme,
                      onChanged: appThemeChange,
                      hint: Text('hint'),
                      items: const [
                        DropdownMenuItem(
                          child: Text('Dark'),
                          value: 'dark',
                        ),
                        DropdownMenuItem(
                          child: Text('Light'),
                          value: 'light',
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  int index = 0;
  String appTheme = 'dark';
  @override
  void dispose() {
    print('dispose');
    super.dispose();
  }

  @override
  void initState() {
    index = 2134;
    super.initState();
  }

  void indexPlusOne() {
    setState(() {
      index++;
    });
  }

  void appThemeChange(value) {
    print(value);
    setState(() {
      appTheme = value;
    });
  }
}
