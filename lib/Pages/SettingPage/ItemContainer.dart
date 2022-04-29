// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';
import 'package:ssmflutter/SysSetting.dart';

class ItemContainer extends StatefulWidget {
  const ItemContainer({Key? key, required this.children}) : super(key: key);
  final List<Widget> children;
  @override
  State<StatefulWidget> createState() {
    return _ItemContainer();
  }
}

class _ItemContainer extends State<ItemContainer> {
  _ItemContainer();
  @override
  Widget build(BuildContext context) {
    Color backgroundColor = User.setting.appTheme == 'light' ? Colors.grey : Colors.blueGrey.shade800;
    return Padding(
      padding: EdgeInsets.only(
        top: 5,
      ),
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.only(left: 8, right: 9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: widget.children,
        ),
      ),
    );
  }
}
