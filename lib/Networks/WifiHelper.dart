// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:wifi_connector/wifi_connector.dart';
import 'package:wifi_iot/wifi_iot.dart';

Future<String> getCurrentSSID() async {
  var ssid = await WiFiForIoTPlugin.getSSID();
  print(ssid);
  return ssid!;
}

Future<List<String>> getSSIDList() async {
  List<String> ssidList = [];
  return ssidList;
}

Future<DeviceWifiInfo?> getDeviceWifiInfo() async {
  String? ip = await WiFiForIoTPlugin.getIP();
  String? ssid = await WiFiForIoTPlugin.getSSID();
  return DeviceWifiInfo(ip!, ssid!, "");
}

Future<DeviceWifiInfo> connectToSSSID(String ssid, String? password) async {
  bool connected = await WifiConnector.connectToWifi(ssid: ssid, password: password);
  DeviceWifiInfo? info = DeviceWifiInfo('ip', '<unknown ssid>', 'macAddress');
  String _ssid = '';
  while ((_ssid = (await getDeviceWifiInfo())!.ssid) == "<unknown ssid>") {}

  String _ip = "0.0.0.0";
  while (_ip == "0.0.0.0") {
    info = await getDeviceWifiInfo();
    _ip = info!.ip;
  }
  info?.connected = connected;
  return info!;
}

class DeviceWifiInfo {
  final String ssid;
  final String ip;
  final String macAddress;
  String state = "";
  bool connected = false;
  DeviceWifiInfo(this.ip, this.ssid, this.macAddress);

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'ssid': ssid});
    result.addAll({'ip': ip});
    result.addAll({'macAddress': macAddress});
    result.addAll({'connected': connected});

    return result;
  }

  factory DeviceWifiInfo.fromMap(Map<String, dynamic> map) {
    return DeviceWifiInfo(
      map['ssid'] ?? '',
      map['ip'] ?? '',
      map['macAddress'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory DeviceWifiInfo.fromJson(String source) => DeviceWifiInfo.fromMap(json.decode(source));
}
