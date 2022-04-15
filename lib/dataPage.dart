// ignore_for_file: unnecessary_this, no_logic_in_create_state, avoid_print

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:charts_flutter/flutter.dart' as charts;

import 'dart:math' as math;
import 'drawer.dart';
import 'SSMModule/module.dart';

class DataPage extends StatefulWidget {
  const DataPage({Key? key, required this.title, this.ssmModule})
      : super(key: key);
  final String title;
  final Module? ssmModule;
  @override
  State<DataPage> createState() => _DataPageState(ssmModule: this.ssmModule);
}

class _DataPageState extends State<DataPage> {
  _DataPageState({this.ssmModule});

  final Module? ssmModule;

  var range;

  List<double> accX = [];
  List<double> accY = [];
  List<double> accZ = [];

  get revAccDataLen_X {
    return accX.length;
  }

  get revAccDataLen_Y {
    return accY.length;
  }

  get revAccDataLen_Z {
    return accZ.length;
  }

  get avgAccX {
    return calculateAvg(accX);
  }

  get avgAccX_UiDisplay {
    return double.parse(avgAccX.toString()).toStringAsFixed(2);
  }

  get avgAccY {
    return calculateAvg(accY);
  }

  get avgAccY_UiDisplay {
    return double.parse(avgAccY.toString()).toStringAsFixed(2);
  }

  get avgAccZ {
    return calculateAvg(accZ);
  }

  get avgAccZ_UiDisplay {
    return double.parse(avgAccZ.toString()).toStringAsFixed(2);
  }

  get module_address => ssmModule?.address;

  get connected => ssmModule?.connected;
  set connected(val) {
    ssmModule?.connected = val;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      drawer: drawer,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: Row(
                children: [
                  Icon(
                    connected ? Icons.check : Icons.error,
                    color: connected ? Colors.green : Colors.red,
                  ),
                  Text('$module_address' ' | 量測範圍:$range' 'G'),
                ],
              ),
            ),
            Text(
                'Rev> X:$revAccDataLen_X Y:$revAccDataLen_Y Z:$revAccDataLen_Z'),
            Text('Average> X:$avgAccX_UiDisplay'),
            Text('Average> Y:$avgAccY_UiDisplay'),
            Text('Average> Z:$avgAccZ_UiDisplay'),
            ElevatedButton(onPressed: send, child: const Text('send')),
            ElevatedButton(
                onPressed: closeSocket, child: const Text('CLOSE SCOKET')),
            ElevatedButton(
                onPressed: reConnect, child: const Text('RE-CONNECT')),
            Column(
              children: <Widget>[
                const Text('chart here'),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    ssmModule?.accDataOnChange.listen((data) {
      accDataHandle(data);
    });
    ssmModule?.startReadValue();
    setState(() {
      range = ssmModule?.range;
    });
    super.initState();
  }

  @override
  void dispose() {
    print('page disposed');
    ssmModule?.close();
    super.dispose();
  }

  void send() {
    ssmModule?.readParameter();
  }

  void closeSocket() {
    ssmModule?.close();
    setState(() {
      connected = false;
    });
  }

  void reConnect() {
    ssmModule?.connect();
    ssmModule?.startReadValue();
  }

  void accDataHandle(AccDataRevDoneEvent data) {
    print('data ready, rend this');
    print(data.accData_X.length);
    setState(() {
      accX = data.accData_X;
      accY = data.accData_Y;
      accZ = data.accData_Z;
    });
  }

  double calculateAvg(List<double> ls) {
    if (ls.isEmpty) return -1;
    double avg = 0;
    //sum
    double sum = ls.reduce((value, element) => value + element);
    avg = sum / ls.length;
    return avg;
  }
}

class AccDataPoint {
  final int time;
  final double value;
  AccDataPoint(this.time, this.value);
}
