import 'package:ssmflutter/SSMModule/module.dart';

class SensorData {
  final DateTime time;
  final double acc_x_pp;
  final double acc_y_pp;
  final double acc_z_pp;
  final double vel_x_rms;
  final double vel_y_rms;
  final double vel_z_rms;
  final double dis_x_pp;
  final double dis_y_pp;
  final double dis_z_pp;
  final String sensorIP;
  SensorData(
      this.sensorIP,
      this.time,
      this.acc_x_pp,
      this.acc_y_pp,
      this.acc_z_pp,
      this.vel_x_rms,
      this.vel_y_rms,
      this.vel_z_rms,
      this.dis_x_pp,
      this.dis_y_pp,
      this.dis_z_pp);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sensorIP': this.sensorIP,
      'time': this.time.toIso8601String(),
      'acc_x_pp': this.acc_x_pp,
      'acc_y_pp': this.acc_y_pp,
      'acc_z_pp': this.acc_z_pp,
      'vel_x_rms': this.vel_x_rms,
      'vel_y_rms': this.vel_y_rms,
      'vel_z_rms': this.vel_z_rms,
      'dis_x_pp': this.dis_x_pp,
      'dis_y_pp': this.dis_y_pp,
      'dis_z_pp': this.dis_z_pp,
    };
  }
}
