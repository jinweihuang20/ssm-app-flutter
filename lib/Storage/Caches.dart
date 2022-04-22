import 'package:charts_flutter/flutter.dart';
import 'package:ssmflutter/Pages/QueryPage.dart';

class QueryCache {
  static SeriesLsToRender queryOutDataSet = SeriesLsToRender(
      [Series(id: 'Acc-X', data: [], domainFn: (SeriesPt accpet, _) => accpet.time, measureFn: (SeriesPt accpet, _) => accpet.value)],
      [Series(id: 'Acc-Y', data: [], domainFn: (SeriesPt accpet, _) => accpet.time, measureFn: (SeriesPt accpet, _) => accpet.value)],
      [Series(id: 'Acc-Z', data: [], domainFn: (SeriesPt accpet, _) => accpet.time, measureFn: (SeriesPt accpet, _) => accpet.value)]);
}
