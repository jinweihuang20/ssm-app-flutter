// ignore_for_file: avoid_print

import 'package:sqflite/sqflite.dart';
import './Database/SqliteAPI.dart';

class SysSetting {
  String scope = "user";
  String appTheme = "dark";

  ///是否要存到DB 0 : NO ; 1:OK!!
  int saveDataToDB = 1;
  int dataKeepDay = 3;

  SysSetting();

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'scope': scope,
      'appTheme': appTheme,
      'saveDataToDB': saveDataToDB,
      'dataKeepDay': dataKeepDay,
    };
  }
}

class User {
  static SysSetting _setting = SysSetting();

  static int get dataSaveDay => _setting.dataKeepDay;
  static set dataSaveDay(int day) {
    _setting.dataKeepDay = day;
    _saveToDB();
  }

  static bool get writeDataToDb => _setting.saveDataToDB == 1;
  static set writeDataToDb(bool v) {
    _setting.saveDataToDB = v ? 1 : 0;
    _saveToDB();
  }

  static set appTheme(String value) {
    print('user set appTheme:$value');
    _setting.appTheme = value;
    _saveToDB();
  }

  static void _saveToDB() async {
    print(_setting.toMap());
    await API.saveAPPSetting(_setting);
  }

  static void loadSetting() {
    API.getAPPSetting().then((value) => _setting = value);
    print('SettingLoaded');
  }
}
