// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';

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
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: Container(
        color: Colors.blueGrey.shade800,
        padding: const EdgeInsets.only(left: 8, right: 9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: widget.children,
        ),
      ),
    );
  }
}
