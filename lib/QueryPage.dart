// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:path/path.dart';
import 'package:ssmflutter/Database/SensorData.dart';
import 'Chartslb/LineChart.dart';
import 'Database/SqliteAPI.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class QueryPage extends StatefulWidget {
  const QueryPage({Key? key}) : super(key: key);

  @override
  State<QueryPage> createState() => _QueryPage();
}

class _QueryPage extends State<QueryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Data Query'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Padding(padding: EdgeInsets.only(top: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: queryLastFiveMinData,
                    child: const Text('過去5分鐘')),
                ElevatedButton(
                    onPressed: queryLastTenMinData,
                    child: const Text('過去10分鐘')),
                ElevatedButton(
                    onPressed: queryLastThirtyMinData,
                    child: const Text('過去30分鐘'))
              ],
            ),
            const Divider(),
            TrendChart(
              title: '加速度-PP',
              seriseLs: acc_data_seriseLs,
              unit: 'G',
            ),
            const Divider(),
            TrendChart(
                title: '速度-RMS', seriseLs: vel_data_seriseLs, unit: 'mm/s'),
            const Divider(),
            TrendChart(title: '位移量-P2P', seriseLs: dis_data_seriseLs, unit: 'um')
          ],
        ),
      ),
    );
  }

  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  String timeSelectFor = 'start'; //'end'

  List<Series<SeriesPt, DateTime>> acc_data_seriseLs = [
    Series(
        id: 'Acc-X',
        data: [],
        domainFn: (SeriesPt accpet, _) => accpet.time,
        measureFn: (SeriesPt accpet, _) => accpet.value)
  ];
  List<Series<SeriesPt, DateTime>> vel_data_seriseLs = [
    Series(
        id: 'Acc-Y',
        data: [],
        domainFn: (SeriesPt accpet, _) => accpet.time,
        measureFn: (SeriesPt accpet, _) => accpet.value)
  ];
  List<Series<SeriesPt, DateTime>> dis_data_seriseLs = [
    Series(
        id: 'Acc-Z',
        data: [],
        domainFn: (SeriesPt accpet, _) => accpet.time,
        measureFn: (SeriesPt accpet, _) => accpet.value)
  ];
  @override
  void dispose() {
    super.dispose();
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
    print(outputLs.last.time);

    setState(() {
      SeriesCollection collection = SeriesCollection(outputLs);
      var set = collection.GetSerisesToRender();
      acc_data_seriseLs = set.acc_data_seriseLs;
      vel_data_seriseLs = set.vel_data_seriseLs;
      dis_data_seriseLs = set.dis_data_seriseLs;
    });

    return outputLs;
  }
}

class TrendChart extends StatefulWidget {
  const TrendChart(
      {Key? key,
      required this.title,
      required this.seriseLs,
      required this.unit})
      : super(key: key);
  final List<Series<SeriesPt, DateTime>> seriseLs;
  final String title;
  final String unit;
  @override
  State<TrendChart> createState() => _TrendChartState();
}

class _TrendChartState extends State<TrendChart> {
  var measures_result_string = 'Time\r\nX:-1\r\nY:-1\r\n:Z:-1';

  @override
  Widget build(BuildContext context) {
    charts.RenderSpec<num> renderSpecPrimary = AxisTheme.axisThemeNum();
    charts.RenderSpec<DateTime> renderSpecDomain =
        AxisTheme.axisThemeDateTime();

    _onSelectionChanged(charts.SelectionModel model) {
      final selectedDatum = model.selectedDatum;
      DateTime time = DateTime(0);
      final measures = <String, num>{};
      if (selectedDatum.isNotEmpty) {
        time = selectedDatum.first.datum.time;
        selectedDatum.forEach((charts.SeriesDatum datumPair) {
          measures[datumPair.series.displayName!] = datumPair.datum.value;
        });
      }
      // Request a build.
      setState(() {
        measures_result_string = time.toIso8601String() + '\r\n';
        print(measures);
        var xVal = measures['X'];
        var yVal = measures['Y'];
        var zVal = measures['Z'];
        measures_result_string += "X:$xVal" + widget.unit + "\r\n";
        measures_result_string += "Y:$yVal" + widget.unit + "\r\n";
        measures_result_string += "Z:$zVal" + widget.unit + "\r\n";
      });
    }

    return Center(
        child: Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 200,
          child: charts.TimeSeriesChart(
            widget.seriseLs,
            animate: false,
            primaryMeasureAxis: charts.NumericAxisSpec(
              renderSpec: charts.SmallTickRendererSpec(
                labelStyle: TextStyleSpec(color: charts.MaterialPalette.white),
                axisLineStyle:
                    LineStyleSpec(color: charts.MaterialPalette.gray.shade500),
              ),
            ),
            domainAxis: DateTimeAxisSpec(renderSpec: renderSpecDomain),
            behaviors: [
              charts.SeriesLegend(position: charts.BehaviorPosition.top),
              charts.ChartTitle(widget.title,
                  behaviorPosition: BehaviorPosition.top,
                  titleStyleSpec: TextStyleSpec(
                      color: charts.MaterialPalette.white.darker)),
              charts.ChartTitle('Time',
                  behaviorPosition: charts.BehaviorPosition.bottom,
                  titleStyleSpec: const charts.TextStyleSpec(
                      fontSize: 14, color: charts.MaterialPalette.white)),
              charts.ChartTitle(widget.unit,
                  behaviorPosition: charts.BehaviorPosition.start,
                  titleStyleSpec: const charts.TextStyleSpec(
                      fontSize: 14, color: charts.MaterialPalette.white))
            ],
            selectionModels: [
              charts.SelectionModelConfig(
                type: charts.SelectionModelType.info,
                changedListener: _onSelectionChanged,
              )
            ],
          ),
        ),
        Center(
          child: Text('$measures_result_string'),
        )
      ],
    ));
  }
}

class SeriesPt {
  final DateTime time;
  final double value;

  SeriesPt(this.time, this.value);
}

class SeriesCollection {
  SeriesCollection(this.sensorDataLs);
  final List<SensorData> sensorDataLs;

  SeriesLsToRender GetSerisesToRender() {
    List<Series<SeriesPt, DateTime>> acc_data_seriseLs = [];
    List<Series<SeriesPt, DateTime>> vel_data_seriseLs = [];
    List<Series<SeriesPt, DateTime>> dis_data_seriseLs = [];

    List<SeriesPt> acc_x_ls = [];
    List<SeriesPt> acc_y_ls = [];
    List<SeriesPt> acc_z_ls = [];
    List<SeriesPt> vel_x_ls = [];
    List<SeriesPt> vel_y_ls = [];
    List<SeriesPt> vel_z_ls = [];
    List<SeriesPt> dis_x_ls = [];
    List<SeriesPt> dis_y_ls = [];
    List<SeriesPt> dis_z_ls = [];
    List.generate(sensorDataLs.length, (index) {
      var dataSet = sensorDataLs[index];
      DateTime time = dataSet.time;

      acc_x_ls.add(SeriesPt(time, dataSet.acc_x_pp));
      acc_y_ls.add(SeriesPt(time, dataSet.acc_y_pp));
      acc_z_ls.add(SeriesPt(time, dataSet.acc_z_pp));

      vel_x_ls.add(SeriesPt(time, dataSet.vel_x_rms));
      vel_y_ls.add(SeriesPt(time, dataSet.vel_y_rms));
      vel_z_ls.add(SeriesPt(time, dataSet.vel_z_rms));

      dis_x_ls.add(SeriesPt(time, dataSet.dis_x_pp));
      dis_y_ls.add(SeriesPt(time, dataSet.dis_y_pp));
      dis_z_ls.add(SeriesPt(time, dataSet.dis_z_pp));
    });

    Series<SeriesPt, DateTime> accXSeries = Series(
        id: 'X',
        data: acc_x_ls,
        domainFn: (SeriesPt accpet, _) => accpet.time,
        measureFn: (SeriesPt accpet, _) => accpet.value);
    Series<SeriesPt, DateTime> accYSeries = Series(
        id: 'Y',
        data: acc_y_ls,
        domainFn: (SeriesPt accpet, _) => accpet.time,
        measureFn: (SeriesPt accpet, _) => accpet.value);
    Series<SeriesPt, DateTime> accZSeries = Series(
        id: 'Z',
        data: acc_z_ls,
        domainFn: (SeriesPt accpet, _) => accpet.time,
        measureFn: (SeriesPt accpet, _) => accpet.value);

    acc_data_seriseLs.add(accXSeries);
    acc_data_seriseLs.add(accYSeries);
    acc_data_seriseLs.add(accZSeries);

    Series<SeriesPt, DateTime> velXSeries = Series(
        id: 'X',
        data: vel_x_ls,
        domainFn: (SeriesPt accpet, _) => accpet.time,
        measureFn: (SeriesPt accpet, _) => accpet.value);
    Series<SeriesPt, DateTime> velYSeries = Series(
        id: 'Y',
        data: vel_y_ls,
        domainFn: (SeriesPt accpet, _) => accpet.time,
        measureFn: (SeriesPt accpet, _) => accpet.value);
    Series<SeriesPt, DateTime> velZSeries = Series(
        id: 'Z',
        data: vel_z_ls,
        domainFn: (SeriesPt accpet, _) => accpet.time,
        measureFn: (SeriesPt accpet, _) => accpet.value);

    vel_data_seriseLs.add(velXSeries);
    vel_data_seriseLs.add(velYSeries);
    vel_data_seriseLs.add(velZSeries);

    Series<SeriesPt, DateTime> disXSeries = Series(
        id: 'X',
        data: dis_x_ls,
        domainFn: (SeriesPt accpet, _) => accpet.time,
        measureFn: (SeriesPt accpet, _) => accpet.value);
    Series<SeriesPt, DateTime> disYSeries = Series(
        id: 'Y',
        data: dis_y_ls,
        domainFn: (SeriesPt accpet, _) => accpet.time,
        measureFn: (SeriesPt accpet, _) => accpet.value);
    Series<SeriesPt, DateTime> disZSeries = Series(
        id: 'Z',
        data: dis_z_ls,
        domainFn: (SeriesPt accpet, _) => accpet.time,
        measureFn: (SeriesPt accpet, _) => accpet.value);

    dis_data_seriseLs.add(disXSeries);
    dis_data_seriseLs.add(disYSeries);
    dis_data_seriseLs.add(disZSeries);

    return SeriesLsToRender(
        acc_data_seriseLs, vel_data_seriseLs, dis_data_seriseLs);
  }
}

class SeriesLsToRender {
  SeriesLsToRender(
      this.acc_data_seriseLs, this.vel_data_seriseLs, this.dis_data_seriseLs);
  final List<Series<SeriesPt, DateTime>> acc_data_seriseLs;
  final List<Series<SeriesPt, DateTime>> vel_data_seriseLs;
  final List<Series<SeriesPt, DateTime>> dis_data_seriseLs;
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
