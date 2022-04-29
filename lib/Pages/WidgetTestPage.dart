import 'package:flutter/material.dart';
import 'package:ssmflutter/SSMModule/Unit.dart';
import 'package:ssmflutter/Widgets/openUnitSettingWidget.dart';

import '../Router/Routers.dart';

class WidgetTestPage extends StatefulWidget {
  const WidgetTestPage({Key? key}) : super(key: key);

  @override
  State<WidgetTestPage> createState() => _WidgetTestPageState();
}

class _WidgetTestPageState extends State<WidgetTestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TEST"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            UnitWidge(),
          ],
        ),
      ),
    );
  }
}

class UnitWidge extends StatelessWidget {
  const UnitWidge({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OpenUnitSettingButton(
      pageName: 'HomePage',
      unitSettingDone: (unitData) => {print(unitData['HomePage']!.accUnitStr)},
    );
  }
}
