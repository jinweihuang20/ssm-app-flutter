// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';

class ItemTitle extends StatelessWidget {
  const ItemTitle({Key? key, required this.text, this.icon}) : super(key: key);

  final text;
  final Icon? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 12, left: 4),
      child: Row(
        children: [
          Padding(
              padding: const EdgeInsets.only(right: 5),
              child: icon ??
                  const Icon(
                    Icons.my_library_books_sharp,
                    size: 17,
                  )),
          Text(text)
        ],
      ),
    );
  }
}
