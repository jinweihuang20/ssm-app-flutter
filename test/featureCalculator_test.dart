// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:ssmflutter/MathLib/FeatureCalculator.dart';

void main() {
  test('p2p_test', () async {
    var p2p = toP2P([12.2, 23.2, 2, -1.3]);
    expect(24.5, p2p);
  });

  test('oa-test', () async {
    var oa = toOA([1, 2, 3]);
    print(oa);
    expect('3.06', oa.toStringAsFixed(2));
  });

  test('rms-test', () async {
    var rms = toRMS([
      32,
      231,
      3,
      1.23,
    ]);

    expect('116.61', rms.toStringAsFixed(2));
  });
}
