import 'package:charts_flutter/flutter.dart';

class LinearSales {
  final DateTime time;
  final double value;

  LinearSales(this.time, this.value);
}

class AccPt {
  final int index;
  final double value;
  AccPt(this.index, this.value);
}

List<Series<AccPt, int>> GetAccRawSeries(
    List<double> accx, List<double> accy, List<double> accz) {
  List<Series<AccPt, int>> ls = [];
  Series<AccPt, int> series_accx = Series(
      id: 'accx',
      data: [],
      domainFn: (AccPt accpt, _) => accpt.index,
      measureFn: (AccPt accpt, _) => accpt.value);

  Series<AccPt, int> series_accy = Series(
      id: 'accy',
      data: [],
      domainFn: (AccPt accpt, _) => accpt.index,
      measureFn: (AccPt accpt, _) => accpt.value);

  Series<AccPt, int> series_accz = Series(
      id: 'accz',
      data: [],
      domainFn: (AccPt accpt, _) => accpt.index,
      measureFn: (AccPt accpt, _) => accpt.value);

  for (var i = 0; i < accx.length; i++) {
    series_accx.data.add(AccPt(i, accx[i]));
    series_accy.data.add(AccPt(i, accy[i]));
    series_accz.data.add(AccPt(i, accz[i]));
  }

  ls.add(series_accx);
  ls.add(series_accy);
  ls.add(series_accz);

  return ls;
}

class FFTPt {
  final double freqPt;
  final double mag;
  FFTPt(this.freqPt, this.mag);
}

List<Series<FFTPt, double>> GetFFTSeries(List<double> fftx, List<double> ffty,
    List<double> ffyz, double samplingRate) {
  double freqStep = samplingRate / 2 / fftx.length;
  List<Series<FFTPt, double>> ls = [];
  Series<FFTPt, double> series_accx = Series(
      id: 'FFT-X',
      data: [],
      domainFn: (FFTPt accpt, _) => accpt.freqPt,
      measureFn: (FFTPt accpt, _) => accpt.mag);

  Series<FFTPt, double> series_accy = Series(
      id: 'FFT-Y',
      data: [],
      domainFn: (FFTPt accpt, _) => accpt.freqPt,
      measureFn: (FFTPt accpt, _) => accpt.mag);

  Series<FFTPt, double> series_accz = Series(
      id: 'FFT-Z',
      data: [],
      domainFn: (FFTPt accpt, _) => accpt.freqPt,
      measureFn: (FFTPt accpt, _) => accpt.mag);

  for (var i = 0; i < fftx.length; i++) {
    series_accx.data.add(FFTPt(i * freqStep, fftx[i]));
    series_accy.data.add(FFTPt(i * freqStep, ffty[i]));
    series_accz.data.add(FFTPt(i * freqStep, ffyz[i]));
  }

  ls.add(series_accx);
  ls.add(series_accy);
  ls.add(series_accz);

  return ls;
}
