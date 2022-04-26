import 'package:flutter/material.dart';

Widget iconButton({required String text, required Color color, required Function() onPressed}) {
  return Padding(
      padding: const EdgeInsets.all(6),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), primary: color),
      ));
}
