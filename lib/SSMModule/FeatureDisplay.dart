import 'package:flutter/material.dart';
import 'package:ssmflutter/SSMModule/module.dart';

import '../Storage/Caches.dart';

class FeatureDisplay extends StatefulWidget {
  FeatureDisplay(this.featuresData);
  Features featuresData;
  @override
  State<FeatureDisplay> createState() => _FeatureDisplayState();
}

class _FeatureDisplayState extends State<FeatureDisplay> {
  TextStyle textStyle = const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 3);
  TextStyle titleTextStyle = const TextStyle(fontSize: 12, decoration: TextDecoration.underline, decorationColor: Colors.white);
  @override
  Widget build(BuildContext context) {
    widget.featuresData ??= Features();
    return SingleChildScrollView(
      child: Card(
        color: Colors.transparent,
        child: Column(
          children: [
            const Text(
              '特徵值',
              style: const TextStyle(fontSize: 15),
            ),
            FeatureCard(
                featureName: 'OA',
                xData: widget.featuresData.oa_x,
                yData: widget.featuresData.oa_y,
                zData: widget.featuresData.oa_z,
                unit: UnitSettingCache.homePageUnit.accUnitStr),
            FeatureCard(
                featureName: 'ACC(P2P)',
                xData: widget.featuresData.acc_x_pp,
                yData: widget.featuresData.acc_y_pp,
                zData: widget.featuresData.acc_z_pp,
                unit: UnitSettingCache.homePageUnit.accUnitStr),
            FeatureCard(
                featureName: 'VEL(RMS)',
                xData: widget.featuresData.vel_x_rms,
                yData: widget.featuresData.vel_y_rms,
                zData: widget.featuresData.vel_z_rms,
                unit: UnitSettingCache.homePageUnit.velUnitStr),
            FeatureCard(
                featureName: 'DIS(P2P)',
                xData: widget.featuresData.dis_x_pp,
                yData: widget.featuresData.dis_y_pp,
                zData: widget.featuresData.dis_z_pp,
                unit: UnitSettingCache.homePageUnit.disUnitStr),
          ],
        ),
      ),
    );
  }

  Divider divider() {
    return const Divider(
      thickness: 1,
      indent: 20,
      endIndent: 20,
    );
  }

  Widget FeatureCard({required String featureName, required double xData, required double yData, required double zData, String unit = ""}) {
    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ValueDisplayWidget(title: "$featureName-X", value: xData, unit: unit),
              ),
              Expanded(
                child: ValueDisplayWidget(title: "$featureName-Y", value: yData, unit: unit),
              ),
              Expanded(
                child: ValueDisplayWidget(title: "$featureName-Z", value: zData, unit: unit),
              ),
            ],
          )
        ],
      ),
    );
  }

  Padding ValueDisplayWidget({required String title, required double value, required String unit}) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 3, bottom: 4),
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.blue),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      value.toStringAsFixed(2),
                      style: textStyle,
                    ),
                  ),
                ),
                unitWidget(text: unit)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget TextFieldOfData() {
    return const TextField();
  }

  Widget unitWidget({required String text}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, right: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 9),
      ),
    );
  }
}
