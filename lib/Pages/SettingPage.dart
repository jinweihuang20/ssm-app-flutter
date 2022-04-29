// ignore_for_file: avoid_print

import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../Pages/SettingPage/ItemTitle.dart';
import '../Pages/SettingPage/ItemContainer.dart';
import '../SysSetting.dart';
import '../Database/SqliteAPI.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPage();
}

class _SettingPage extends State<SettingPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  String appVersion = "0.0.0.0";
  @override
  Widget build(BuildContext context) {
    var column = Column(
      children: [
        const ItemTitle(
          text: 'APP Information',
          icon: Icon(
            Icons.info,
            size: 17,
          ),
        ),
        ItemContainer(
          children: [Text('版本號'), Text(appVersion)],
        ),
        const ItemTitle(
          text: '外觀與樣式',
          icon: Icon(
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
        const ItemTitle(
          text: '資料儲存',
          icon: Icon(
            Icons.save,
            size: 17,
          ),
        ),
        ItemContainer(children: [const Text('數據使用資料庫暫存'), Switch(value: _writeDataToDb, onChanged: _writeData2DbSwitchOnChange)]),
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
                    decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.only(left: 12, top: 10), border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
          ),
        ]),
        ItemTitle(
          text: 'Developer',
          icon: Icon(Icons.developer_mode),
        ),
        ItemContainer(
          children: [const Text('顯示Landing Page'), ElevatedButton(onPressed: showLandingPage, child: const Text('SHOW'))],
        )
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('系統設定'),
      ),
      body: column,
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
    API.getAPPSetting().then((settings) async {
      final appInfo = await PackageInfo.fromPlatform();
      print(appInfo.toString());
      setState(() {
        appVersion = appInfo.version;
        appTheme = settings.appTheme;
        _writeDataToDb = settings.saveDataToDB == 1;
        dataSaveDay = settings.dataKeepDay;
        dataSaveDayTextFieldcontroller = TextEditingController(text: dataSaveDay.toString());
        print('SettingLoaded');
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

  void showLandingPage() async {
    Navigator.pushNamed(context, '/landing', arguments: 'dev');
  }
}
