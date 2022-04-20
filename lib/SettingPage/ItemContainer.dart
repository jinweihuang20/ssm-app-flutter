// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';

class ItemContainer extends StatefulWidget {
  ItemContainer(this.children) : super();
  List<Widget> children = [];
  @override
  State<StatefulWidget> createState() {
    return _ItemContainer(children);
  }
}

class _ItemContainer extends State<ItemContainer> {
  _ItemContainer(this.children);
  List<Widget> children = [];
  @override
  @override
  Widget build(BuildContext context) {
    return Row(
      children: children,
    );
  }
}
