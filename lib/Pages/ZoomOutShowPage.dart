import 'dart:ffi';

import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:ssmflutter/Chartslb/SimpleLineChart.dart';

class ZoomOutPage extends StatefulWidget {
  ZoomOutPage({Key? key, required this.data, required this.onClose, required this.title, required this.xAxisTitle, required this.yAxisTitle}) : super(key: key);
  final String title;
  final String xAxisTitle;
  final String yAxisTitle;
  final List<SimpleData> data;
  _ZoomOutPageState state = _ZoomOutPageState();
  final Function(bool) onClose;
  @override
  State<ZoomOutPage> createState() => state;
}

class _ZoomOutPageState extends State<ZoomOutPage> {
  var data;
  var _pauseFlag = false;

  @override
  Widget build(BuildContext context) {
    print(data);
    if (data == null) {
      data = widget.data;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              IconButton(padding: EdgeInsets.all(1), onPressed: _pauseFlag ? null : _pause, icon: const Icon(Icons.pause_circle_outline)),
              IconButton(onPressed: !_pauseFlag ? null : _resume, icon: const Icon(Icons.play_arrow))
            ],
          )
        ],
      ),
      body: Center(
        child: SimpleLineChart(
          dataSetList: data,
          title: widget.title,
          xAxistTitle: widget.xAxisTitle,
          yAxisTitle: widget.yAxisTitle,
          ledgenPosition: BehaviorPosition.top,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    widget.onClose(true);
    print('disposed');
  }

  void _resume() {
    setState(() {
      _pauseFlag = false;
    });
  }

  void _pause() {
    setState(() {
      _pauseFlag = true;
    });
  }

  void update(List<SimpleData> list) {
    if (_pauseFlag) return;
    setState(() {
      data = list;
    });
  }
}
