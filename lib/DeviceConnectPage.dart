import 'package:flutter/material.dart';
import 'package:ssmflutter/SSMModule/emulator.dart' as ssm_emulator;

import 'SSMModule/module.dart';
import 'SysSetting.dart';
import 'drawer.dart';

class DeviceConnectPage extends StatefulWidget {
  const DeviceConnectPage({Key? key}) : super(key: key);

  @override
  State<DeviceConnectPage> createState() => _DeviceConnectPageState();
}

class _DeviceConnectPageState extends State<DeviceConnectPage> with AutomaticKeepAliveClientMixin {
  static String _ipAddress = '192.168.0.68';
  static int _port = 5000;

  final TextEditingController _ipTextFieldController = TextEditingController(text: '192.168.0.68');

  final TextEditingController _portTextFieldController = TextEditingController(text: '5000');

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    ssm_emulator.start('127.0.0.1', 5000);

    User.loadSetting();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextField(
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
            onChanged: (port) {
              setState(() {
                _port = int.parse(port);
              });
            },
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(hintText: 'Ex:5000', labelText: 'Port', icon: Icon(Icons.numbers_sharp)),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: _menuItemClickedHandle,
                child: const Text(
                  '連線',
                )),
          ),
          const Divider(),
        ],
      ),
    );
  }

  void _menuItemClickedHandle() async {
    _showConnectingSpinner();
    Module? ssmModule = Module(ip: _ipAddress, port: _port);
    bool connect = await ssmModule.connect();

    await Future.delayed(const Duration(seconds: 1));

    Navigator.pop(this.context);
    if (!connect) {
      _showConnectErrDialog();
    } else {
      Navigator.pushNamed((this.context), 'dataPage', arguments: ssmModule);
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
        context: this.context,
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
}
