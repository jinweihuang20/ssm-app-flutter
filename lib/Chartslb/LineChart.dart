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

List<Series<AccPt, int>> getAccRawSeries(List<double> accx, List<double> accy, List<double> accz) {
  List<Series<AccPt, int>> ls = [];
  Series<AccPt, int> seriesAccx = Series(id: 'accx', data: [], domainFn: (AccPt accpt, _) => accpt.index, measureFn: (AccPt accpt, _) => accpt.value);

  Series<AccPt, int> seriesAccy = Series(id: 'accy', data: [], domainFn: (AccPt accpt, _) => accpt.index, measureFn: (AccPt accpt, _) => accpt.value);

  Series<AccPt, int> seriesAccz = Series(id: 'accz', data: [], domainFn: (AccPt accpt, _) => accpt.index, measureFn: (AccPt accpt, _) => accpt.value);

  for (var i = 0; i < accx.length; i++) {
    seriesAccx.data.add(AccPt(i, accx[i]));
    seriesAccy.data.add(AccPt(i, accy[i]));
    seriesAccz.data.add(AccPt(i, accz[i]));
  }

  ls.add(seriesAccx);
  ls.add(seriesAccy);
  ls.add(seriesAccz);

  return ls;
}

class FFTPt {
  final double freqPt;
  final double mag;
  FFTPt(this.freqPt, this.mag);
}

List<Series<FFTPt, double>> getFFTSeries(List<double> fftx, List<double> ffty, List<double> ffyz, double samplingRate) {
  double freqStep = samplingRate / 2 / fftx.length;
  List<Series<FFTPt, double>> ls = [];
  Series<FFTPt, double> seriesAccx = Series(id: 'FFT-X', data: [], domainFn: (FFTPt accpt, _) => accpt.freqPt, measureFn: (FFTPt accpt, _) => accpt.mag);

  Series<FFTPt, double> seriesAccy = Series(id: 'FFT-Y', data: [], domainFn: (FFTPt accpt, _) => accpt.freqPt, measureFn: (FFTPt accpt, _) => accpt.mag);

  Series<FFTPt, double> seriesAccz = Series(id: 'FFT-Z', data: [], domainFn: (FFTPt accpt, _) => accpt.freqPt, measureFn: (FFTPt accpt, _) => accpt.mag);

  for (var i = 0; i < fftx.length; i++) {
    seriesAccx.data.add(FFTPt(i * freqStep, fftx[i]));
    seriesAccy.data.add(FFTPt(i * freqStep, ffty[i]));
    seriesAccz.data.add(FFTPt(i * freqStep, ffyz[i]));
  }

  ls.add(seriesAccx);
  ls.add(seriesAccy);
  ls.add(seriesAccz);

  return ls;
}
