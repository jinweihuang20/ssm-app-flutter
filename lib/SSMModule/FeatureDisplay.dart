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
    return Column(
      children: [
        Card(
          color: Colors.black,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('OA-X', style: titleTextStyle),
                  Text('OA-Y', style: titleTextStyle),
                  Text('OA-Z', style: titleTextStyle),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    widget.featuresData.oa_x.toStringAsFixed(2),
                    style: textStyle,
                  ),
                  Text(
                    widget.featuresData.oa_y.toStringAsFixed(2),
                    style: textStyle,
                  ),
                  Text(
                    widget.featuresData.oa_z.toStringAsFixed(2),
                    style: textStyle,
                  ),
                ],
              )
            ],
          ),
        ),
        divider(),
        Card(
          color: Colors.black,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('ACC P2P-X', style: titleTextStyle),
                  Text('ACC P2P-Y', style: titleTextStyle),
                  Text('ACC P2P-Z', style: titleTextStyle),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    widget.featuresData.acc_x_pp.toStringAsFixed(2),
                    style: textStyle,
                  ),
                  Text(
                    widget.featuresData.acc_y_pp.toStringAsFixed(2),
                    style: textStyle,
                  ),
                  Text(
                    widget.featuresData.acc_z_pp.toStringAsFixed(2),
                    style: textStyle,
                  ),
                ],
              )
            ],
          ),
        ),
        divider(),
        Card(
          color: Colors.black,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('VEL RMS-X', style: titleTextStyle),
                  Text('VEL RMS-Y', style: titleTextStyle),
                  Text('VEL RMS-Z', style: titleTextStyle),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    widget.featuresData.vel_x_rms.toStringAsFixed(2),
                    style: textStyle,
                  ),
                  Text(
                    widget.featuresData.vel_y_rms.toStringAsFixed(2),
                    style: textStyle,
                  ),
                  Text(
                    widget.featuresData.vel_z_rms.toStringAsFixed(2),
                    style: textStyle,
                  ),
                ],
              )
            ],
          ),
        ),
        divider(),
        Card(
          color: Colors.black,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Dis P2P-X', style: titleTextStyle),
                  Text('DIS P2P-Y', style: titleTextStyle),
                  Text('DIS P2P-Z', style: titleTextStyle),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    widget.featuresData.dis_x_pp.toStringAsFixed(2),
                    style: textStyle,
                  ),
                  Text(
                    widget.featuresData.dis_y_pp.toStringAsFixed(2),
                    style: textStyle,
                  ),
                  Text(
                    widget.featuresData.dis_z_pp.toStringAsFixed(2),
                    style: textStyle,
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Divider divider() {
    return const Divider(
      thickness: 1,
      indent: 20,
      endIndent: 20,
    );
  }
}
