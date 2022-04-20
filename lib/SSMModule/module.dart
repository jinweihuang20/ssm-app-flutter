// ignore_for_file: avoid_print, non_constant_identifier_names, empty_catches
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:ssmflutter/MathLib/FeatureCalculator.dart';

class Module {
  Module({required this.ip, required this.port});

  final String ip;
  final int port;

  set range(v) {
    param = ModuleParam(v);
  }

  ModuleParam param = ModuleParam(2);
  bool isREADVLUE = false;
  bool isParameterSetDone = false;
  List<int> accDataBuffer = [];
  Socket? _ssmSocket;

  StreamController<AccDataRevDoneEvent> changeController = StreamController<AccDataRevDoneEvent>();
  Stream<AccDataRevDoneEvent> get accDataOnChange => changeController.stream;

  get accDataByteRevNum {
    return accDataBuffer.length;
  }

  get ssmSocket {
    return _ssmSocket;
  }

  get range {
    return param.range;
  }

  String? get address => ip + ":" + port.toString();

  bool? connected = false;

  Future<bool> connect() async {
    try {
      _ssmSocket = await Socket.connect(ip, port, timeout: const Duration(seconds: 3));
      print('socket open');
      _ssmSocket?.listen((packet) {
        connected = true;
        packetHandle(packet);
      }, onError: (err) => errorHandler(err), onDone: () => {print('done')});
      return true;
    } catch (e) {
      connected = false;
      return false;
    }
  }

  void packetHandle(Uint8List packetRev) async {
    if (isREADVLUE) {
      accDataBuffer.addAll(packetRev);
      if (accDataByteRevNum < 3072) {
      } else {
        double samplingRate = 8000;
        List<List<double>> data = convertDataByte(accDataBuffer);
        var acc_x = data[0];
        var acc_y = data[1];
        var acc_z = data[2];
        var fft_x = toFFT(acc_x);
        var fft_y = toFFT(acc_y);
        var fft_z = toFFT(acc_z);

        var vel_x = toVelocityList(acc_x, samplingRate);
        var vel_y = toVelocityList(acc_y, samplingRate);
        var vel_z = toVelocityList(acc_z, samplingRate);

        var dis_x = toDisplacementList(vel_x, samplingRate);
        var dis_y = toDisplacementList(vel_y, samplingRate);
        var dis_z = toDisplacementList(vel_z, samplingRate);
        Features features = Features();
        features.oa_x = toOA(fft_x);
        features.oa_y = toOA(fft_y);
        features.oa_z = toOA(fft_z);

        features.acc_x_pp = toP2P(acc_x);
        features.acc_y_pp = toP2P(acc_y);
        features.acc_z_pp = toP2P(acc_z);

        features.vel_x_rms = toRMS(vel_x);
        features.vel_y_rms = toRMS(vel_y);
        features.vel_z_rms = toRMS(vel_z);

        features.dis_x_pp = toP2P(dis_x);
        features.dis_y_pp = toP2P(dis_y);
        features.dis_z_pp = toP2P(dis_z);

        changeController.add(AccDataRevDoneEvent(data[0], data[1], data[2], fft_x, fft_y, fft_z, features));
        accDataBuffer.clear();
        await Future.delayed(const Duration(microseconds: 600));
        try {
          _ssmSocket?.write('READVALUE\r\n');
        } catch (e) {
          print(e);
        }
      }
    } else {
      print(packetRev);
      if (packetRev.length == 8) {
        accDataBuffer.clear();
        isParameterSetDone = true;
        _ssmSocket?.write('READVALUE\r\n');
      }
    }
  }

  List<List<double>> convertDataByte(List<int> accDataBuffer) {
    List<double> accX = [];
    List<double> accY = [];
    List<double> accZ = [];
    int lsb = param.lsb;
    for (var i = 0; i < 512; i++) {
      var dx = toInt16([accDataBuffer[512 * 1 + i], accDataBuffer[512 * 0 + i]]);
      var dy = toInt16([accDataBuffer[512 * 3 + i], accDataBuffer[512 * 2 + i]]);
      var dz = toInt16([accDataBuffer[512 * 5 + i], accDataBuffer[512 * 4 + i]]);
      accX.add(dx / lsb);
      accY.add(dy / lsb);
      accZ.add(dz / lsb);
    }
    return [accX, accY, accZ];
  }

  static int toInt16(List<int> list, {int index = 0}) {
    Uint8List byteArray = Uint8List.fromList(list);
    ByteBuffer buffer = byteArray.buffer;
    ByteData data = ByteData.view(buffer);
    int short = data.getInt16(index, Endian.big);
    return short;
  }

  Future<bool> setRange(range) async {
    this.range = range;
    return await writeParameter();
  }

  Future<bool> writeParameter() async {
    isParameterSetDone = false;
    isREADVLUE = false;
    await Future.delayed(const Duration(seconds: 3));
    _ssmSocket?.add(param.byteToSend);

    while (!isParameterSetDone) {
      await Future.delayed(const Duration(seconds: 1));
    }
    print('p s-done');
    isREADVLUE = true;
    _ssmSocket?.write('READVALUE\r\n');

    return true;
  }

  void startReadValue() async {
    await setRange(2);

    await Future.delayed(const Duration(seconds: 1));
    try {
      isREADVLUE = true;
      _ssmSocket?.write('READVALUE\r\n');
    } catch (e) {
      print(e.toString());
    }
  }

  void errorHandler(er) {
    print(er);
  }

  void close() {
    try {
      _ssmSocket?.close();
      connected = false;
      accDataBuffer.clear();
      print('socket close');
    } catch (e) {
      print('socket close');
    }
  }
}

/// 事件類別
class AccDataRevDoneEvent {
  List<double> accData_X = [];
  List<double> accData_Y = [];
  List<double> accData_Z = [];
  List<double> fftData_X = [];
  List<double> fftData_Y = [];
  List<double> fftData_Z = [];
  Features features = Features();
  AccDataRevDoneEvent(this.accData_X, this.accData_Y, this.accData_Z, this.fftData_X, this.fftData_Y, this.fftData_Z, this.features);
}

///特徵值
class Features {
  double oa_x = 0;
  double oa_y = 0;
  double oa_z = 0;
  double acc_x_pp = 0;
  double acc_y_pp = 0;
  double acc_z_pp = 0;

  double vel_x_rms = 0;
  double vel_y_rms = 0;
  double vel_z_rms = 0;

  double dis_x_pp = 0;
  double dis_y_pp = 0;
  double dis_z_pp = 0;
}

///參數
class ModuleParam {
  ModuleParam(this.range);

  final int range;
  int lsb = 16384;
  get byteToSend {
    if (range == 2) {
      lsb = 16384;
      return [83, 1, 0, 159, 0, 0, 0, 0, 0, 13, 10];
    } else if (range == 4) {
      lsb = 8192;
      return [83, 1, 0, 159, 16, 0, 0, 0, 0, 13, 10];
    } else if (range == 8) {
      lsb = 4096;
      return [83, 1, 0, 159, 32, 0, 0, 0, 0, 13, 10];
    } else if (range == 16) {
      lsb = 2048;
      return [83, 1, 0, 159, 64, 0, 0, 0, 0, 13, 10];
    } else {
      lsb = 16384;
      return [83, 1, 0, 159, 0, 0, 0, 0, 0, 13, 10];
    }
  }
}
