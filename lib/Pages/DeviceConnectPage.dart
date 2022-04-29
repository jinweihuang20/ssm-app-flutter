// ignore_for_file: no_logic_in_create_state, must_be_immutable, avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ssmflutter/Networks/WifiHelper.dart';
import 'package:ssmflutter/SSMModule/MeasureRangeDropDownBtn.dart';
import '../QRCode/QRSacnWidget.dart';
import '../SSMModule/module.dart';
import '../SysSetting.dart';

class DeviceConnectPage extends StatefulWidget {
  DeviceConnectPage({Key? key, required this.ssmModuleOnConnect, this.ip = "127.0.0.1", this.port = 5000, this.connected = false}) : super(key: key);

  final String ip;
  final int port;
  final bool connected;
  final Function(SSMConnectState) ssmModuleOnConnect;
  var state = _DeviceConnectPageState();

  @override
  State<DeviceConnectPage> createState() => state;
}

class _DeviceConnectPageState extends State<DeviceConnectPage> with AutomaticKeepAliveClientMixin {
  static String _ipAddress = '192.168.0.68';
  static int _port = 5000;
  var _ipTextFieldController = TextEditingController(text: '192.168.0.68');
  var _portTextFieldController = TextEditingController(text: '5000');
  var stateWidget;
  var connectBtnText = "連線";
  var connectBtnBgColor = Colors.blue;
  final TextStyle titleStyle = const TextStyle(fontSize: 15, fontWeight: FontWeight.bold);

  SSMConnectState _ssmState = SSMConnectState(false, Module(ip: "127.0.0.1", port: 5000));
  DeviceWifiInfo wifiInfo = DeviceWifiInfo("ip", "ssid", "macAddress");

  get widgetNor => Card(
        color: Colors.green,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                '模組正常連線中',
                style: TextStyle(fontSize: 20),
              ),
            )
          ],
        ),
      );

  get widgetAbnor => Card(
      color: const Color.fromARGB(255, 177, 11, 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.warning,
            color: Colors.white,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              '模組連線異常',
              style: TextStyle(fontSize: 20),
            ),
          )
        ],
      ));

  bool _connected = false;

  set connected(connected) {
    _connected = connected;
    if (connected) {
      stateWidget = widgetNor;
      connectBtnText = 'Disconnect';
      connectBtnBgColor = Colors.red;
    } else {
      stateWidget = widgetAbnor;
      connectBtnText = 'Connect';
      connectBtnBgColor = Colors.blue;
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    getDeviceWifiInfo().then((value) {
      setState(() {
        wifiInfo = value!;
      });
    });
    User.loadSetting().then((value) {
      setState(() {
        _ipAddress = value.ssmIp;
        _port = value.ssmPort;
        _ipTextFieldController = TextEditingController(text: value.ssmIp);
        _portTextFieldController = TextEditingController(text: value.ssmPort.toString());
      });
    });
    connected = widget.connected;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var singleChildScrollView = SingleChildScrollView(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: stateWidget,
          ),
          titleWidget(text: "連線"),
          Card(
            color: const Color.fromARGB(255, 56, 55, 55),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextField(
                  controller: _ipTextFieldController,
                  onChanged: (text) {
                    setState(() {
                      _ipAddress = text;
                    });
                  },
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                      hintText: 'Ex:192.168.0.3',
                      labelText: 'IP',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.numbers),
                      suffixIcon: _ipTextFieldController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _ipTextFieldController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.clear))),
                ),
                const Divider(),
                TextField(
                  controller: _portTextFieldController,
                  onChanged: (port) {
                    setState(() {
                      _port = int.parse(port);
                    });
                  },
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                      hintText: 'Ex:5000',
                      labelText: 'Port',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.numbers_sharp),
                      suffixIcon: _portTextFieldController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _portTextFieldController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.clear))),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton.icon(
                          style: ElevatedButton.styleFrom(primary: connectBtnBgColor, onPrimary: Colors.white),
                          icon: const Icon(Icons.link),
                          onPressed: _connected ? _disconnect : _menuItemClickedHandle,
                          label: Text(
                            connectBtnText,
                          )),
                    )),
              ],
            ),
          ),
          titleWidget(text: "模組設定"),

          Card(
            color: const Color.fromARGB(255, 56, 55, 55),
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('量測範圍'),
                        MeasureRangeDropDownBtn(
                          onRangeSelected: (range) => {},
                        )
                      ],
                    ))
              ],
            ),
          ),
          Row(
            children: [
              Expanded(child: titleWidget(text: "Wi-Fi Information")),
              IconButton(
                  onPressed: () {
                    getDeviceWifiInfo().then((value) {
                      setState(() {
                        wifiInfo = value!;
                      });
                    });
                  },
                  icon: const Icon(Icons.refresh))
            ],
          ),
          Card(
            color: const Color.fromARGB(255, 56, 55, 55),
            child: Column(
              children: [
                wifiInfoWidget(),
              ],
            ),
          ),
          // ElevatedButton(
          //   onPressed: openQRCodeScanner,
          //   child: const Text('qrView'),
          // )
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        title: const Text('模組連線/設定', style: const TextStyle()),
        actions: [IconButton(onPressed: openQRCodeScanner, icon: const Icon(Icons.qr_code_scanner_sharp))],
      ),
      body: singleChildScrollView,
    );
  }

  Widget titleWidget({required String text}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 10),
      child: Row(
        children: [
          Text(text, style: titleStyle),
        ],
      ),
    );
  }

  Widget wifiInfoWidget() {
    return SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            wifiInfoItem(
              name: "SSID",
              icon: const Icon(Icons.text_format_rounded),
              jsutText: false,
              widget: TextButton(
                onPressed: showWifiSelectDialog,
                child: Text(wifiInfo.ssid),
              ),
            ),
            const Divider(
              indent: 10,
            ),
            wifiInfoItem(name: "Device IP", icon: const Icon(Icons.nine_mp_rounded), jsutText: true, text: wifiInfo.ip),
            const Divider(
              indent: 10,
            ),
            wifiInfoItem(name: "Mac Address", icon: const Icon(Icons.nine_mp_rounded), jsutText: true, text: wifiInfo.macAddress),
          ],
        ));
  }

  Widget wifiInfoItem({required String name, Icon icon = const Icon(Icons.info_rounded), bool jsutText = true, String text = "", Widget widget = const Text('data')}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: () {},
          icon: icon,
          label: Text(name),
          style: ElevatedButton.styleFrom(onPrimary: Colors.white),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: jsutText ? Text(text) : widget,
        ),
      ],
    );
  }

  void ssmModuleConnect() async {}

  void _menuItemClickedHandle() async {
    _showConnectingSpinner();

    var oldIP = (await User.loadSetting()).ssmIp;

    User.ssmModule(_ipAddress, _port);
    Module? ssmModule = Module(ip: _ipAddress, port: _port);
    bool connect = await ssmModule.connect();
    await Future.delayed(const Duration(seconds: 1));
    _ssmState = SSMConnectState(connect, ssmModule);
    _ssmState.isIPChange = oldIP != _ipAddress;
    Navigator.pop(context);
    if (!connect) {
      _showConnectErrDialog();
    } else {
      // Navigator.pushNamed((this.context), 'dataPage', arguments: ssmModule);
      setState(() {
        connected = true;
        widget.ssmModuleOnConnect(_ssmState);
      });
    }
  }

  void _disconnect() {
    try {
      _ssmState.ssmModule.close();
      _ssmState = SSMConnectState(false, _ssmState.ssmModule);
      setState(() {
        connected = false;
      });
      widget.ssmModuleOnConnect(_ssmState);
    } catch (e) {
      print(e);
    }
  }

  void _showConnectingSpinner() async {
    AlertDialog alertDialog = AlertDialog(
      content: Row(children: [
        const CircularProgressIndicator(
          strokeWidth: 3,
        ),
        Container(
          margin: const EdgeInsets.only(left: 25),
          child: Text(
            'Connecting to ' + _ipAddress,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        )
      ]),
    );

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }

  void _showConnectErrDialog() {
    AlertDialog alertDialog = AlertDialog(
      content: Row(children: [
        Container(
            margin: const EdgeInsets.only(left: 25),
            child: Wrap(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 6, right: 10),
                  child: Text(
                    '連線失敗!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(children: [
                      ElevatedButton(onPressed: () => {Navigator.of(context).pop(true), _menuItemClickedHandle()}, child: const Text('重試')),
                      ElevatedButton(onPressed: () => {Navigator.of(context).pop(true)}, child: const Text('OK'))
                    ]))
              ],
            ))
      ]),
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }

  void openQRCodeScanner() {
    var qrScanner = QRScanner(
      // ssmMoudleQRCodeOnCapature: (s) => {},
      ssmMoudleQRCodeOnCapature: ssmModuleQRCodeHandle,
    );
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => qrScanner,
    ))
        .then((value) {
      // var str = ModalRoute.of(context)!.settings.arguments as String;
      print('qr return : $value');

      ssmModuleQRCodeHandle(value);
    });
  }

  ssmModuleQRCodeHandle(String p1) {
    List<String> splited = p1.split(':');
    String ssid = splited[1];
    String ip = splited[2];
    print('ssid:$ssid, ip : $ip');
    User.ssmModule(ip, 5000);
    setState(() {
      _ipAddress = ip;
      _ipTextFieldController = TextEditingController(text: ip);
      _connecToSSID(ssid: ssid);
    });
  }

  void showWifiSelectDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('選擇 Wi-Fi'),
            content: SizedBox(
              height: 300,
              child: SingleChildScrollView(
                child: Column(
                  children: [],
                ),
              ),
            ),
            actions: [const ElevatedButton(onPressed: null, child: Text('OK'))],
          );
        });
  }

  var wifiConnectResultByQRConde = '';
  void _connecToSSID({required String ssid, String? pw}) async {
    wifiInfo.state = "Connecting";
    showWifiConnectStateDialog();

    connectToSSSID(ssid, pw).then((currentWifiInfo) async {
      print('wifi-connect : ${currentWifiInfo.toJson()}  ');
      setState(() {
        wifiInfo = currentWifiInfo;
        wifiInfo.state = "Finish";
      });

      await Future.delayed(const Duration(seconds: 3));
      Navigator.pop(context);
      showWifiConnectStateDialog();

      if (wifiInfo.connected) {
        Navigator.pop(context);
        if (_connected) _disconnect();
        _menuItemClickedHandle();
      }
    });
  }

  Future<void> showWifiConnectStateDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.wifi),
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text('WIFI連線'),
                )
              ],
            ),
            content: Row(
              children: [
                const CircularProgressIndicator(
                  color: Colors.white,
                ),
                Text('Connect to ${wifiInfo.ssid} ..${wifiInfo.state}'),
              ],
            ),
          );
        });
  }
}

class SSMConnectState {
  final bool connected;
  final Module ssmModule;
  bool isIPChange = false;
  SSMConnectState(this.connected, this.ssmModule);
}
