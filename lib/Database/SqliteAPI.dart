// ignore_for_file: avoid_print

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import './SensorData.dart';

class API {
  static String tableName = "sensor_data_tb";
  static Future<Database> openDB() async {
    var dbFilePath = join(await getDatabasesPath(), 'features_data.db');
    Database database = await openDatabase(dbFilePath, onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE $tableName(time TEXT PRIMARY KEY, acc_x_pp REAL, acc_y_pp REAL, acc_z_pp REAL,vel_x_rms REAL,vel_y_rms REAL,vel_z_rms REAL,dis_x_pp REAL,dis_y_pp REAL,dis_z_pp REAL)",
      );
    }, version: 6);
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
}
