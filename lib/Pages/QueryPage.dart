// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:ssmflutter/Chartslb/ISOPlugin.dart';
import 'package:ssmflutter/Database/SensorData.dart';
import '../Chartslb/TimeLineChart.dart';
import '../Database/SqliteAPI.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../MyWidget/Buttons.dart';

class QueryPage extends StatefulWidget {
  QueryPage({Key? key}) : super(key: key);

  _QueryPage state = _QueryPage();
  @override
  State<QueryPage> createState() => state;
}

class _QueryPage extends State<QueryPage>
    with AutomaticKeepAliveClientMixin {
  int _minQueryNow = 5;

  final Color _activeBtnColor = const Color.fromARGB(255, 21, 64, 93);
  final Color _nonActiveBtnColor = Colors.grey;

  Map<int, Color> buttonColorMap = <int, Color>{
    5: const Color.fromARGB(255, 21, 64, 93),
    10: Colors.grey,
    30: Colors.grey,
  };

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    var btnStyle = ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith(
      (Set<MaterialState> states) {
        print(states);
        if (states.contains(MaterialState.pressed)) return Colors.red;
        return Colors.green; // Use the component's default.
      },
    ));

    void queryData(int min) {
      setState(() {
        buttonColorMap[5] = _nonActiveBtnColor;
        buttonColorMap[10] = _nonActiveBtnColor;
        buttonColorMap[30] = _nonActiveBtnColor;
        buttonColorMap[min] = _activeBtnColor;
      });
      _minQueryNow = min;
      endTime = DateTime.now();
      startTime = endTime.add(Duration(minutes: -min));
      query();
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Padding(padding: EdgeInsets.only(top: 20)),
          Row(
            children: [
              Expanded(
                  child: iconButton(
                      text: '過去5分鐘',
                      onPressed: () {
                        queryData(5);
                      },
                      color: buttonColorMap[5]!)),
              Expanded(
                  child: iconButton(
                      text: '過去10分鐘',
                      onPressed: () {
                        queryData(10);
                      },
                      color: buttonColorMap[10]!)),
              Expanded(
                  child: iconButton(
                      text: '過去30分鐘',
                      onPressed: () {
                        queryData(30);
                      },
                      color: buttonColorMap[30]!))
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
              chartISOProperty:
                  ChartISOProperty(showIso: true, isoType: 1),
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

  List<charts.Series<TimeSeriesPt, DateTime>> acc_data_seriseLs = [];
  List<charts.Series<TimeSeriesPt, DateTime>> vel_data_seriseLs = [];
  List<charts.Series<TimeSeriesPt, DateTime>> dis_data_seriseLs = [];

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
    List<Map<String, dynamic>> ls =
        await API.queryOutWithTimeInterval(startTime, endTime);
    int? len = ls.length;

    if (len != 0) {
      List.generate(len, (i) {
        var dp = ls[i];
        SensorData data = SensorData(
            DateTime.parse(dp['time']),
            dp['acc_x_pp'],
            dp['acc_y_pp'],
            dp['acc_z_pp'],
            dp['vel_x_rms'],
            dp['vel_y_rms'],
            dp['vel_z_rms'],
            dp['dis_x_pp'],
            dp['dis_y_pp'],
            dp['dis_z_pp']);
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
  final xAxisColor = charts.MaterialPalette.blue.shadeDefault;
  final yAxisColor = charts.MaterialPalette.red.shadeDefault;
  final zAxisColor = charts.MaterialPalette.yellow.shadeDefault;

  TimeData acc_x = TimeData(
      name: 'ACC-x', timeList: [], values: [], color: xAxisColor);
  TimeData acc_y = TimeData(
      name: 'ACC-y', timeList: [], values: [], color: yAxisColor);
  TimeData acc_z = TimeData(
      name: 'ACC-z', timeList: [], values: [], color: zAxisColor);

  TimeData vel_x = TimeData(
      name: 'VEL-x', timeList: [], values: [], color: xAxisColor);
  TimeData vel_y = TimeData(
      name: 'VEL-y', timeList: [], values: [], color: yAxisColor);
  TimeData vel_z = TimeData(
      name: 'VEL-z', timeList: [], values: [], color: zAxisColor);

  TimeData dis_x = TimeData(
      name: 'DIS-x', timeList: [], values: [], color: xAxisColor);
  TimeData dis_y = TimeData(
      name: 'DIS-y', timeList: [], values: [], color: yAxisColor);
  TimeData dis_z = TimeData(
      name: 'DIS-z', timeList: [], values: [], color: zAxisColor);

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
