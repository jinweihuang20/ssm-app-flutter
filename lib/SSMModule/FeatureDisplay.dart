import 'package:flutter/material.dart';
import 'package:ssmflutter/SSMModule/module.dart';

class FeatureDisplay extends StatefulWidget {
  FeatureDisplay(this.featuresData);
  Features featuresData;
  @override
  State<FeatureDisplay> createState() => _FeatureDisplayState();
}

class _FeatureDisplayState extends State<FeatureDisplay> {
  TextStyle textStyle = const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 3);
  TextStyle titleTextStyle = const TextStyle(
    fontSize: 12,
  );
  @override
  Widget build(BuildContext context) {
    widget.featuresData ??= Features();
    return SingleChildScrollView(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 50, bottom: 10),
            child: Text(
              '特徵值',
              style: TextStyle(fontSize: 15),
            ),
          ),
          FeatureCard(featureName: 'OA', xData: widget.featuresData.oa_x, yData: widget.featuresData.oa_y, zData: widget.featuresData.oa_z),
          FeatureCard(featureName: 'ACC(P2P)', xData: widget.featuresData.acc_x_pp, yData: widget.featuresData.acc_y_pp, zData: widget.featuresData.acc_z_pp),
          FeatureCard(featureName: 'VEL(RMS)', xData: widget.featuresData.vel_x_rms, yData: widget.featuresData.vel_y_rms, zData: widget.featuresData.vel_z_rms),
          FeatureCard(featureName: 'DIS(P2P)', xData: widget.featuresData.dis_x_pp, yData: widget.featuresData.dis_y_pp, zData: widget.featuresData.dis_z_pp),
        ],
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

  Widget FeatureCard({
    required String featureName,
    required double xData,
    required double yData,
    required double zData,
  }) {
    return Card(
      color: Colors.black,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('$featureName-X', style: titleTextStyle),
              Text('$featureName-Y', style: titleTextStyle),
              Text('$featureName-Z', style: titleTextStyle),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                xData.toStringAsFixed(2),
                style: textStyle,
              ),
              Text(
                yData.toStringAsFixed(2),
                style: textStyle,
              ),
              Text(
                zData.toStringAsFixed(2),
                style: textStyle,
              ),
            ],
          )
        ],
      ),
    );
  }
}
