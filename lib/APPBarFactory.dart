import 'package:flutter/material.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _showConnectPage,
      icon: const Icon(Icons.cast_connected_rounded),
    );
  }

  void _showConnectPage() {
    Navigator.pushNamed(context, "/connect");
  }
}
