// ignore_for_file: avoid_print, empty_catches
import 'dart:io';
import 'dart:math' as math;
import "dart:typed_data";
import 'package:flutter/material.dart';

class Emulator {
  static String ip = '127.0.0.1';
  static int port = 5000;
  static ServerSocket? serverSocket;
}

void start(String ip, int port) {
  ServerSocket.bind(ip, port).then((serverSocket) => {
        Emulator.serverSocket = serverSocket,
        Emulator.ip = ip,
        Emulator.port = port,
        print('server build..$ip:$port'),
        serverSocket.listen((client) async {
          client.listen((data) async {
            if (data[0] == 83) {
              client.add(data.sublist(1, 9));
            }
            if (String.fromCharCodes(data).contains('READVALUE')) {
              var data = await fakeData();
              client.add(data);
            }
          });
        })
      });
}

Future<List<int>> fakeData() async {
  List<int> ls = List.filled(3072, 0);
  List<int> x = sineWave(233);
  List<int> y = sineWave(1200);
  List<int> z = sineWave(2000);
  for (var i = 0; i < 512; i++) {
    var bytesX = intToBytes(x[i]);
    var bytesY = intToBytes(y[i]);
    var bytesZ = intToBytes(z[i]);
    int lowx = bytesX[0];
    int highx = bytesX[1];
    int lowy = bytesY[0];
    int highy = bytesY[1];
    int lowz = bytesZ[0];
    int highz = bytesZ[1];

    ls[i] = lowx;
    ls[i + 512] = highx;
    ls[i + 1024] = lowy;
    ls[i + 1024 + 512] = highy;
    ls[i + 2048] = lowz;
    ls[i + 2048 + 512] = highz;
    //0 512 , 1 513 , 2 514  511 1023    1024 1536
  }
  return ls;
}

List<int> sineWave(freq) {
  List<int> ls = [];
  for (var i = 0; i < 512; i++) {
    var d = (_sinPt(i, freq) * 5 * 1000).toStringAsFixed(0);
    ls.add(int.parse(d));
  }
  return ls;
}

List<int> intToBytes(int value) {
  var bdata = ByteData(8);
  bdata.setInt32(0, value);
  int low = bdata.getUint16(0);
  int high = bdata.getUint16(1);
  return [high, low];
}

double _sinPt(int number, freq) {
  var sampleFreq = 8000.0 / freq;
  var noise = 10000 * math.Random().nextDouble();
  return noise + 32700 * math.sin(number / (sampleFreq / (math.pi * 2)));
}

void restart() {
  try {
    Emulator.serverSocket?.close();
  } catch (err) {}
  start(Emulator.ip, Emulator.port);
}
