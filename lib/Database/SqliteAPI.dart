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
        "CREATE TABLE $appSettingTableName(scope TEXT PRIMARY KEY, appTheme TEXT, saveDataToDB REAL, dataKeepDay REAL)",
      );
    }, version: 1);
    return database;
  }

  static Future<void> insertData(SensorData data) async {
    Database database = await openDB();

    try {
      await database.insert(tableName, data.toJson());
    } catch (e) {
      print(e);
    }
  }

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

  static Future<List<Map<String, dynamic?>>> queryOutWithTimeInterval(
      DateTime start, DateTime end) async {
    List<Map<String, dynamic>> ls = [];
    Database database = await openDB();
    String startTimeStr = start.toIso8601String();
    String endTimeStr = end.toIso8601String();
    String condition =
        "time BETWEEN '" + startTimeStr + "' AND '" + endTimeStr + "'";
    print(condition);
    try {
      ls = await database.query(tableName, where: condition);
      print(ls.length);
    } catch (e) {
      print('query error: $e');
    }

    return ls;
  }

  static saveAPPSetting(SysSetting setting) async {
    try {
      var db = await openAPPSettingDB();

      var existLs = await db.query(appSettingTableName);
      if (existLs.isNotEmpty) {
        await db.update(appSettingTableName, setting.toMap(),
            where: "scope == 'user'");
      } else {
        await db.insert(appSettingTableName, setting.toMap());
      }
      getAPPSetting();
      print('ok-' '${setting.toMap()}');
    } catch (ee) {
      print(ee);
    }
  }

  static Future<SysSetting> getAPPSetting() async {
    SysSetting settings = SysSetting();

    var db = await openAPPSettingDB();
    var existLs = await db.query(appSettingTableName);
    if (existLs.isNotEmpty) {
      var settingMap = existLs.first;
      settings.appTheme = settingMap['appTheme'].toString();
      settings.saveDataToDB = int.parse(
          double.parse(settingMap['saveDataToDB'].toString())
              .toStringAsFixed(0));
      settings.dataKeepDay = int.parse(
          double.parse(settingMap['dataKeepDay'].toString())
              .toStringAsFixed(0));
      print('from db :' + settings.toMap().toString());
    }

    return settings;
  }
}
