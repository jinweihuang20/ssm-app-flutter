import 'package:ssmflutter/SSMModule/module.dart';

enum ACC_UNIT { g, m_s2 }

enum VEL_UNIT { mm_s, um_s }

enum DIS_UNIT { mm, um }

enum UNIT_TYPE { ACC, VEL, DIS }

class UnitData {
  ACC_UNIT accUnit = ACC_UNIT.g;
  VEL_UNIT velUnit = VEL_UNIT.mm_s;
  DIS_UNIT disUnit = DIS_UNIT.um;

  String get accUnitStr => accUnitConvert(accUnit);
  String get velUnitStr => velUnitConvert(velUnit);
  String get disUnitStr => disUnit.name;

  dynamic source;

  UnitData({this.source = ""});
}

String velUnitConvert(VEL_UNIT velUnit) {
  if (velUnit == VEL_UNIT.mm_s) {
    return "mm/s";
  } else if (velUnit == VEL_UNIT.um_s) {
    return "um/s";
  } else
    return "";
}

String accUnitConvert(ACC_UNIT accUnit) {
  if (accUnit == ACC_UNIT.g) {
    return "G";
  } else if (accUnit == ACC_UNIT.m_s2) {
    return "m/s^2";
  } else {
    return "";
  }
}

Features convertByUnit(Features features, UnitData unit) {
  double acc_ratio = unit.accUnit == ACC_UNIT.g ? 1 : 9.8;
  double vel_ratio = unit.velUnit == VEL_UNIT.mm_s ? 1 : 1000.0;
  double dis_ratio = unit.disUnit == DIS_UNIT.um ? 1 : 0.001;

  Features featuresConverted = Features();

  featuresConverted.oa_x = features.oa_x * acc_ratio;
  featuresConverted.oa_y = features.oa_y * acc_ratio;
  featuresConverted.oa_z = features.oa_z * acc_ratio;

  featuresConverted.acc_x_pp = features.acc_x_pp * acc_ratio;
  featuresConverted.acc_y_pp = features.acc_y_pp * acc_ratio;
  featuresConverted.acc_z_pp = features.acc_z_pp * acc_ratio;

  featuresConverted.vel_x_rms = features.vel_x_rms * vel_ratio;
  featuresConverted.vel_y_rms = features.vel_y_rms * vel_ratio;
  featuresConverted.vel_z_rms = features.vel_z_rms * vel_ratio;

  featuresConverted.dis_x_pp = features.dis_x_pp * dis_ratio;
  featuresConverted.dis_y_pp = features.dis_y_pp * dis_ratio;
  featuresConverted.dis_z_pp = features.dis_z_pp * dis_ratio;

  return featuresConverted;
}
