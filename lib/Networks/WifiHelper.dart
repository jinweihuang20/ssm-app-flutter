///Get or set wifi informatrion or setting.
///
///
import 'package:wifi_iot/wifi_iot.dart';

bool _isEnabled = false;

Future<String> getSSID() async {
  var ssid = await WiFiForIoTPlugin.getSSID();
  print(ssid);
  return ssid!;
}
