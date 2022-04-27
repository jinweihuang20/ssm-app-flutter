import 'dart:math';

import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:ssmflutter/Chartslb/ISOPlugin.dart';

class TimeLineChart extends StatefulWidget {
  TimeLineChart(
      {Key? key,
      required this.title,
      this.yAxisTitle = "Y-Title",
      required this.dataSetList,
      this.showLegend = true,
      this.chartISOProperty =
          const ChartISOProperty(showIso: false, isoType: 1)})
      : super(key: key);
  final String title;
  final String yAxisTitle;
  final List<TimeData> dataSetList;
  final bool showLegend;
  final ChartISOProperty chartISOProperty;

  _TimeLineChartState state = _TimeLineChartState();

  @override
  State<TimeLineChart> createState() => state;
}

class _TimeLineChartState extends State<TimeLineChart> {
  ChartTitle<DateTime> xAxisTitle = ChartTitle('title');
  var axis = charts.NumericAxisSpec(
      showAxisLine: true,
      tickProviderSpec: const NumericEndPointsTickProviderSpec(),
      renderSpec: charts.GridlineRendererSpec(
          labelStyle: const charts.TextStyleSpec(
              fontSize: 10, color: charts.MaterialPalette.white),
          axisLineStyle: LineStyleSpec(
              thickness: 1,
              color: charts.MaterialPalette.gray.shadeDefault),
          lineStyle: charts.LineStyleSpec(
              thickness: 0,
              color: charts.MaterialPalette.gray.shadeDefault)));

  var axisTime = const charts.DateTimeAxisSpec(
      showAxisLine: true,
      tickProviderSpec: DateTimeEndPointsTickProviderSpec(),
      renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
              fontSize: 10, color: charts.MaterialPalette.white),
          axisLineStyle: LineStyleSpec(
              thickness: 1, color: charts.MaterialPalette.white),
          lineStyle: charts.LineStyleSpec(
              thickness: 1, color: charts.MaterialPalette.white)));

  List<ChartBehavior<DateTime>> _creatBehaviors() {
    List<ChartBehavior<DateTime>> behaviors = [];
    List<ChartBehavior<DateTime>> titlesBehavios = [
      charts.SeriesLegend(
          position: charts.BehaviorPosition.bottom,
          showMeasures: true),
      charts.ChartTitle(widget.title,
          behaviorPosition: BehaviorPosition.top,
          titleStyleSpec: const TextStyleSpec(
              color: charts.MaterialPalette.white)),
      charts.ChartTitle('Time',
          behaviorPosition: charts.BehaviorPosition.bottom,
          titleStyleSpec: const charts.TextStyleSpec(
              fontSize: 14, color: charts.MaterialPalette.white)),
      charts.ChartTitle(widget.yAxisTitle,
          behaviorPosition: charts.BehaviorPosition.start,
          titleStyleSpec: const charts.TextStyleSpec(
              fontSize: 14, color: charts.MaterialPalette.white)),
    ];

    if (widget.chartISOProperty.showIso) {
      behaviors.add(iSORangeAnnotationForDateTimeAxis(
          widget.chartISOProperty.isoType));
    }
    behaviors.addAll(titlesBehavios);

    return behaviors;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: charts.TimeSeriesChart(
        widget.dataSetList.isEmpty
            ? getDefual()
            : _genSeriesDataList(widget.dataSetList),
        animate: false,
        behaviors: _creatBehaviors(),
        domainAxis: axisTime,
        primaryMeasureAxis: axis,
      ),
    );
  }

  List<Series<dynamic, DateTime>> getDefual() {
    List<DateTime> timeList = [];
    List<double> values = [];

    for (var i = 0; i < 0; i++) {
      timeList.add(DateTime.now().add(Duration(seconds: i)));
      values.add(Random().nextDouble());
    }

    TimeData s1Data = TimeData(
        name: 'X',
        timeList: timeList,
        values: values,
        color: MaterialPalette.blue.shadeDefault);
    TimeData s2Data = TimeData(
        name: 'Y',
        timeList: timeList,
        values: values,
        color: MaterialPalette.red.shadeDefault);
    TimeData s3Data = TimeData(
        name: 'Z',
        timeList: timeList,
        values: values,
        color: MaterialPalette.yellow.shadeDefault);

    return _genSeriesDataList([s1Data, s2Data, s3Data]);
  }
}

class TimeData {
  ///series名稱
  String name;
  List<DateTime> timeList;
  List<double> values;
  Color color;
  TimeData(
      {required this.name,
      required this.timeList,
      required this.values,
      required this.color});
}

List<Series<TimeSeriesPt, DateTime>> _genSeriesDataList(
    List<TimeData> userDataSetList) {
  List<Series<TimeSeriesPt, DateTime>> seriesList = [];

  List.generate(
      userDataSetList.length,
      (index) =>
          {seriesList.add(_genSeriesData(userDataSetList[index]))});

  return seriesList;
}

Series<TimeSeriesPt, DateTime> _genSeriesData(TimeData userData) {
  List<TimeSeriesPt> ptList = [];
  List.generate(
      userData.timeList.length,
      (index) => {
            ptList.add(TimeSeriesPt(userData.timeList[index],
                userData.values[index], userData.color))
          });

  Series<TimeSeriesPt, DateTime> series = Series(
      id: userData.name,
      data: ptList,
      colorFn: (TimeSeriesPt accpet, _) => accpet.color,
      domainFn: (TimeSeriesPt accpet, _) => accpet.time,
      measureFn: (TimeSeriesPt accpet, _) => accpet.value);

  return series;
}

class TimeSeriesPt {
  final DateTime time;
  final double value;
  final Color color;

  TimeSeriesPt(this.time, this.value, this.color);
}
