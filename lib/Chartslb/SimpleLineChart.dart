import 'dart:math';
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:ssmflutter/Chartslb/ISOPlugin.dart';

class SimpleLineChart extends StatefulWidget {
  const SimpleLineChart(
      {Key? key,
      required this.dataSetList,
      this.title = "title",
      this.xAxistTitle = 'xTitle',
      this.yAxisTitle = "yTitle",
      this.showLegend = true,
      this.showTitle = true,
      this.useNumericEndPointsTickProviderSpec = false,
      this.ledgenPosition = charts.BehaviorPosition.inside,
      this.showZoomOutButton = false,
      this.zoomButtonOnClick,
      this.showISO = false})
      : super(key: key);
  final String title;
  final String yAxisTitle;
  final String xAxistTitle;
  final List<SimpleData> dataSetList;
  final bool showLegend;
  final bool useNumericEndPointsTickProviderSpec;
  final bool showTitle;
  final charts.BehaviorPosition ledgenPosition;
  final Function()? zoomButtonOnClick;
  final bool showZoomOutButton;
  final bool showISO;
  @override
  State<SimpleLineChart> createState() => _SimpleLineChartState();
}

class _SimpleLineChartState extends State<SimpleLineChart> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    var axis = charts.NumericAxisSpec(
        showAxisLine: true,
        tickProviderSpec: widget.useNumericEndPointsTickProviderSpec ? const NumericEndPointsTickProviderSpec() : null,
        renderSpec: const charts.GridlineRendererSpec(
            labelStyle: charts.TextStyleSpec(fontSize: 10, color: charts.MaterialPalette.white),
            axisLineStyle: LineStyleSpec(thickness: 1, color: charts.MaterialPalette.white),
            lineStyle: charts.LineStyleSpec(thickness: 1, color: charts.MaterialPalette.white)));

    List<ChartBehavior<num>> titlesBehavios = [
      charts.SeriesLegend(position: widget.ledgenPosition, showMeasures: true),
      charts.ChartTitle(widget.showTitle ? widget.title : "",
          outerPadding: 22, behaviorPosition: BehaviorPosition.top, titleStyleSpec: const TextStyleSpec(color: charts.MaterialPalette.white, lineHeight: 1)),
      charts.ChartTitle(widget.xAxistTitle,
          behaviorPosition: charts.BehaviorPosition.bottom, titleStyleSpec: const charts.TextStyleSpec(fontSize: 14, color: charts.MaterialPalette.white)),
      charts.ChartTitle(widget.yAxisTitle,
          behaviorPosition: charts.BehaviorPosition.start, titleStyleSpec: const charts.TextStyleSpec(fontSize: 14, color: charts.MaterialPalette.white))
    ];

    List<ChartBehavior<num>> behaviors = [];
    if (widget.showISO) {
      behaviors.add(iSORangeAnnotation());
    }
    behaviors.addAll(titlesBehavios);

    var chart = charts.LineChart(
      // widget.dataSetList.isEmpty ? getDefual() : _genSeriesDataList(widget.dataSetList),
      widget.dataSetList.isEmpty ? getDefual() : _genSeriesDataList(widget.dataSetList),
      animate: false,
      behaviors: behaviors,
      domainAxis: axis,
      primaryMeasureAxis: axis,
    );

    var zoomWidget = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
            alignment: Alignment.topRight,
            onPressed: widget.zoomButtonOnClick,
            icon: const Icon(
              Icons.zoom_out_map_sharp,
              size: 18,
            ))
      ],
    );
    if (widget.showZoomOutButton) {
      return Center(
        child: Card(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(),
          child: Stack(
            children: [zoomWidget, chart],
          ),
        ),
      );
    } else {
      return chart;
    }
  }
}

List<Series<dynamic, double>> getDefual() {
  List<double> xList = [];
  List<double> values = [];

  for (var i = 0; i < 0; i++) {
    xList.add(i.toDouble());
    values.add(Random().nextDouble());
  }

  SimpleData s1Data = SimpleData('X', xList, values);
  SimpleData s2Data = SimpleData('Y', xList, values);
  SimpleData s3Data = SimpleData('Z', xList, values);

  return _genSeriesDataList([s1Data, s2Data, s3Data]);
}

List<Series<SimpleSeriesPt, double>> _genSeriesDataList(List<SimpleData> userDataSetList) {
  List<Series<SimpleSeriesPt, double>> seriesList = [];

  List.generate(userDataSetList.length, (index) => {seriesList.add(_genSeriesData(userDataSetList[index]))});

  return seriesList;
}

Series<SimpleSeriesPt, double> _genSeriesData(SimpleData userData) {
  List<SimpleSeriesPt> ptList = [];
  List.generate(userData.xList.length, (index) => {ptList.add(SimpleSeriesPt(userData.xList[index], userData.values[index]))});

  Series<SimpleSeriesPt, double> series =
      Series(id: userData.name, data: ptList, domainFn: (SimpleSeriesPt accpet, _) => accpet.xval, measureFn: (SimpleSeriesPt accpet, _) => accpet.value);
  return series;
}

class SimpleData {
  ///series名稱
  String name;
  List<double> xList;
  List<double> values;
  SimpleData(this.name, this.xList, this.values);
}

class SimpleSeriesPt {
  final double xval;
  final double value;

  SimpleSeriesPt(this.xval, this.value);
}
