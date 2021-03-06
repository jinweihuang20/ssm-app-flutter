import 'package:fft/fft.dart';
import 'dart:math' as math;

List<double> toFFT(List<double> data) {
  List<double> fftOut = [];
  var fft = FFT().Transform(data);
  fft[0] = Complex.ZERO;
  for (var i = 0; i < fft.length / 2; i++) {
    var d = fft[i].modulus.toDouble();
    fftOut.add(d);
  }
  return fftOut;
}

double toOA(List<double> fftData) {
  double sum = 0;
  for (var i = 0; i < fftData.length; i++) {
    sum += math.pow(fftData[i], 2);
  }
  return 0.8165 * math.sqrt(sum);
}

double toRMS(List<double> data) {
  double sum = 0;
  int len = data.length;
  for (var i = 0; i < len; i++) {
    sum += math.pow(data[i], 2);
  }
  return math.sqrt(sum / len);
}

double toP2P(List<double> data) {
  double max = -99999.0;
  double min = 99999.0;
  for (var i = 0; i < data.length; i++) {
    max = math.max(max, data[i]);
    min = math.min(min, data[i]);
  }
  return max - min;
}

///速度量
List<double> toVelocityList(List<double> accList, double sampingRate) {
  List<double> grmedLs = _removeGravity(accList);

  List<double> gmms2 = [];

  List.generate(grmedLs.length, (index) => gmms2.add(grmedLs[index] * 9.81 * 1000)); //G=>mm/s^2

  List<double> ve = _removeGravity(_trapezoidalAreaMethodSeriesOut(gmms2, sampingRate));
  return ve;
}

///位移量
List<double> toDisplacementList(List<double> velList, double sampingRate) {
  List<double> dis = _removeGravity(_trapezoidalAreaMethodSeriesOut(velList, sampingRate));
  List<double> umList = [];
  List.generate(dis.length, (index) => umList.add(dis[index] * 1000)); //mm=>um

  return dis;
}

List<double> _removeGravity(List<double> accAry) {
  double sum = 0;
  int len = accAry.length;
  List<double> gRemovedLs = [];
  for (var i = 0; i < len; i++) {
    sum += accAry[i];
  }
  double avg = sum / len;
  for (var i = 0; i < len; i++) {
    gRemovedLs.add(accAry[i] - avg);
  }
  return gRemovedLs;
}

List<double> _trapezoidalAreaMethodSeriesOut(List<double> dataAry, double sampingRate) {
  double h = 1 / sampingRate;
  double area0 = 0;
  List<double> trapeziodLs = [];
  trapeziodLs.add(0);
  for (var i = 1; i < dataAry.length; i++) {
    double a1 = dataAry[i - 1];
    double a2 = dataAry[i];
    double area = (a1 + a2) * h / 2;
    area0 += area;
    trapeziodLs.add(area0);
  }
  return trapeziodLs;
}
