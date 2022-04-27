import 'package:flutter_test/flutter_test.dart';
import 'package:ssmflutter/Database/SensorData.dart';

void main() {
  test('json_test', () async {
    var data = SensorData(
        "127.0.0.1", DateTime.now(), 1, 1, 1, 1, 1, 1, 1, 1, 1);
    var json = data.toJson();
  });
}
