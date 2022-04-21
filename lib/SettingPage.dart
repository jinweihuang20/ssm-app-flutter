// ignore_for_file: avoid_print

import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';

import 'SettingPage/ItemTitle.dart';
import 'SettingPage/ItemContainer.dart';
import 'SysSetting.dart';
import 'Database/SqliteAPI.dart';

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
        title: const Text('設定'),
      ),
      body: Column(
        children: [
          ItemTitle(
            text: 'APP Information',
            icon: const Icon(
              Icons.info,
              size: 17,
            ),
          ),
          const ItemContainer(
            children: [Text('版本號'), Text('BETA 0.0.1')],
          ),
          ItemTitle(
            text: '外觀與樣式',
            icon: const Icon(
              Icons.style,
              size: 17,
            ),
          ),
          ItemContainer(
            children: [
              const Text('APP 顏色主題'),
              DropdownButton(
                items: const [
                  DropdownMenuItem(
                    child: Text('Dark'),
                    value: 'dark',
                  ),
                  DropdownMenuItem(
                    child: Text('Light'),
                    value: 'light',
                  ),
                ],
                onChanged: appThemeChange,
                value: appTheme,
              )
            ],
          ),
          ItemTitle(
            text: '資料儲存',
            icon: const Icon(
              Icons.save,
              size: 17,
            ),
          ),
          ItemContainer(children: [
            const Text('數據使用資料庫暫存'),
            Switch(
                value: _writeDataToDb, onChanged: _writeData2DbSwitchOnChange)
          ]),
          ItemContainer(children: [
            const Text('數據保留天數'),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: 50,
                height: 40,
                child: Stack(
                  children: [
                    TextField(
                      controller: dataSaveDayTextFieldcontroller,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onChanged: dataSaveDayTFOnChange,
                      decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.only(left: 12, top: 10),
                          border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
            ),
          ])
        ],
      ),
    );
  }

  var dataSaveDayTextFieldcontroller = TextEditingController(text: "2");
  int index = 0;
  String appTheme = 'dark';
  bool _writeDataToDb = true;
  int dataSaveDay = 2;

  @override
  void dispose() {
    print('dispose');
    super.dispose();
  }

  @override
  void initState() {
    index = 2134;
    super.initState();
    API.getAPPSetting().then((settings) {
      setState(() {
        appTheme = settings.appTheme;
        _writeDataToDb = settings.saveDataToDB == 1;
        dataSaveDay = settings.dataKeepDay;
        dataSaveDayTextFieldcontroller =
            TextEditingController(text: dataSaveDay.toString());
      });
    });
  }

  void indexPlusOne() {
    setState(() {
      index++;
    });
  }

  void appThemeChange(value) {
    print(value);

    User.appTheme = value;
    setState(() {
      appTheme = value;
    });
  }

  void _writeData2DbSwitchOnChange(isWrite) {
    setState(() {
      print(isWrite);
      _writeDataToDb = isWrite;
      User.writeDataToDb = _writeDataToDb;
    });
  }

  void dataSaveDayTFOnChange(String value) {
    dataSaveDay = int.parse(value);
    User.dataSaveDay = dataSaveDay;
  }
}
