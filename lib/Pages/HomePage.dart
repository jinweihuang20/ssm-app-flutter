// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print, empty_catches

import 'package:flutter/material.dart';
import 'package:ssmflutter/Chartslb/SimpleLineChart.dart';
import 'package:ssmflutter/Database/SensorData.dart';
import 'package:ssmflutter/Pages/ZoomOutShowPage.dart';
import 'package:ssmflutter/SSMModule/FeatureDisplay.dart';
import 'package:ssmflutter/SSMModule/Unit.dart';
import 'package:ssmflutter/SSMModule/module.dart';
import 'package:ssmflutter/SocialMediaShare/SocialMediaWidget.dart';
import 'package:ssmflutter/Storage/FileSaveLocalHelper.dart';
import 'package:ssmflutter/Widgets/openUnitSettingWidget.dart';
import '../Database/SqliteAPI.dart' as db;
import '../Storage/Caches.dart';
import '../SysSetting.dart';
import 'package:ssmflutter/Storage/FileSaveLocalHelper.dart' as FileSaveHelper;

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);
  _HomePageState state = _HomePageState();
  @override
  State<HomePage> createState() => state;
}

class _HomePageState extends State<HomePage> {
  Module _ssmMoudle = Module(ip: 'ip', port: -1);
  List<SimpleData> accData = [];
  List<SimpleData> fFtData = [];
  bool _pause = false;
  var features;

  set ssmModule(value) {
    _ssmMoudle = value;
    try {
      _ssmMoudle.accDataOnChange.listen((event) {
        accDataOnChangeHandle(event);
      });
      _ssmMoudle.startReadValue();
    } catch (e) {}
  }

  void accDataOnChangeHandle(AccDataRevDoneEvent data) {
    _dbSave(data.features);
    _dataToSeriesDataOfChart(data);
    features = convertByUnit(data.features, UnitSettingCache.homePageUnit);

    if (!mounted) return;

    if (!_pause)
      setState(() {
        if (zoomOutPage != null) {
          var zoomPage = zoomOutPage as ZoomOutPage;
          zoomPage.state.update(zoomPage.title == "加速度" ? accData : fFtData);
          print('zoom page render');
        }
      });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    _ssmMoudle.close();
  }

  get accChart {
    return SimpleLineChart(
      title: '加速度',
      dataSetList: accData,
      xAxistTitle: "Index",
      yAxisTitle: UnitSettingCache.homePageUnit.accUnitStr,
      useNumericEndPointsTickProviderSpec: true,
      showZoomOutButton: true,
      zoomButtonOnClick: accZoomOut,
    );
  }

  get fftChart {
    return SimpleLineChart(
      title: 'FFT',
      dataSetList: fFtData,
      xAxistTitle: "Freq(Hz)",
      yAxisTitle: 'Mag(${UnitSettingCache.homePageUnit.accUnitStr})',
      showZoomOutButton: true,
      zoomButtonOnClick: fftZoomOut,
    );
  }

  void _homePagePause() {
    setState(() {
      _homePagePauseFlag = true;
      pause();
    });
  }

  void _homePageResume() {
    setState(() {
      _homePagePauseFlag = false;
      resume();
    });
  }

  void saveAccDataToMachine() async {
    print('Save Data');

    await FileNameHelper.displayTextInputDialog(context).then((value) {});
    if (FileNameHelper.fileName == "") return;
    String fileName = FileNameHelper.fileName + ".csv";
    FileSaveHelper.saveRawAccData(fileName, accData).then((filePath) {
      showSaveDoneDialog(context, filePath: fileName);
      print('Data save ok, Path:$filePath');
    });
  }

  bool _homePagePauseFlag = false;

  get _homePageControlWidget {
    return <Widget>[
      ButtonBar(
        buttonPadding: EdgeInsets.all(1),
        alignment: MainAxisAlignment.center,
        children: [
          OpenUnitSettingButton(
            pageName: "HomePage",
            unitSettingDone: (unitMap) {
              print(unitMap.keys);
              setState(() {
                print('ca-home-${UnitSettingCache.homePageUnit.accUnitStr}');
              });
            },
          ),
          IconButton(padding: const EdgeInsets.all(1), onPressed: () => {saveAccDataToMachine()}, icon: const Icon(Icons.save)),
          Card(
            shape: RoundedRectangleBorder(),
            margin: EdgeInsets.all(0),
            color: Color.fromARGB(255, 107, 107, 107),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    splashRadius: 10,
                    padding: const EdgeInsets.all(1),
                    onPressed: _homePagePauseFlag ? null : _homePagePause,
                    icon: const Icon(Icons.pause_circle_outline)),
                IconButton(
                    alignment: Alignment.centerLeft,
                    color: Colors.green,
                    splashRadius: 10,
                    padding: const EdgeInsets.all(1),
                    onPressed: !_homePagePauseFlag ? null : _homePageResume,
                    icon: const Icon(Icons.play_arrow)),
              ],
            ),
          )
        ],
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        title: const Text("時/頻圖", style: const TextStyle()),
        actions: _homePageControlWidget,
      ),
      body: SizedBox.expand(
        child: Column(
          children: [
            Expanded(
              child: accChart,
            ),
            divider(),
            Expanded(
              child: fftChart,
            ),
            divider(),
            Expanded(child: FeatureDisplay(features))
          ],
        ),
      ),
    );
  }

  Widget getTitleWiget(String text, Widget? widget) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
            padding: const EdgeInsets.only(
              left: 5,
            ),
            child: Row(
              children: [
                const Icon(Icons.data_thresholding_sharp),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                )
              ],
            )),
        widget ?? const Text('')
      ],
    );
  }

  Widget divider() {
    return const Divider(
      thickness: 1,
      color: Color.fromARGB(255, 255, 255, 255),
      indent: 12,
      endIndent: 12,
    );
  }

  void _dataToSeriesDataOfChart(AccDataRevDoneEvent data) {
    List<double> xListOfTDData = List.generate(512, (int index) => (index).toDouble(), growable: true);

    double freqStep = 4000 / 256; //256 > 4000

    List<double> freqListOfFFTData = List.generate(256, (int index) => (index * freqStep).toDouble(), growable: true);
    double ratio = UnitSettingCache.homePageUnit.accUnit == ACC_UNIT.g ? 1 : 9.8;

    List<double> xShowList = List.generate(512, (index) => data.accData_X[index] * ratio);
    List<double> yShowList = List.generate(512, (index) => data.accData_Y[index] * ratio);
    List<double> zShowList = List.generate(512, (index) => data.accData_Z[index] * ratio);

    SimpleData xAxisTDData = SimpleData('X', xListOfTDData, xShowList);
    SimpleData yAxisTDData = SimpleData('Y', xListOfTDData, yShowList);
    SimpleData zAxisTDData = SimpleData('Z', xListOfTDData, zShowList);

    SimpleData xAxisFFTData = SimpleData('X', freqListOfFFTData, data.fftData_X);
    SimpleData yAxisFFTData = SimpleData('Y', freqListOfFFTData, data.fftData_Y);
    SimpleData zAxisFFTData = SimpleData('Z', freqListOfFFTData, data.fftData_Z);

    accData = [xAxisTDData, yAxisTDData, zAxisTDData];
    fFtData = [xAxisFFTData, yAxisFFTData, zAxisFFTData];
  }

  void _dbSave(Features features) {
    if (User.writeDataToDb) {
      //db
      db.API.insertData(SensorData(
        _ssmMoudle.ip,
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
  }

  pause() {
    setState(() {
      _pause = true;
    });
  }

  resume() {
    setState(() {
      _pause = false;
    });
  }

  var zoomOutPage;
  void zoomOutChart(data, {required String title, required String xtitle, required String ytitle}) {
    zoomOutPage = ZoomOutPage(
      data: data,
      title: title,
      xAxisTitle: xtitle,
      yAxisTitle: ytitle,
      onClose: (b) => {zoomOutPage = null},
    );
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => zoomOutPage,
        ));
  }

  void accZoomOut() {
    zoomOutChart(accData, title: "加速度", xtitle: "Index", ytitle: "G");
  }

  void fftZoomOut() {
    zoomOutChart(fFtData, title: "FFT", xtitle: "Freq(Hz)", ytitle: "Mag(G)");
  }
}
