import 'package:ssmflutter/SSMModule/module.dart';

class SensorData {
  final DateTime time;
  final double accXPp;
  final double accYPp;
  final double accZPp;
  final double velXRms;
  final double velYRms;
  final double velZRms;
  final double disXpp;
  final double disYpp;
  final double disZpp;
  final String sensorIP;
  SensorData(this.sensorIP, this.time, this.accXPp, this.accYPp, this.accZPp, this.velXRms, this.velYRms, this.velZRms, this.disXpp, this.disYpp, this.disZpp);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sensorIP': sensorIP,
      'time': time.toIso8601String(),
      'acc_x_pp': accXPp,
      'acc_y_pp': accYPp,
      'acc_z_pp': accZPp,
      'vel_x_rms': velXRms,
      'vel_y_rms': velYRms,
      'vel_z_rms': velZRms,
      'dis_x_pp': disXpp,
      'dis_y_pp': disYpp,
      'dis_z_pp': disZpp,
    };
  }
}
