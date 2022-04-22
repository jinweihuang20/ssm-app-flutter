import 'package:flutter/material.dart';

class PageState {
  String title;
  Icon icon;
  Widget pageWidget;
  Color iconColor;
  PageState({required this.pageWidget, required this.title, required this.icon, required this.iconColor});
}
