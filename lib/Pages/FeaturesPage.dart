import 'package:flutter/material.dart';
import 'package:ssmflutter/Chartslb/ISOPlugin.dart';
import 'package:ssmflutter/Chartslb/TimeLineChart.dart';
import '../SSMModule/FeatureDisplay.dart';

import 'package:charts_flutter/flutter.dart' as charts;

import '../SSMModule/module.dart';

enum SHOW_FE_NAME { oa, acc, vel, dis }

class FeaturesPage extends StatefulWidget {
  FeaturesPage({Key? key}) : super(key: key);
  _FeaturesPageState state = _FeaturesPageState();
  @override
  State<FeaturesPage> createState() => state;
}

class _FeaturesPageState extends State<FeaturesPage> with AutomaticKeepAliveClientMixin {
  final xAxisColor = charts.MaterialPalette.blue.shadeDefault;
  final yAxisColor = charts.MaterialPalette.red.shadeDefault;
  final zAxisColor = charts.MaterialPalette.yellow.shadeDefault;

  Module _ssmMoudle = Module(ip: 'ip', port: -1);
  Features features = Features();

  final Color _noActiveBtnColor = Colors.grey;
  final Color _activeBtnColor = const Color.fromARGB(255, 21, 64, 93);

  Map<String, Color> buttonColorMap = <String, Color>{
    SHOW_FE_NAME.oa.name.toString(): const Color.fromARGB(255, 21, 64, 93),
    SHOW_FE_NAME.acc.name.toString(): Colors.grey,
    SHOW_FE_NAME.vel.name.toString(): Colors.grey,
    SHOW_FE_NAME.dis.name.toString(): Colors.grey
  };

  SHOW_FE_NAME _eShowFEName = SHOW_FE_NAME.oa;
  List<TimeData> oaData = [];
  List<TimeData> accData = [];
  List<TimeData> velData = [];
  List<TimeData> disData = [];
  bool _showISO = false;
  set eShowFEName(SHOW_FE_NAME value) {
    _eShowFEName = value;

    setState(() {
      _chartPageViewController.jumpToPage(_eShowFEName.index);
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

        data.isoResultX = getISOResult(data.xValue, _isoSelect);
        data.isoResultY = getISOResult(data.yValue, _isoSelect);
        data.isoResultZ = getISOResult(data.zValue, _isoSelect);

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

  final PageController _chartPageViewController = PageController(initialPage: 0);

  dynamic _isoSelect = 1;

  @override
  void initState() {
    initializeDataState();
    super.initState();
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
            Expanded(child: axisValueWiget(title: "X", value: showingData.xValue, unit: showingData.unit, isoResult: showingData.isoResultX)),
            Expanded(child: axisValueWiget(title: "Y", value: showingData.yValue, unit: showingData.unit, isoResult: showingData.isoResultY)),
            Expanded(child: axisValueWiget(title: "Z", value: showingData.zValue, unit: showingData.unit, isoResult: showingData.isoResultZ))
          ],
        ),
        // FeatureDisplay(features),
        Expanded(
            child: Container(
          color: Colors.black,
          child: PageView(
            controller: _chartPageViewController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              TimeLineChart(
                title: _eShowFEName.name.toUpperCase(),
                dataSetList: showingData.timeData,
                yAxisTitle: showingData.unit,
              ),
              TimeLineChart(
                title: _eShowFEName.name.toUpperCase(),
                dataSetList: showingData.timeData,
                yAxisTitle: showingData.unit,
              ),
              Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_sharp,
                        size: 16,
                      ),
                      const Padding(padding: EdgeInsets.only(left: 10), child: Text('ISO 規範 : ')),
                      SizedBox(
                          width: 160,
                          child: DropdownButton(
                              value: _isoSelect,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              isExpanded: true,
                              alignment: Alignment.center,
                              items: _isoDropDownItems(),
                              onChanged: _isoSelectValueHandle))
                    ],
                  ),
                  Expanded(
                      child: TimeLineChart(
                    title: _eShowFEName.name.toUpperCase(),
                    dataSetList: showingData.timeData,
                    yAxisTitle: showingData.unit,
                    chartISOProperty: ChartISOProperty(showIso: true, isoType: _isoSelect),
                  ))
                ],
              ),
              TimeLineChart(
                title: _eShowFEName.name.toUpperCase(),
                dataSetList: showingData.timeData,
                yAxisTitle: showingData.unit,
              ),
            ],
          ),
        ))
      ],
    );
  }

  void _isoSelectValueHandle(value) {
    setState(() {
      _isoSelect = value;
    });
  }

  List<DropdownMenuItem> _isoDropDownItems() {
    return const <DropdownMenuItem>[
      DropdownMenuItem(
        child: Text('ISO-10816-1 Class 1'),
        value: 1,
      ),
      DropdownMenuItem(child: Text('ISO-10816-1 Class 2'), value: 2),
      DropdownMenuItem(child: Text('ISO-10816-1 Class 3'), value: 3)
    ];
  }

  Widget iconButton({required String text, required Color color, required Function() onPressed}) {
    return Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), primary: color),
        ));
  }

  Widget axisValueWiget({required String title, required dynamic value, required String unit, Color backgroundColor = Colors.blue, String isoResult = "GOOD"}) {
    var isoWidget = Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
              child: ElevatedButton(
                onPressed: () {},
                child: Text(isoResult),
                style: ElevatedButton.styleFrom(
                    primary: getColorOfISOResult(isoResult),
                    textStyle: const TextStyle(fontSize: 12),
                    fixedSize: const Size(120, 12),
                    padding: const EdgeInsets.all(1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              ),
            )
          ],
        ));

    var contentChildren = [
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
            child: Center(child: Text((value as double).toStringAsFixed(2), style: const TextStyle(fontSize: 27, letterSpacing: 2, fontWeight: FontWeight.bold))),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6, top: 9),
            child: Text(unit, style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic)),
          )
        ],
      )),
    ];

    if (_eShowFEName == SHOW_FE_NAME.vel) {
      contentChildren.addAll([
        const Divider(
          thickness: 1,
        ),
        isoWidget
      ]);
    }

    return Padding(
        padding: const EdgeInsets.all(3),
        child: SizedBox(
          height: 105,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(
              children: contentChildren,
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
  }

  void initializeDataState() {
    oaData = [
      TimeData(name: 'X', timeList: [], values: [], color: xAxisColor),
      TimeData(name: 'Y', timeList: [], values: [], color: yAxisColor),
      TimeData(name: 'Z', timeList: [], values: [], color: zAxisColor)
    ];
    accData = [
      TimeData(name: 'X', timeList: [], values: [], color: xAxisColor),
      TimeData(name: 'Y', timeList: [], values: [], color: yAxisColor),
      TimeData(name: 'Z', timeList: [], values: [], color: zAxisColor)
    ];
    velData = [
      TimeData(name: 'X', timeList: [], values: [], color: xAxisColor),
      TimeData(name: 'Y', timeList: [], values: [], color: yAxisColor),
      TimeData(name: 'Z', timeList: [], values: [], color: zAxisColor)
    ];
    disData = [
      TimeData(name: 'X', timeList: [], values: [], color: xAxisColor),
      TimeData(name: 'Y', timeList: [], values: [], color: yAxisColor),
      TimeData(name: 'Z', timeList: [], values: [], color: zAxisColor)
    ];
  }

  getColorOfISOResult(String isoResult) {
    switch (isoResult) {
      case 'GOOD':
        return Colors.green;
      case 'Staisfactory':
        return Colors.yellow.shade600;
      case 'Unstaisfactory':
        return Colors.orange.shade600;
      case 'Unacceptable':
        return Colors.red;
      default:
    }
  }
}

String getISOResult(double vel, isoSelect) {
  ISO10816SPEC spec = classSepcMap[isoSelect]!;

  return spec.getResult(vel);
}

class ShowingData {
  String unit = "G";
  double xValue = 0;
  double yValue = 0;
  double zValue = 0;
  String isoResultX = "GD";
  String isoResultY = "GD";
  String isoResultZ = "GD";

  List<TimeData> timeData = [];
}
