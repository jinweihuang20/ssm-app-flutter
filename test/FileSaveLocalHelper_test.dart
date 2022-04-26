import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ssmflutter/Storage/FileSaveLocalHelper.dart';

void main() {
  test('getFilePathToSave-Test', () async {
    getFilePath('test.csv').then((value) => print(value));
  });

  test('saveFile-Test', () async {
    saveFile('test.csv', 'fuck=6999');
  });
}
