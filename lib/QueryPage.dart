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
import 'Storage/Caches.dart';

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
            TrendChart(
                title: '位移量-P2P', seriseLs: dis_data_seriseLs, unit: 'um')
          ],
        ),
      ),
    );
  }

  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  String timeSelectFor = 'start'; //'end'

  List<Series<SeriesPt, DateTime>> acc_data_seriseLs = [];
  List<Series<SeriesPt, DateTime>> vel_data_seriseLs = [];
  List<Series<SeriesPt, DateTime>> dis_data_seriseLs = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      acc_data_seriseLs = QueryCache.queryOutDataSet.acc_data_seriseLs;
      vel_data_seriseLs = QueryCache.queryOutDataSet.vel_data_seriseLs;
      dis_data_seriseLs = QueryCache.queryOutDataSet.dis_data_seriseLs;
    });
  }

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

    setState(() {
      SeriesCollection collection = SeriesCollection(outputLs);
      SeriesLsToRender dataSet = collection.getSerisesToRender();

      acc_data_seriseLs = dataSet.acc_data_seriseLs;
      vel_data_seriseLs = dataSet.vel_data_seriseLs;
      dis_data_seriseLs = dataSet.dis_data_seriseLs;
      QueryCache.queryOutDataSet = dataSet;
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

  SeriesLsToRender getSerisesToRender() {
    List<Series<SeriesPt, DateTime>> accDataSeriseLs = [];
    List<Series<SeriesPt, DateTime>> velDataSeriseLs = [];
    List<Series<SeriesPt, DateTime>> disDataSeriseLs = [];

    List<SeriesPt> accXLs = [];
    List<SeriesPt> accYLs = [];
    List<SeriesPt> accZLs = [];
    List<SeriesPt> velXLs = [];
    List<SeriesPt> velYLs = [];
    List<SeriesPt> velZLs = [];
    List<SeriesPt> disXLs = [];
    List<SeriesPt> disYLs = [];
    List<SeriesPt> disZLs = [];
    List.generate(sensorDataLs.length, (index) {
      var dataSet = sensorDataLs[index];
      DateTime time = dataSet.time;

      accXLs.add(SeriesPt(time, dataSet.acc_x_pp));
      accYLs.add(SeriesPt(time, dataSet.acc_y_pp));
      accZLs.add(SeriesPt(time, dataSet.acc_z_pp));

      velXLs.add(SeriesPt(time, dataSet.vel_x_rms));
      velYLs.add(SeriesPt(time, dataSet.vel_y_rms));
      velZLs.add(SeriesPt(time, dataSet.vel_z_rms));

      disXLs.add(SeriesPt(time, dataSet.dis_x_pp));
      disYLs.add(SeriesPt(time, dataSet.dis_y_pp));
      disZLs.add(SeriesPt(time, dataSet.dis_z_pp));
    });

    Series<SeriesPt, DateTime> accXSeries = Series(
        id: 'X',
        data: accXLs,
        domainFn: (SeriesPt accpet, _) => accpet.time,
        measureFn: (SeriesPt accpet, _) => accpet.value);
    Series<SeriesPt, DateTime> accYSeries = Series(
        id: 'Y',
        data: accYLs,
        domainFn: (SeriesPt accpet, _) => accpet.time,
        measureFn: (SeriesPt accpet, _) => accpet.value);
    Series<SeriesPt, DateTime> accZSeries = Series(
        id: 'Z',
        data: accZLs,
        domainFn: (SeriesPt accpet, _) => accpet.time,
        measureFn: (SeriesPt accpet, _) => accpet.value);

    accDataSeriseLs.add(accXSeries);
    accDataSeriseLs.add(accYSeries);
    accDataSeriseLs.add(accZSeries);

    Series<SeriesPt, DateTime> velXSeries = Series(
        id: 'X',
        data: velXLs,
        domainFn: (SeriesPt accpet, _) => accpet.time,
        measureFn: (SeriesPt accpet, _) => accpet.value);
    Series<SeriesPt, DateTime> velYSeries = Series(
        id: 'Y',
        data: velYLs,
        domainFn: (SeriesPt accpet, _) => accpet.time,
        measureFn: (SeriesPt accpet, _) => accpet.value);
    Series<SeriesPt, DateTime> velZSeries = Series(
        id: 'Z',
        data: velZLs,
        domainFn: (SeriesPt accpet, _) => accpet.time,
        measureFn: (SeriesPt accpet, _) => accpet.value);

    velDataSeriseLs.add(velXSeries);
    velDataSeriseLs.add(velYSeries);
    velDataSeriseLs.add(velZSeries);

    Series<SeriesPt, DateTime> disXSeries = Series(
        id: 'X',
        data: disXLs,
        domainFn: (SeriesPt accpet, _) => accpet.time,
        measureFn: (SeriesPt accpet, _) => accpet.value);
    Series<SeriesPt, DateTime> disYSeries = Series(
        id: 'Y',
        data: disYLs,
        domainFn: (SeriesPt accpet, _) => accpet.time,
        measureFn: (SeriesPt accpet, _) => accpet.value);
    Series<SeriesPt, DateTime> disZSeries = Series(
        id: 'Z',
        data: disZLs,
        domainFn: (SeriesPt accpet, _) => accpet.time,
        measureFn: (SeriesPt accpet, _) => accpet.value);

    disDataSeriseLs.add(disXSeries);
    disDataSeriseLs.add(disYSeries);
    disDataSeriseLs.add(disZSeries);

    return SeriesLsToRender(accDataSeriseLs, velDataSeriseLs, disDataSeriseLs);
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
