import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

// enum ISO10816{

// }

class ISORangeBound {
  double start = 0;
  double end = 0;
  ISORangeBound(this.start, this.end);
}

class ISO10816SPEC {
  ISORangeBound good = ISORangeBound(0, 23);
  ISORangeBound staisfactory = ISORangeBound(23, 43);
  ISORangeBound unstaisfactory = ISORangeBound(43, 53);
  ISORangeBound unacceptable = ISORangeBound(53, 123);
  ISO10816SPEC(List<double> ranges) {
    good.start = 0;
    good.end = staisfactory.start = ranges[0];
    staisfactory.end = unstaisfactory.start = ranges[1];
    unstaisfactory.end = unacceptable.start = ranges[2];
    unacceptable.end = ranges[3];
  }

  String getResult(double vel) {
    if (vel < good.end) {
      return "GOOD";
    } else if (vel < staisfactory.end) {
      return "Staisfactory";
    } else if (vel < unstaisfactory.end) {
      return "Unstaisfactory";
    } else {
      return "Unacceptable";
    }
  }
}

Map<dynamic, ISO10816SPEC> classSepcMap = <dynamic, ISO10816SPEC>{
  1: ISO10816SPEC([.71, 1.8, 4.5, 12]),
  2: ISO10816SPEC([1.12, 2.8, 7.1, 12]),
  3: ISO10816SPEC([1.8, 4.5, 11.2, 23]),
  4: ISO10816SPEC([2.8, 7.1, 18, 30]),
};

charts.ChartBehavior<num> iSORangeAnnotation([int _class = 1]) {
  return getNumRanAnnoByClassNum(_class);
}

charts.ChartBehavior<DateTime> iSORangeAnnotationForDateTimeAxis([int _class = 1]) {
  print('show iso type:$_class');
  return getRanAnnoByClassNum(_class);
}

charts.ChartBehavior<DateTime> getRanAnnoByClassNum(classNUmber) {
  double goodStart = classSepcMap[classNUmber]!.good.start;
  double goodEnd = classSepcMap[classNUmber]!.good.end;
  double staisfactoryStart = classSepcMap[classNUmber]!.staisfactory.start;
  double staisfactoryEnd = classSepcMap[classNUmber]!.staisfactory.end;
  double unstaisfactoryStart = classSepcMap[classNUmber]!.unstaisfactory.start;
  double unstaisfactoryEnd = classSepcMap[classNUmber]!.unstaisfactory.end;
  double unacceptableStart = classSepcMap[classNUmber]!.unacceptable.start;
  double unacceptableEnd = classSepcMap[classNUmber]!.unacceptable.end;

  return charts.RangeAnnotation([
    charts.RangeAnnotationSegment(goodStart, goodEnd, charts.RangeAnnotationAxisType.measure,
        endLabel: 'Good-$goodEnd', color: charts.MaterialPalette.green.shadeDefault),
    charts.RangeAnnotationSegment(staisfactoryStart, staisfactoryEnd, charts.RangeAnnotationAxisType.measure,
        endLabel: 'Staisfactory-$staisfactoryEnd', color: charts.MaterialPalette.yellow.shadeDefault),
    charts.RangeAnnotationSegment(unstaisfactoryStart, unstaisfactoryEnd, charts.RangeAnnotationAxisType.measure,
        endLabel: 'Unstaisfactory-$unstaisfactoryEnd', color: charts.MaterialPalette.deepOrange.shadeDefault),
    charts.RangeAnnotationSegment(unacceptableStart, unacceptableEnd, charts.RangeAnnotationAxisType.measure,
        endLabel: 'Unacceptable-$unacceptableEnd', color: charts.MaterialPalette.red.shadeDefault),
  ]);
}

charts.ChartBehavior<num> getNumRanAnnoByClassNum(classNUmber) {
  double goodStart = classSepcMap[classNUmber]!.good.start;
  double goodEnd = classSepcMap[classNUmber]!.good.end;
  double staisfactoryStart = classSepcMap[classNUmber]!.staisfactory.start;
  double staisfactoryEnd = classSepcMap[classNUmber]!.staisfactory.end;
  double unstaisfactoryStart = classSepcMap[classNUmber]!.unstaisfactory.start;
  double unstaisfactoryEnd = classSepcMap[classNUmber]!.unstaisfactory.end;
  double unacceptableStart = classSepcMap[classNUmber]!.unacceptable.start;
  double unacceptableEnd = classSepcMap[classNUmber]!.unacceptable.end;

  return charts.RangeAnnotation([
    charts.RangeAnnotationSegment(goodStart, goodEnd, charts.RangeAnnotationAxisType.measure,
        endLabel: 'Good-$goodEnd', color: charts.MaterialPalette.green.shadeDefault),
    charts.RangeAnnotationSegment(staisfactoryStart, staisfactoryEnd, charts.RangeAnnotationAxisType.measure,
        endLabel: 'Staisfactory-$staisfactoryEnd', color: charts.MaterialPalette.yellow.shadeDefault),
    charts.RangeAnnotationSegment(unstaisfactoryStart, unstaisfactoryEnd, charts.RangeAnnotationAxisType.measure,
        endLabel: 'Unstaisfactory-$unstaisfactoryEnd', color: charts.MaterialPalette.deepOrange.shadeDefault),
    charts.RangeAnnotationSegment(unacceptableStart, unacceptableEnd, charts.RangeAnnotationAxisType.measure,
        endLabel: 'Unacceptable-$unacceptableEnd', color: charts.MaterialPalette.red.shadeDefault),
  ]);
}

class ChartISOProperty {
  final bool showIso;
  final int isoType;
  const ChartISOProperty({required this.showIso, required this.isoType});
}
