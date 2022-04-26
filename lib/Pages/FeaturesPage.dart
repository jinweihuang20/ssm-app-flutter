import 'package:flutter/material.dart';
import 'package:ssmflutter/Chartslb/TimeLineChart.dart';
import '../SSMModule/FeatureDisplay.dart';
import '../SSMModule/module.dart';

enum SHOW_FE_NAME { oa, acc, vel, dis }

class FeaturesPage extends StatefulWidget {
  FeaturesPage({Key? key}) : super(key: key);
  _FeaturesPageState state = _FeaturesPageState();
  @override
  State<FeaturesPage> createState() => state;
}

class _FeaturesPageState extends State<FeaturesPage>
    with AutomaticKeepAliveClientMixin {
  Module _ssmMoudle = Module(ip: 'ip', port: -1);
  Features features = Features();
  List<TimeData> oaData = [
    TimeData(name: 'X', timeList: [], values: []),
    TimeData(name: 'Y', timeList: [], values: []),
    TimeData(name: 'Z', timeList: [], values: [])
  ];
  List<TimeData> accData = [
    TimeData(name: 'X', timeList: [], values: []),
    TimeData(name: 'Y', timeList: [], values: []),
    TimeData(name: 'Z', timeList: [], values: [])
  ];
  List<TimeData> velData = [
    TimeData(name: 'X', timeList: [], values: []),
    TimeData(name: 'Y', timeList: [], values: []),
    TimeData(name: 'Z', timeList: [], values: [])
  ];
  List<TimeData> disData = [
    TimeData(name: 'X', timeList: [], values: []),
    TimeData(name: 'Y', timeList: [], values: []),
    TimeData(name: 'Z', timeList: [], values: [])
  ];
  final Color _noActiveBtnColor = Colors.grey;
  final Color _activeBtnColor = const Color.fromARGB(255, 21, 64, 93);

  Map<String, Color> buttonColorMap = <String, Color>{
    SHOW_FE_NAME.oa.name.toString(): const Color.fromARGB(255, 21, 64, 93),
    SHOW_FE_NAME.acc.name.toString(): Colors.grey,
    SHOW_FE_NAME.vel.name.toString(): Colors.grey,
    SHOW_FE_NAME.dis.name.toString(): Colors.grey
  };

  SHOW_FE_NAME _eShowFEName = SHOW_FE_NAME.oa;
  set eShowFEName(SHOW_FE_NAME value) {
    _eShowFEName = value;

    setState(() {
      buttonColorMap = <String, Color>{
        SHOW_FE_NAME.oa.name.toString(): _noActiveBtnColor,
        SHOW_FE_NAME.acc.name.toString(): _noActiveBtnColor,
        SHOW_FE_NAME.vel.name.toString(): _noActiveBtnColor,
        SHOW_FE_NAME.dis.name.toString(): _noActiveBtnColor
      };
      buttonColorMap[_eShowFEName.name.toString()] = _activeBtnColor;
    });
  }

  ShowingData get showingData {
    ShowingData data = ShowingData();

    switch (_eShowFEName) {
      case SHOW_FE_NAME.oa:
        data.xValue = features.oa_x;
        data.yValue = features.oa_y;
        data.zValue = features.oa_z;
        data.unit = 'G';
        data.timeData = oaData;
        break;

      case SHOW_FE_NAME.acc:
        data.xValue = features.acc_x_pp;
        data.yValue = features.acc_y_pp;
        data.zValue = features.acc_z_pp;
        data.unit = 'G';
        data.timeData = accData;
        break;

      case SHOW_FE_NAME.vel:
        data.xValue = features.vel_x_rms;
        data.yValue = features.vel_y_rms;
        data.zValue = features.vel_z_rms;
        data.unit = 'mm/s';
        data.timeData = velData;
        break;

      case SHOW_FE_NAME.dis:
        data.xValue = features.dis_x_pp;
        data.yValue = features.dis_y_pp;
        data.zValue = features.dis_z_pp;
        data.unit = 'um';
        data.timeData = disData;
        break;
      default:
    }

    return data;
  }

  set ssmModule(value) {
    _ssmMoudle = value;
    try {
      _ssmMoudle.featureDataOnChange.listen((evtArg) {
        _featuresDataOnChangeHandle(evtArg.features);
      });
    } catch (e) {}
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: iconButton(
              text: 'OA',
              onPressed: () => {eShowFEName = SHOW_FE_NAME.oa},
              color: buttonColorMap[SHOW_FE_NAME.oa.name]!,
            )),
            Expanded(
                child: iconButton(
              text: 'ACC',
              onPressed: () => {eShowFEName = SHOW_FE_NAME.acc},
              color: buttonColorMap[SHOW_FE_NAME.acc.name]!,
            )),
            Expanded(
                child: iconButton(
              text: 'VEL',
              onPressed: () => {eShowFEName = SHOW_FE_NAME.vel},
              color: buttonColorMap[SHOW_FE_NAME.vel.name]!,
            )),
            Expanded(
                child: iconButton(
              text: 'DIS',
              onPressed: () => {eShowFEName = SHOW_FE_NAME.dis},
              color: buttonColorMap[SHOW_FE_NAME.dis.name]!,
            )),
          ],
        ),
        const Divider(
          thickness: 2,
          indent: 5,
          endIndent: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
                child: axisValueWiget(
                    title: "X",
                    value: showingData.xValue,
                    unit: showingData.unit,
                    backgroundColor: const Color.fromARGB(255, 37, 129, 204))),
            Expanded(
                child: axisValueWiget(
                    title: "Y",
                    value: showingData.yValue,
                    unit: showingData.unit,
                    backgroundColor: Colors.red)),
            Expanded(
                child: axisValueWiget(
                    title: "Z",
                    value: showingData.zValue,
                    unit: showingData.unit,
                    backgroundColor: const Color.fromARGB(255, 230, 215, 81)))
          ],
        ),
        // FeatureDisplay(features),
        Expanded(
            child: Container(
          color: Colors.black,
          child: TimeLineChart(
            title: _eShowFEName.name.toUpperCase(),
            dataSetList: showingData.timeData,
            yAxisTitle: showingData.unit,
          ),
        ))
      ],
    );
  }

  Widget iconButton(
      {required String text,
      required Color color,
      required Function() onPressed}) {
    return Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              primary: color),
        ));
  }

  Widget axisValueWiget(
      {required String title,
      required dynamic value,
      required String unit,
      Color backgroundColor = Colors.blue}) {
    return Padding(
        padding: const EdgeInsets.all(3),
        child: SizedBox(
          height: 70,
          width: 100,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  color: backgroundColor,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                ),
                Expanded(
                    child: Row(
                  children: [
                    Expanded(
                      child: Center(
                          child: Text((value as double).toStringAsFixed(2),
                              style: const TextStyle(
                                  fontSize: 27,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold))),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 6, top: 9),
                      child: Text(unit,
                          style: const TextStyle(
                              fontSize: 15, fontStyle: FontStyle.italic)),
                    )
                  ],
                ))
              ],
            ),
          ),
        ));
  }

  void _removeFirstElementOfchartSeries() {
    for (var i = 0; i < 3; i++) {
      oaData[i].timeList.removeAt(0);
      accData[i].timeList.removeAt(0);
      velData[i].timeList.removeAt(0);
      disData[i].timeList.removeAt(0);

      oaData[i].values.removeAt(0);
      accData[i].values.removeAt(0);
      velData[i].values.removeAt(0);
      disData[i].values.removeAt(0);
    }
  }

  void _featuresDataOnChangeHandle(Features features) {
    try {
      setState(() {
        this.features = features;
        var time = DateTime.now();

        for (var i = 0; i < 3; i++) {
          oaData[i].timeList.add(time);
          accData[i].timeList.add(time);
          velData[i].timeList.add(time);
          disData[i].timeList.add(time);
        }

        oaData[0].values.add(features.oa_x);
        oaData[1].values.add(features.oa_y);
        oaData[2].values.add(features.oa_z);

        accData[0].values.add(features.acc_x_pp);
        accData[1].values.add(features.acc_y_pp);
        accData[2].values.add(features.acc_z_pp);

        velData[0].values.add(features.vel_x_rms);
        velData[1].values.add(features.vel_y_rms);
        velData[2].values.add(features.vel_z_rms);

        disData[0].values.add(features.dis_x_pp);
        disData[1].values.add(features.dis_y_pp);
        disData[2].values.add(features.dis_z_pp);

        int dataLen = oaData[0].timeList.length;

        if (dataLen > 100) {
          _removeFirstElementOfchartSeries();
        }
      });
    } catch (e) {
      print('features rev..$e');
    }
    print('features rev..');
  }
}

class ShowingData {
  String unit = "G";
  double xValue = 0;
  double yValue = 0;
  double zValue = 0;
  List<TimeData> timeData = [];
}
