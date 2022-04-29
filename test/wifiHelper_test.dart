import 'package:flutter_test/flutter_test.dart';
import 'package:ssmflutter/Networks/WifiHelper.dart';

void main() {
  test('init-Test', () async {
    getCurrentSSID().then((value) => print(value));
  });
}
