// ignore_for_file: unnecessary_this, no_logic_in_create_state, avoid_print, non_constant_identifier_names
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ssmflutter/Database/SensorData.dart';
import 'package:ssmflutter/SSMModule/FeatureDisplay.dart';
import 'package:ssmflutter/SysSetting.dart';
import '../drawer.dart';
import '../SSMModule/module.dart';
import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import '../Chartslb/LineChart.dart';
import '../SSMModule/MeasureRangeDropDownBtn.dart';
import 'package:ssmflutter/SSMModule/emulator.dart' as ssm_emulator;

import '../Database/SqliteAPI.dart' as db;
import '../Storage/Caches.dart';

class DataPage extends StatefulWidget {
  const DataPage({Key? key}) : super(key: key);

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  var _ssmModule;

  set ssmModule(Module module) {
    if (_ssmModule == null) {
      _ssmModule = module;
      _ssmModule.accDataOnChange.listen((data) {
        accDataHandle(data);
      });
      _ssmModule.startReadValue();
      setState(() {
        range = _ssmModule.range;
      });
    }
  }

  Module get ssmModule => _ssmModule;

  var range;
  final Color pauseBgColor = Colors.grey;
  final Color normalBgColor = Colors.white;

  Color bgColor = Colors.white;

  var _pauseFlag = false;

  get pauseFlag {
    return _pauseFlag;
  }

  set pauseFlag(value) {
    _pauseFlag = value;
    bgColor = value ? pauseBgColor : normalBgColor;
  }

  List<double> accX = [];
  List<double> accY = [];
  List<double> accZ = [];

  List<LinearSales> avgXLineData = [];
  List<LinearSales> avgYLineData = [];
  List<LinearSales> avgZLineData = [];
  var seriesList = [
    charts.Series<LinearSales, DateTime>(
      id: 'Sales',
      domainFn: (LinearSales sales, _) => sales.time,
      measureFn: (LinearSales sales, _) => sales.value,
      data: [],
    )
  ];

  var accSeries = getAccRawSeries([], [], []);
  var fftSeries = GetFFTSeries([], [], [], 8000);
  Features features = Features();

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

  get module_address => ssmModule.address;

  get connected {
    if (ssmModule == null)
      return false;
    else
      return ssmModule.connected;
  }

  set connected(val) {
    ssmModule.connected = val;
  }

  @override
  Widget build(BuildContext context) {
    ssmModule = ModalRoute.of(context)!.settings.arguments as Module;
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Monitor"),
      ),
      drawer: DrawerWidget(),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ElevatedButton(
                onPressed: pauseFlag ? null : () => {pauseFlag = true},
                child: const Text('Pause'),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
              ),
            ),
            ElevatedButton(
              onPressed: !pauseFlag ? null : () => {pauseFlag = false},
              child: const Text('Resume'),
            )
          ],
        )
      ],
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(onPressed: () => {}, icon: Icon(connected ? Icons.check : Icons.error), label: Text('$module_address')),
                  MeasureRangeDropDownBtn(
                    onRangeSelected: _setRange,
                  )
                ],
              ),
            ),
            Card(
              child: SizedBox(
                height: 150,
                child: charts.LineChart(
                  accSeries,
                  animate: false,
                  domainAxis: const charts.NumericAxisSpec(
                      tickProviderSpec: charts.BasicNumericTickProviderSpec(
                        zeroBound: true,
                      ),
                      renderSpec: charts.GridlineRendererSpec(lineStyle: charts.LineStyleSpec(color: charts.Color(r: 11, g: 11, b: 11, a: 9)))),
                  behaviors: [
                    charts.SeriesLegend(position: charts.BehaviorPosition.end, entryTextStyle: const charts.TextStyleSpec(fontSize: 11)),
                    charts.ChartTitle('ACC RAW DATA', titleStyleSpec: const charts.TextStyleSpec(fontSize: 14)),
                    charts.ChartTitle('G', behaviorPosition: charts.BehaviorPosition.start, titleStyleSpec: const charts.TextStyleSpec(fontSize: 14)),
                    charts.ChartTitle('INDEX', behaviorPosition: charts.BehaviorPosition.bottom, titleStyleSpec: const charts.TextStyleSpec(fontSize: 14))
                  ],
                ),
              ),
            ),
            const Divider(
              thickness: 1,
            ),
            Card(
              child: SizedBox(
                height: 150,
                child: charts.LineChart(
                  fftSeries,
                  animate: false,
                  domainAxis: const charts.NumericAxisSpec(
                      tickProviderSpec: charts.BasicNumericTickProviderSpec(
                        zeroBound: true,
                      ),
                      renderSpec: charts.GridlineRendererSpec(lineStyle: charts.LineStyleSpec(color: charts.Color(r: 11, g: 11, b: 11, a: 9)))),
                  behaviors: [
                    charts.SeriesLegend(position: charts.BehaviorPosition.end, entryTextStyle: const charts.TextStyleSpec(fontSize: 11)),
                    charts.ChartTitle('FFT', titleStyleSpec: const charts.TextStyleSpec(fontSize: 14)),
                    charts.ChartTitle('Mag(G)', behaviorPosition: charts.BehaviorPosition.start, titleStyleSpec: const charts.TextStyleSpec(fontSize: 14)),
                    charts.ChartTitle('Freq(Hz)', behaviorPosition: charts.BehaviorPosition.bottom, titleStyleSpec: const charts.TextStyleSpec(fontSize: 14))
                  ],
                ),
              ),
            ),
            const Divider(
              thickness: 1,
            ),
            FeatureDisplay(features),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    print('page disposed');
    ssmModule.close();
    ssm_emulator.restart();
    super.dispose();
  }

  void closeSocket() {
    ssmModule.close();
    setState(() {
      connected = false;
    });
  }

  void reConnect() {
    ssmModule.connect();
    ssmModule.startReadValue();
  }

  void accDataHandle(AccDataRevDoneEvent data) {
    setState(() {
      accX = data.accData_X;
      accY = data.accData_Y;
      accZ = data.accData_Z;

      if (this.avgXLineData.length > 30) {
        this.avgXLineData.removeAt(0);
        this.avgYLineData.removeAt(0);
        this.avgZLineData.removeAt(0);
      }
      this.avgXLineData.add(LinearSales(DateTime.now(), avgAccX));
      this.avgYLineData.add(LinearSales(DateTime.now(), avgAccY));
      this.avgZLineData.add(LinearSales(DateTime.now(), avgAccZ));

      if (pauseFlag) return;

      features = data.features;

      if (User.writeDataToDb) {
        //db
        db.API.insertData(SensorData(
          DateTime.now(),
          features.acc_x_pp,
          features.acc_y_pp,
          features.acc_z_pp,
          features.vel_x_rms,
          features.vel_y_rms,
          features.vel_z_rms,
          features.dis_x_pp,
          features.dis_y_pp,
          features.dis_z_pp,
        ));
      } else {
        print('not write db');
      }

      seriesList = [
        charts.Series<LinearSales, DateTime>(
          id: 'Avg-X',
          domainFn: (LinearSales sales, _) => sales.time,
          measureFn: (LinearSales sales, _) => sales.value,
          data: this.avgXLineData,
        ),
        charts.Series<LinearSales, DateTime>(
          id: 'Avg-Y',
          domainFn: (LinearSales sales, _) => sales.time,
          measureFn: (LinearSales sales, _) => sales.value,
          data: this.avgYLineData,
        ),
        charts.Series<LinearSales, DateTime>(
          id: 'Avg-Z',
          domainFn: (LinearSales sales, _) => sales.time,
          measureFn: (LinearSales sales, _) => sales.value,
          data: this.avgZLineData,
        )
      ];
      accSeries = getAccRawSeries(accX, accY, accZ);
      fftSeries = GetFFTSeries(data.fftData_X, data.fftData_Y, data.fftData_Z, 8000);
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

  _setRange(int range) {
    ssmModule.setRange(range);
  }
}

class AccDataPoint {
  final int time;
  final double value;
  AccDataPoint(this.time, this.value);
}
