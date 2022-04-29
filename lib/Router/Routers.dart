import 'package:flutter/material.dart';

class PageState {
  String title;
  dynamic icon;
  Widget pageWidget;
  Widget appBarWidget = const Text("");
  Color iconColor;
  MyBadgeState badgeState;
  PageState({required this.pageWidget, required this.title, required this.icon, required this.iconColor, required this.badgeState});
}

class MyBadgeState {
  bool showBadge = false;
  MyBadgeState({required this.showBadge});
}
