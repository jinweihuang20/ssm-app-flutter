import 'package:flutter_test/flutter_test.dart';
import 'package:ssmflutter/Database/SensorData.dart';
import 'package:ssmflutter/SSMModule/module.dart';

void main() {
  test('json_test', () async {
    List<double> gx = [1, 23, 4];
    List<double> gy = [3, 23, 4];
    List<double> gz = [4, 23, 4];
    Features features = Features();

    var data = SensorData(DateTime.now(), 1,1,1,1,1,1,1,1,1);
    var json = data.toJson();
    print(json);
  });
}
