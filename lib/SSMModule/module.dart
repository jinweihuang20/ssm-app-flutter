// ignore_for_file: avoid_print, non_constant_identifier_names
import 'dart:async';
import 'dart:io';

import 'dart:typed_data';

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
  int lsb = 16384;
  List<int> accDataBuffer = [];
  Socket? _ssmSocket;

  var changeController = StreamController<AccDataRevDoneEvent>();
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
      _ssmSocket =
          await Socket.connect(ip, port, timeout: const Duration(seconds: 3));
      print('socket open');
      _ssmSocket?.listen((packet) {
        connected = true;
        packetHandle(packet);
      }, onError: (err) => errorHandler(err));
      return true;
    } catch (e) {
      connected = false;
      return false;
    }
  }

  void packetHandle(Uint8List packetRev) {
    if (isREADVLUE) {
      accDataBuffer.addAll(packetRev);
      print('$accDataByteRevNum/3072');
      if (accDataByteRevNum < 3072) {
      } else {
        print('rev-done');
        List<List<double>> data = convertDataByte(accDataBuffer);
        changeController.add(AccDataRevDoneEvent(data[0], data[1], data[2]));
        accDataBuffer.clear();
        _ssmSocket?.write('READVALUE\r\n');
      }
    } else {
      print(packetRev);
      if (packetRev.length >= 8) {
        isParameterSetDone = true;
      }
    }
  }

  List<List<double>> convertDataByte(List<int> accDataBuffer) {
    List<double> accX = [];
    List<double> accY = [];
    List<double> accZ = [];
    for (var i = 0; i < 512; i++) {
      accX.add((accDataBuffer[512 * 0 + i] + accDataBuffer[512 * 1 + i] * 256) /
          lsb);
      accY.add((accDataBuffer[512 * 2 + i] + accDataBuffer[512 * 3 + i] * 256) /
          lsb);
      accZ.add((accDataBuffer[512 * 4 + i] + accDataBuffer[512 * 5 + i] * 256) /
          lsb);
    }
    return [accX, accY, accZ];
  }

  void setRange(range) {
    this.range = range;
    writeParameter();
  }

  void readParameter() {
    try {
      _ssmSocket?.write('READSTVAL\r\n');
    } catch (e) {
      print(e);
    }
  }

  void writeParameter() {
    isREADVLUE = false;
    _ssmSocket?.add(param.byteToSend);
  }

  void startReadValue() async {
    setRange(8);
    while (!isParameterSetDone) {
      await Future.delayed(const Duration(seconds: 1));
    }

    await Future.delayed(const Duration(seconds: 1));
    isREADVLUE = true;
    _ssmSocket?.write('READVALUE\r\n');
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
    } catch (e) {}
  }
}

/// 事件類別
class AccDataRevDoneEvent {
  List<double> accData_X = [];
  List<double> accData_Y = [];
  List<double> accData_Z = [];
  AccDataRevDoneEvent(this.accData_X, this.accData_Y, this.accData_Z);
}

class ModuleParam {
  ModuleParam(this.range);

  final int range;

  get byteToSend {
    if (range == 2) {
      return [83, 1, 0, 159, 0, 0, 0, 0, 0, 13, 10];
    } else if (range == 4) {
      return [83, 1, 0, 159, 16, 0, 0, 0, 0, 13, 10];
    } else if (range == 8) {
      return [83, 1, 0, 159, 32, 0, 0, 0, 0, 13, 10];
    } else if (range == 16) {
      return [83, 1, 0, 159, 64, 0, 0, 0, 0, 13, 10];
    } else {
      return [83, 1, 0, 159, 0, 0, 0, 0, 0, 13, 10];
    }
  }
}
