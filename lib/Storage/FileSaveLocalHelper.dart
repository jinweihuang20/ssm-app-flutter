import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ssmflutter/Chartslb/SimpleLineChart.dart';

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
  String filePath = await getFilePath(fileNameWithExtension);
  File file = File(filePath);
  await file.writeAsString(text);
  return filePath;
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

class FileNameHelper {
  static get fileName {
    return _textFieldController.text;
  }

  static TextEditingController _textFieldController = TextEditingController(text: "");

  static Future<void> displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('時/頻圖數據儲存'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: "Text Field in Dialog", labelText: "檔案名稱"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('CANCEL'),
              onPressed: () {
                _textFieldController = TextEditingController(text: "");
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                print(_textFieldController.text);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showSaveDoneDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save OK !'),
          content: Text("檔案已儲存 " + _textFieldController.text),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                print(_textFieldController.text);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
