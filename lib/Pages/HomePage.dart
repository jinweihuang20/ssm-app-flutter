import 'package:flutter/material.dart';
import 'package:ssmflutter/Chartslb/SimpleLineChart.dart';
import 'package:ssmflutter/Database/SensorData.dart';
import 'package:ssmflutter/Pages/ZoomOutShowPage.dart';
import 'package:ssmflutter/SSMModule/FeatureDisplay.dart';
import 'package:ssmflutter/SSMModule/module.dart';
import 'package:ssmflutter/Storage/FileSaveLocalHelper.dart';
import '../Database/SqliteAPI.dart' as db;
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
    var len = data.accData_X.length;
    _dbSave(data.features);
    _dataToSeriesDataOfChart(data);
    features = data.features;
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
      yAxisTitle: "G",
      showTitle: false,
      useNumericEndPointsTickProviderSpec: true,
    );
  }

  get fftChart {
    return SimpleLineChart(
      title: 'FFT',
      dataSetList: fFtData,
      xAxistTitle: "Freq(Hz)",
      yAxisTitle: 'Mag(G)',
      showTitle: false,
    );
  }

  void saveAccDataToMachine() async {
    print('Save Data');

    await FileNameHelper.displayTextInputDialog(context);
    if (FileNameHelper.fileName == "") return;
    String fileName = FileNameHelper.fileName + ".csv";
    FileSaveHelper.saveRawAccData(fileName, accData).then((filePath) {
      FileNameHelper.showSaveDoneDialog(context);
      print('Data save ok, Path:$filePath');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          getTitleWiget(const Icon(Icons.data_thresholding_sharp), "加速度", IconButton(onPressed: accZoomOut, icon: const Icon(Icons.zoom_out_map))),
          divider(),
          Expanded(
              child: SizedBox(
            height: 220,
            child: accChart,
          )),
          const Divider(),
          getTitleWiget(const Icon(Icons.data_thresholding_sharp), "FFT", IconButton(onPressed: fftZoomOut, icon: const Icon(Icons.zoom_out_map))),
          divider(),
          Expanded(
              child: SizedBox(
            height: 220,
            child: fftChart,
          )),
          getTitleWiget(const Icon(Icons.data_thresholding_sharp), "特徵值", null),
          divider(),
          Expanded(child: FeatureDisplay(features))
        ],
      ),
    );
  }

  Widget getTitleWiget(Icon icon, String text, Widget? widget) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
              padding: const EdgeInsets.only(
                left: 10,
              ),
              child: Row(
                children: [
                  icon,
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      text,
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  )
                ],
              )),
          widget == null ? const Text('') : widget
        ],
      ),
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
    int lenOfTimeDomainData = data.accData_X.length;
    int lenOfFFTData = data.fftData_X.length;

    List<double> xListOfTDData = List.generate(512, (int index) => (index).toDouble(), growable: true);

    double freqStep = 4000 / 256; //256 > 4000

    List<double> freqListOfFFTData = List.generate(256, (int index) => (index * freqStep).toDouble(), growable: true);

    SimpleData xAxisTDData = SimpleData('X', xListOfTDData, data.accData_X);
    SimpleData yAxisTDData = SimpleData('Y', xListOfTDData, data.accData_Y);
    SimpleData zAxisTDData = SimpleData('Z', xListOfTDData, data.accData_Z);

    SimpleData xAxisFFTData = SimpleData('X', freqListOfFFTData, data.fftData_X);
    SimpleData yAxisFFTData = SimpleData('Y', freqListOfFFTData, data.fftData_Y);
    SimpleData zAxisFFTData = SimpleData('Z', freqListOfFFTData, data.fftData_Z);

    accData = [xAxisTDData, yAxisTDData, zAxisTDData];
    fFtData = [xAxisFFTData, yAxisFFTData, zAxisFFTData];
  }

  void _dbSave(features) {
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
