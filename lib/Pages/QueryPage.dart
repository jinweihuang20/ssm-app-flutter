// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:path/path.dart';
import 'package:ssmflutter/Database/SensorData.dart';
import '../Chartslb/LineChart.dart';
import '../Chartslb/TimeLineChart.dart';
import '../Database/SqliteAPI.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../Storage/Caches.dart';

class QueryPage extends StatefulWidget {
  QueryPage({Key? key}) : super(key: key);

  _QueryPage state = _QueryPage();
  @override
  State<QueryPage> createState() => state;
}

class _QueryPage extends State<QueryPage> with AutomaticKeepAliveClientMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    var btnStyle = ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith(
      (Set<MaterialState> states) {
        print(states);
        if (states.contains(MaterialState.pressed)) return Colors.red;
        return Colors.green; // Use the component's default.
      },
    ));

    void queryLastFiveMinData() {
      endTime = DateTime.now();
      startTime = endTime.add(const Duration(minutes: -5));
      query();
    }

    void queryLastTenMinData() {
      endTime = DateTime.now();
      startTime = endTime.add(const Duration(minutes: -10));
      query();
    }

    void queryLastThirtyMinData() {
      endTime = DateTime.now();
      startTime = endTime.add(const Duration(minutes: -30));
      query();
    }

    var btn1 = ElevatedButton(onPressed: queryLastFiveMinData, child: const Text('過去5分鐘'), style: btnStyle);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Padding(padding: EdgeInsets.only(top: 20)),
          ButtonBar(
            alignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(onPressed: queryLastFiveMinData, child: const Text('過去5分鐘'), style: btnStyle),
              ElevatedButton(onPressed: queryLastTenMinData, child: const Text('過去10分鐘'), style: btnStyle),
              ElevatedButton(onPressed: queryLastThirtyMinData, child: const Text('過去30分鐘'), style: btnStyle)
            ],
          ),
          const Divider(),
          SizedBox(
            width: double.infinity,
            height: 200,
            child: TimeLineChart(
              title: "加速度",
              yAxisTitle: "G",
              dataSetList: accData,
            ),
          ),
          const Divider(),
          SizedBox(
            width: double.infinity,
            height: 200,
            child: TimeLineChart(
              title: "速度",
              yAxisTitle: "mm/s",
              dataSetList: velData,
            ),
          ),
          const Divider(),
          SizedBox(
            width: double.infinity,
            height: 200,
            child: TimeLineChart(
              title: "位移",
              yAxisTitle: "um",
              dataSetList: disData,
            ),
          ),
        ],
      ),
    );
  }

  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  String timeSelectFor = 'start'; //'end'

  List<Series<TimeSeriesPt, DateTime>> acc_data_seriseLs = [];
  List<Series<TimeSeriesPt, DateTime>> vel_data_seriseLs = [];
  List<Series<TimeSeriesPt, DateTime>> dis_data_seriseLs = [];

  List<TimeData> accData = [];
  List<TimeData> velData = [];
  List<TimeData> disData = [];

  @override
  void initState() {
    super.initState();
    print('Quert Page Init');
  }

  @override
  void dispose() {
    super.dispose();
    print('Query Page Disposed');
  }

  void refresh() {
    print('refresh');
  }

  void showDateTimePicker(context) {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(2022, 1, 1),
      maxTime: DateTime(2119, 6, 7),
      onChanged: (date) {
        print('change $date');
      },
      onConfirm: (date) {
        print('confirm $date');
        setState(() {
          if (timeSelectFor == 'start')
            startTime = date;
          else
            endTime = date;
        });
      },
      currentTime: DateTime.now(),
      locale: LocaleType.tw,
    );
  }

  Future<List<SensorData>> query() async {
    List<SensorData> outputLs = [];
    List<Map<String, dynamic>> ls = await API.queryOutWithTimeInterval(startTime, endTime);
    int? len = ls.length;

    if (len != 0) {
      List.generate(len, (i) {
        var dp = ls[i];
        SensorData data = SensorData(DateTime.parse(dp['time']), dp['acc_x_pp'], dp['acc_y_pp'], dp['acc_z_pp'], dp['vel_x_rms'], dp['vel_y_rms'], dp['vel_z_rms'],
            dp['dis_x_pp'], dp['dis_y_pp'], dp['dis_z_pp']);
        outputLs.add(data);
      });
    }
    print(outputLs.length);

    setState(() {
      var axisDataLs = getTimeDataList(outputLs);
      accData = axisDataLs[0];
      velData = axisDataLs[1];
      disData = axisDataLs[2];
    });

    return outputLs;
  }
}

List<List<TimeData>> getTimeDataList(sensorDataLs) {
  TimeData acc_x = TimeData(name: 'ACC-x', timeList: [], values: []);
  TimeData acc_y = TimeData(name: 'ACC-y', timeList: [], values: []);
  TimeData acc_z = TimeData(name: 'ACC-z', timeList: [], values: []);

  TimeData vel_x = TimeData(name: 'VEL-x', timeList: [], values: []);
  TimeData vel_y = TimeData(name: 'VEL-y', timeList: [], values: []);
  TimeData vel_z = TimeData(name: 'VEL-z', timeList: [], values: []);

  TimeData dis_x = TimeData(name: 'DIS-x', timeList: [], values: []);
  TimeData dis_y = TimeData(name: 'DIS-y', timeList: [], values: []);
  TimeData dis_z = TimeData(name: 'DIS-z', timeList: [], values: []);

  List.generate(sensorDataLs.length, (index) {
    DateTime time = sensorDataLs[index].time;
    acc_x.timeList.add(time);
    acc_y.timeList.add(time);
    acc_z.timeList.add(time);
    acc_x.values.add(sensorDataLs[index].acc_x_pp);
    acc_y.values.add(sensorDataLs[index].acc_y_pp);
    acc_z.values.add(sensorDataLs[index].acc_z_pp);

    vel_x.timeList.add(time);
    vel_y.timeList.add(time);
    vel_z.timeList.add(time);
    vel_x.values.add(sensorDataLs[index].vel_x_rms);
    vel_y.values.add(sensorDataLs[index].vel_y_rms);
    vel_z.values.add(sensorDataLs[index].vel_z_rms);

    dis_x.timeList.add(time);
    dis_y.timeList.add(time);
    dis_z.timeList.add(time);
    dis_x.values.add(sensorDataLs[index].dis_x_pp);
    dis_y.values.add(sensorDataLs[index].dis_y_pp);
    dis_z.values.add(sensorDataLs[index].dis_z_pp);
  });

  return [
    [acc_x, acc_y, acc_z],
    [vel_x, vel_y, vel_z],
    [dis_x, dis_y, dis_z],
  ];
}

class AxisTheme {
  static charts.RenderSpec<num> axisThemeNum() {
    return charts.GridlineRendererSpec(
      labelStyle: charts.TextStyleSpec(
        color: charts.MaterialPalette.red.shadeDefault,
      ),
      lineStyle: charts.LineStyleSpec(
        color: charts.MaterialPalette.red.shadeDefault,
      ),
    );
  }

  static charts.RenderSpec<DateTime> axisThemeDateTime() {
    return charts.GridlineRendererSpec(
      labelStyle: charts.TextStyleSpec(
        color: charts.MaterialPalette.gray.shade500,
      ),
      lineStyle: charts.LineStyleSpec(
        color: charts.MaterialPalette.transparent,
      ),
    );
  }
}
