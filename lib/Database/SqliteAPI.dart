// ignore_for_file: avoid_print

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ssmflutter/SysSetting.dart';
import './SensorData.dart';

class API {
  static String tableName = "sensor_data_tb";
  static String appSettingDBName = "appSetting.db";

  static String appSettingTableName = "appSetting_tb";

  static Future<Database> openDB() async {
    var dbFilePath = join(await getDatabasesPath(), 'features_data.db');
    Database database = await openDatabase(dbFilePath, onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE $tableName(time TEXT PRIMARY KEY, acc_x_pp REAL, acc_y_pp REAL, acc_z_pp REAL,vel_x_rms REAL,vel_y_rms REAL,vel_z_rms REAL,dis_x_pp REAL,dis_y_pp REAL,dis_z_pp REAL)",
      );
    }, version: 6);
    return database;
  }

  static Future<Database> openAPPSettingDB() async {
    var dbFilePath = join(await getDatabasesPath(), '$appSettingDBName');
    Database database = await openDatabase(dbFilePath, onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE $appSettingTableName(scope TEXT PRIMARY KEY, appTheme TEXT, saveDataToDB REAL, dataKeepDay REAL, ssmIp TEXT, ssmPort REAL)",
      );
    }, version: 24);
    return database;
  }

  ///插入一筆振動數據到資料庫
  static Future<void> insertData(SensorData data) async {
    Database database = await openDB();

    try {
      await database.insert(tableName, data.toJson());
    } catch (e) {
      print(e);
    }
  }

  ///從資料庫中刪除N天以前的振動數據
  ///
  ///@param day 指定的天數.
  static Future<int> delete(int day) async {
    List<Map<String, Object?>>? ls = [];
    Database database = await openDB();
    try {
      var startTimeStr = DateTime.now().add(Duration(days: -day)).toIso8601String();
      String condition = "time <= '" + startTimeStr + "'";
      return await database.delete(tableName, where: condition);
    } catch (e) {
      print(e);
      return -1;
    }
  }

  ///從資料庫中刪除所有的振動數據
  ///
  static Future<int> deleteAll() async {
    List<Map<String, Object?>>? ls = [];
    Database database = await openDB();
    try {
      var startTimeStr = DateTime.now().add(const Duration(days: 1)).toIso8601String();
      String condition = "time <= '" + startTimeStr + "'";
      return await database.delete(tableName, where: condition);
    } catch (e) {
      print(e);
      return -1;
    }
  }

  ///從資料庫中查詢所有的振動數據
  static Future<List<Map<String, Object?>>?> queryOut() async {
    List<Map<String, Object?>>? ls = [];
    Database database = await openDB();
    try {
      ls = await database.query(tableName);
    } catch (e) {
      print(e);
    }

    return ls;
  }

  ///從資料庫中查詢特定時間區間的振動數據
  static Future<List<Map<String, dynamic?>>> queryOutWithTimeInterval(DateTime start, DateTime end) async {
    List<Map<String, dynamic>> ls = [];
    Database database = await openDB();
    String startTimeStr = start.toIso8601String();
    String endTimeStr = end.toIso8601String();
    String condition = "time BETWEEN '" + startTimeStr + "' AND '" + endTimeStr + "'";
    print(condition);
    try {
      ls = await database.query(tableName, where: condition);
      print(ls.length);
    } catch (e) {
      print('query error: $e');
    }

    return ls;
  }

  ///將用戶設定儲存至資料庫
  static saveAPPSetting(SysSetting setting) async {
    try {
      var db = await openAPPSettingDB();

      var existLs = await db.query(appSettingTableName);
      if (existLs.isNotEmpty) {
        await db.update(appSettingTableName, setting.toMap(), where: "scope == 'user'");
      } else {
        await db.insert(appSettingTableName, setting.toMap());
      }
      getAPPSetting();
      print('ok-' '${setting.toMap()}');
    } catch (ee) {
      var dbFilePath = join(await getDatabasesPath(), '$appSettingDBName');
      deleteDatabase(dbFilePath);
      saveAPPSetting(setting);
      print(ee);
    }
  }

  ///從資料庫取得用戶設定
  static Future<SysSetting> getAPPSetting() async {
    SysSetting settings = SysSetting();

    var db = await openAPPSettingDB();
    var existLs = await db.query(appSettingTableName);
    if (existLs.isNotEmpty) {
      var settingMap = existLs.first;
      settings.appTheme = settingMap['appTheme'].toString();
      settings.saveDataToDB = int.parse(double.parse(settingMap['saveDataToDB'].toString()).toStringAsFixed(0));
      settings.dataKeepDay = int.parse(double.parse(settingMap['dataKeepDay'].toString()).toStringAsFixed(0));
      try {
        settings.ssmIp = settingMap['ssmIp'].toString();
        settings.ssmPort = int.parse(double.parse(settingMap['ssmPort'].toString()).toStringAsFixed(0));
      } catch (e) {
        settings.ssmIp = '127.0.0.1';
        settings.ssmPort = 5000;
      }

      print('from db :' + settings.toMap().toString());
    }

    return settings;
  }
}
