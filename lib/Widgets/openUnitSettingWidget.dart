// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:ssmflutter/SSMModule/Unit.dart';

import '../Storage/Caches.dart';

class OpenUnitSettingButton extends StatelessWidget {
  const OpenUnitSettingButton({Key? key, required this.pageName, required this.unitSettingDone}) : super(key: key);
  final Function(Map<String, UnitData>) unitSettingDone;
  final String pageName;
  @override
  Widget build(BuildContext context) {
    int defaultShowIndex = pageName == "HomePage" ? 0 : 1;

    return TextButton(
      onPressed: () {
        Navigator.push<Map<String, UnitData>>(
          context,
          MaterialPageRoute<Map<String, UnitData>>(
            builder: (BuildContext context) => UnitSettingPage(
              defaultShowIndex: defaultShowIndex,
            ),
          ),
        ).then((value) {
          unitSettingDone(value!);
        });
      },
      child: const Text(
        '單位設定',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class UnitSettingPage extends StatefulWidget {
  UnitSettingPage({Key? key, this.defaultShowIndex = 0}) : super(key: key);
  final int defaultShowIndex;
  @override
  State<UnitSettingPage> createState() => _UnitSettingPageState();
}

class _UnitSettingPageState extends State<UnitSettingPage> {
  UnitData unitData = UnitData();
  var _pageIndex = 0;
  Map<String, UnitData> get unitMap {
    return <String, UnitData>{'HomePage': UnitSettingCache.homePageUnit, 'FeaturesPage': UnitSettingCache.featurePageUnit};
  }

  @override
  void initState() {
    print('ca-begin-${UnitSettingCache.homePageUnit.accUnitStr}');
    super.initState();
    _changePageView(widget.defaultShowIndex);
  }

  @override
  void dispose() {
    print('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("單位設定"),
        centerTitle: true,
        leading: IconButton(
          splashRadius: 20,
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(unitMap),
        ),
        actions: [
          TextButton(
              onPressed: _useDefaultHandle,
              child: const Text(
                "使用預設值",
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      body: Column(children: [
        // HeadMenuWidget(selectIndexOnChange: _changePageView, defalutShowIndex: widget.defaultShowIndex),
        // const Divider(
        //   thickness: 4,
        //   color: Colors.grey,
        // ),
        Expanded(
            child:
                createWidgeByDifferentPage(unitData, accUnitOnChange: _accUnitChangeHandle, velUnitOnChange: _velUnitChangeHandle, disUnitOnChange: _disUnitChangeHandle))
      ]),
    );
  }

  _changePageView(int pageIndex) {
    _pageIndex = pageIndex;
    if (pageIndex == 0)
      unitData = UnitSettingCache.homePageUnit;
    else
      unitData = UnitSettingCache.featurePageUnit;

    setState(() {});
  }

  _accUnitChangeHandle(p1) {
    if (_pageIndex == 0)
      UnitSettingCache.homePageUnit.accUnit = p1;
    else
      UnitSettingCache.featurePageUnit.accUnit = p1;

    print('ca-${UnitSettingCache.homePageUnit.accUnitStr}');
  }

  _velUnitChangeHandle(p1) {
    if (_pageIndex == 0)
      UnitSettingCache.homePageUnit.velUnit = p1;
    else
      UnitSettingCache.featurePageUnit.velUnit = p1;
  }

  _disUnitChangeHandle(p1) {
    if (_pageIndex == 0)
      UnitSettingCache.homePageUnit.disUnit = p1;
    else
      UnitSettingCache.featurePageUnit.disUnit = p1;
  }

  void _useDefaultHandle() {
    if (_pageIndex == 0)
      UnitSettingCache.homePageUnit = UnitData();
    else
      UnitSettingCache.featurePageUnit = UnitData();
    _changePageView(_pageIndex);
  }
}

Widget createWidgeByDifferentPage(UnitData unitData,
    {required Function(dynamic) accUnitOnChange, required Function(dynamic) velUnitOnChange, required Function(dynamic) disUnitOnChange}) {
  return Container(
    color: unitData.source == "HomePage" ? Colors.black54 : Colors.black87,
    child: Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('加速度單位'),
            UnitDropDownButton(
              type: UNIT_TYPE.ACC,
              onchange: accUnitOnChange,
              value: unitData.accUnit,
            ),
          ],
        ),
      ),
      const Divider(
        indent: 10,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('速度單位'),
            UnitDropDownButton(
              type: UNIT_TYPE.VEL,
              onchange: velUnitOnChange,
              value: unitData.velUnit,
            ),
          ],
        ),
      ),
      const Divider(
        indent: 10,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('位移量單位'),
            UnitDropDownButton(
              type: UNIT_TYPE.DIS,
              onchange: disUnitOnChange,
              value: unitData.disUnit,
            ),
          ],
        ),
      ),
      const Divider(
        indent: 10,
      ),
    ]),
  );
}

class UnitDropDownButton extends StatefulWidget {
  UnitDropDownButton({Key? key, required this.type, required this.onchange, this.value}) : super(key: key);
  final Function(dynamic) onchange;
  final type;
  dynamic value;
  @override
  State<UnitDropDownButton> createState() => _UnitDropDownButtonState();
}

class _UnitDropDownButtonState extends State<UnitDropDownButton> {
  dynamic selectVal;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: DropdownButton(
        isExpanded: true,
        style: const TextStyle(fontSize: 20),
        value: widget.value,
        items: _createItem(widget.type),
        onChanged: _onChange,
      ),
    );
  }

  void _onChange(dynamic value) {
    setState(() {
      widget.value = value;
      widget.onchange(value);
    });
  }

  List<DropdownMenuItem<dynamic>> _createItem(UNIT_TYPE type) {
    if (type == UNIT_TYPE.VEL) {
      return [
        DropdownMenuItem(child: Text(velUnitConvert(VEL_UNIT.mm_s)), value: VEL_UNIT.mm_s),
        DropdownMenuItem(child: Text(velUnitConvert(VEL_UNIT.um_s)), value: VEL_UNIT.um_s)
      ];
    } else if (type == UNIT_TYPE.DIS) {
      return [
        DropdownMenuItem(child: Text(DIS_UNIT.mm.name), value: DIS_UNIT.mm),
        DropdownMenuItem(child: Text(DIS_UNIT.um.name), value: DIS_UNIT.um),
      ];
    } else {
      return [
        DropdownMenuItem(child: Text(accUnitConvert(ACC_UNIT.g)), value: ACC_UNIT.g),
        DropdownMenuItem(child: Text(accUnitConvert(ACC_UNIT.m_s2)), value: ACC_UNIT.m_s2)
      ];
    }
  }
}

class HeadMenuWidget extends StatefulWidget {
  HeadMenuWidget({Key? key, required this.selectIndexOnChange, this.defalutShowIndex = 0}) : super(key: key);
  Function(int) selectIndexOnChange;
  final int defalutShowIndex;
  @override
  State<HeadMenuWidget> createState() => _HeadMenuWidgetState();
}

class _HeadMenuWidgetState extends State<HeadMenuWidget> {
  var b1Color = Colors.blue;
  var b2Color = Colors.grey;

  var b1BGColor = Colors.white;
  var b2BGColor = Colors.transparent;

  @override
  void initState() {
    if (widget.defalutShowIndex != 0) {
      b2Color = Colors.blue;
      b1Color = Colors.grey;
      b2BGColor = Colors.white;
      b1BGColor = Colors.transparent;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              style: ElevatedButton.styleFrom(onPrimary: b1Color, primary: b1BGColor),
              child: const Text(
                '時/頻圖頁面',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                setState(() {
                  b1Color = Colors.blue;
                  b2Color = Colors.grey;
                  b1BGColor = Colors.white;
                  b2BGColor = Colors.transparent;
                  widget.selectIndexOnChange(0);
                });
              },
            ),
          ),
          Expanded(
            child: TextButton(
              style: ElevatedButton.styleFrom(onPrimary: b2Color, primary: b2BGColor),
              child: const Text(
                "特徵值頁面",
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                setState(() {
                  b2Color = Colors.blue;
                  b1Color = Colors.grey;
                  b2BGColor = Colors.white;
                  b1BGColor = Colors.transparent;
                  widget.selectIndexOnChange(1);
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
