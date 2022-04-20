// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';

class ItemTitle extends StatefulWidget {
  ItemTitle(this.title) : super();
  var title = 'title';
  @override
  State<StatefulWidget> createState() {
    return _ItemTitle(title);
  }
}

class _ItemTitle extends State<ItemTitle> {
  _ItemTitle(this.title);
  var title;
  @override
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(padding: EdgeInsets.only(left: 10)),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        )
      ],
    );
  }
}
