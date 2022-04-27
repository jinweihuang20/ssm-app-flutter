import 'package:flutter/material.dart';
import 'package:ssmflutter/SSMModule/MeasureRangeDropDownBtn.dart';
import 'package:ssmflutter/SSMModule/emulator.dart' as ssm_emulator;
import '../QRCode/QRSacnWidget.dart';
import '../SSMModule/module.dart';
import '../SysSetting.dart';
import '../drawer.dart';

class DeviceConnectPage extends StatefulWidget {
  DeviceConnectPage({Key? key, required this.ssmModuleOnConnect, this.ip = "127.0.0.1", this.port = 5000, this.connected = false}) : super(key: key);

  final String ip;
  final int port;
  final bool connected;
  final Function(SSMConnectState) ssmModuleOnConnect;
  @override
  var state = _DeviceConnectPageState();
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
  final TextStyle titleStyle = const TextStyle(fontSize: 18);
  SSMConnectState _ssmState = SSMConnectState(false, Module(ip: "127.0.0.1", port: 5000));

  get widget_nor => Card(
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

  get widget_abnor => Card(
      color: Color.fromARGB(255, 177, 11, 2),
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
      stateWidget = widget_nor;
      connectBtnText = 'Disconnect';
      connectBtnBgColor = Colors.red;
    } else {
      stateWidget = widget_abnor;
      connectBtnText = 'Connect';
      connectBtnBgColor = Colors.blue;
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
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
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: stateWidget,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 10),
            child: Column(
              children: [
                Text(
                  '模組連線',
                  style: titleStyle,
                ),
              ],
            ),
          ),
          TextField(
            enabled: !widget.connected,
            controller: _ipTextFieldController,
            onChanged: (text) {
              setState(() {
                _ipAddress = text;
              });
            },
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(hintText: 'Ex:192.168.0.3', labelText: 'IP', icon: Icon(Icons.numbers)),
          ),
          TextField(
            controller: _portTextFieldController,
            enabled: !widget.connected,
            onChanged: (port) {
              setState(() {
                _port = int.parse(port);
              });
            },
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(hintText: 'Ex:5000', labelText: 'Port', icon: Icon(Icons.numbers_sharp)),
          ),
          Padding(
              padding: EdgeInsets.only(top: 10),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: connectBtnBgColor,
                    ),
                    onPressed: _connected ? _disconnect : _menuItemClickedHandle,
                    child: Text(
                      connectBtnText,
                    )),
              )),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 10),
            child: Text('模組設定', style: titleStyle),
          ),
          Card(
            child: Column(
              children: [
                Padding(
                    padding: EdgeInsets.all(10),
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
          )
          // ElevatedButton(
          //   onPressed: openQRCodeScanner,
          //   child: const Text('qrView'),
          // )
        ],
      ),
    );
  }

  void ssmModuleConnect() async {}

  void _menuItemClickedHandle() async {
    _showConnectingSpinner();

    User.ssmModule(_ipAddress, _port);
    Module? ssmModule = Module(ip: _ipAddress, port: _port);
    bool connect = await ssmModule.connect();
    await Future.delayed(const Duration(seconds: 1));
    _ssmState = SSMConnectState(connect, ssmModule);
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
      connected = false;
      widget.ssmModuleOnConnect(_ssmState);
    } catch (e) {}
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
                    child: Wrap(alignment: WrapAlignment.spaceAround, children: [
                      ElevatedButton(onPressed: () => {Navigator.of(this.context).pop(true), _menuItemClickedHandle()}, child: const Text('重試')),
                      ElevatedButton(onPressed: () => {Navigator.of(this.context).pop(true)}, child: const Text('OK'))
                    ]))
              ],
            ))
      ]),
    );

    showDialog(
        context: this.context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }

  ssmModuleQRCodeHandle(String p1) {
    List<String> splited = p1.split(':');
    String ssid = splited[1];
    String ip = splited[2];
    print('ssid:$ssid, ip : $ip');
    //TODO Try Connect TO SSID
    User.ssmModule(ip, 5000);
    setState(() {
      _ipAddress = ip;
      _ipTextFieldController = TextEditingController(text: ip);
    });
    Navigator.pop(context);
  }

  void openQRCodeScanner() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => QRScanner(
        ssmMoudleQRCodeOnCapature: ssmModuleQRCodeHandle,
      ),
    ));
  }
}

class SSMConnectState {
  final bool connected;
  final Module ssmModule;
  SSMConnectState(this.connected, this.ssmModule);
}
