import 'package:flutter/cupertino.dart';
import 'package:ssmflutter/SSMModule/module.dart';

class ShareDataWidget extends InheritedWidget {
  ShareDataWidget({required Widget child, required this.module}) : super(child: child);
  final Module module;

  static ShareDataWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType();
  }

  @override
  bool updateShouldNotify(ShareDataWidget oldWidget) {
    return oldWidget.module.dataUpdateTime != oldWidget.module.dataUpdateTime;
  }
}

class ShareData {}
