// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ssmflutter/Chartslb/SimpleLineChart.dart';
import 'package:ssmflutter/Chartslb/TimeLineChart.dart';
import 'package:ssmflutter/SocialMediaShare/SocialMediaWidget.dart';
import 'package:flutter_share/flutter_share.dart';

Future<Directory> downloadsDirectory = DownloadsPathProvider.downloadsDirectory;

Future<String> getFilePath(String fileNameWithExtension) async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }

  Directory appDocumentsDirectory = await downloadsDirectory; // 1
  String appDocumentsPath = appDocumentsDirectory.path; // 2
  String filePath = '$appDocumentsPath/$fileNameWithExtension'; // 3
  return filePath;
}

Future<String> saveFile(String fileNameWithExtension, String text) async {
  try {
    String filePath = await getFilePath(fileNameWithExtension);
    File file = File(filePath);
    await file.writeAsString(text);
    return filePath;
  } catch (e) {
    return 'err';
  }
}

Future<String> saveRawAccData(String fileNameWithExtension, List<SimpleData> accData) async {
  return await saveFile(fileNameWithExtension, _createRawAccCsvText(accData));
}

String _createRawAccCsvText(List<SimpleData> accData) {
  String text = "Index,X,Y,Z\r\n";

  List.generate(accData[0].xList.length, (index) {
    String _index = accData[0].xList[index].toStringAsFixed(0);
    String x = accData[0].values[index].toString();
    String y = accData[1].values[index].toString();
    String z = accData[2].values[index].toString();

    text += '$_index,$x,$y,$z\r\n';
  });

  return text;
}

Future<String> saveQueryPageData(String fileNameWithExtension, List<TimeData> accData, List<TimeData> velData, List<TimeData> disData) async {
  return await saveFile(fileNameWithExtension, _createQueryPageDataText(accData, velData, disData));
}

String _createQueryPageDataText(List<TimeData> accData, List<TimeData> velData, List<TimeData> disData) {
  String text = " Time,Acc(P2P)-X,Acc(P2P)-Y,Acc(P2P)-Z,Vel(RMS)-X,Vel(RMS)-Y,Vel(RMS)-Z,Dis(P2P)-X,Dis(P2P)-Y,Dis(P2P)-Z\r\n";
  int dataLen = accData[0].timeList.length;

  List.generate(dataLen, (index) {
    var time = accData[0].timeList[index];
    double accx = accData[0].values[index];
    double accy = accData[1].values[index];
    double accz = accData[2].values[index];

    double velx = velData[0].values[index];
    double vely = velData[1].values[index];
    double velz = velData[2].values[index];

    double disx = disData[0].values[index];
    double disy = disData[1].values[index];
    double disz = disData[2].values[index];
    text += "${time.toIso8601String()},$accx,$accy,$accz,$velx,$vely,$velz,$disx,$disy,$disz\r\n";
  });

  return text;
}

class FileNameHelper {
  static get fileName {
    return _textFieldController.text;
  }

  static TextEditingController _textFieldController = TextEditingController(text: "");

  static Future<String> displayTextInputDialog(BuildContext context, {String titleName = ""}) async {
    String fileName = "";
    await showDialog(
      barrierDismissible: false,
      barrierLabel: "???",
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titleName),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: "Text Field in Dialog", labelText: "????????????"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('CANCEL'),
              onPressed: () {
                _textFieldController = TextEditingController(text: "");
                fileName = "";
                Navigator.pop(context, 'cancel');
              },
            ),
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                fileName = _textFieldController.text;
                print(_textFieldController.text);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
    return fileName;
  }
}

Future<void> showSaveDoneDialog(BuildContext context, {String filePath = ""}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: TextButton.icon(
            onPressed: () => {},
            icon: const Icon(Icons.check),
            label: const Text('Save OK !'),
            style: ElevatedButton.styleFrom(
              primary: Colors.transparent,
              onPrimary: Colors.white,
              textStyle: const TextStyle(fontSize: 22, color: Colors.white),
            )),
        contentPadding: const EdgeInsets.only(top: 20, right: 20, left: 20),
        content: SizedBox(
          height: 110,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("???????????????:$filePath"),
              const Divider(
                thickness: 2,
              ),
              TextButton.icon(
                  onPressed: () {
                    _share(filePath);
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('???????????????')),
              // const SocialMediaShareWidget(),
            ],
          ),
        ),
        actions: <Widget>[
          const Divider(
            thickness: 2,
          ),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text('OK'),
                style: ElevatedButton.styleFrom(primary: Colors.white, onPrimary: Colors.grey),
                onPressed: () {
                  Navigator.pop(context);
                },
              )),
        ],
      );
    },
  );
}

void _share(String filePath) async {
  if (filePath == "") return;
  await FlutterShare.shareFile(
    title: 'Example share',
    text: 'SSM Module Data Share.',
    filePath: filePath,
  );
}
