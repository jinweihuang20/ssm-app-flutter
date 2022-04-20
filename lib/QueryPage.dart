import 'package:flutter/material.dart';

class QueryPage extends StatefulWidget {
  const QueryPage({Key? key}) : super(key: key);

  @override
  State<QueryPage> createState() => _QueryPage();
}

class _QueryPage extends State<QueryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting'),
      ),
      body: Container(
        child: const Text('This is Query page'),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
