import 'package:flutter/material.dart';

class ConnectingPage extends StatelessWidget {
  const ConnectingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: AlertDialog(
      content: const Text('Connecting...'),
    ));
  }
}
