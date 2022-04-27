import 'dart:async';

import 'package:flutter/material.dart';

class MeasureRangeDropDownBtn extends StatefulWidget {
  MeasureRangeDropDownBtn({required this.onRangeSelected});
  final Function(int) onRangeSelected;
  @override
  State<StatefulWidget> createState() => _MeasureRangeDropDownBtn(this.onRangeSelected);
}

class _MeasureRangeDropDownBtn extends State<MeasureRangeDropDownBtn> {
  _MeasureRangeDropDownBtn(this.onRangeSelected);
  final Function(int) onRangeSelected;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DropdownButton(
          items: _ranges,
          onChanged: rangeOnChanageHandle,
          value: _range,
        )
      ],
    );
  }

  var _range = 2;

  final List<DropdownMenuItem> _ranges = const [
    DropdownMenuItem(
      child: Text('2G'),
      value: 2,
    ),
    DropdownMenuItem(
      child: Text('4G'),
      value: 4,
    ),
    DropdownMenuItem(
      child: Text('8G'),
      value: 8,
    ),
    DropdownMenuItem(
      child: Text('16G'),
      value: 16,
    ),
  ];

  void rangeOnChanageHandle(range) {
    setState(() {
      onRangeSelected(range);
      _range = range;
    });
  }
}
