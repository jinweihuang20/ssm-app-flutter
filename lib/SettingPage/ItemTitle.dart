// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';

class ItemTitle extends StatefulWidget {
  ItemTitle({required this.text, this.icon});
  final text;
  final Icon? icon;
  @override
  State<StatefulWidget> createState() {
    return _ItemTitle();
  }
}

class _ItemTitle extends State<ItemTitle> {
  _ItemTitle();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 12, left: 4),
      child: Row(
        children: [
          Padding(
              padding: EdgeInsets.only(right: 5),
              child: widget.icon == null
                  ? Icon(
                      Icons.my_library_books_sharp,
                      size: 17,
                    )
                  : widget.icon),
          Text(widget.text)
        ],
      ),
    );
  }
}
