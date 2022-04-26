import 'package:flutter_test/flutter_test.dart';
import 'package:ssmflutter/Database/SensorData.dart';

void main() {
  test('json_test', () async {
    var data = SensorData(DateTime.now(), 1, 1, 1, 1, 1, 1, 1, 1, 1);
    var json = data.toJson();
  });
}
