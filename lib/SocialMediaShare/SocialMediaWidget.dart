import 'package:flutter/material.dart';

class SocialMediaShareWidget extends StatelessWidget {
  const SocialMediaShareWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: IconButton(
            icon: const Icon(Icons.discord),
            onPressed: () => {print('discord share')},
          ),
        ),
        Expanded(
          child: IconButton(
            icon: const Icon(Icons.facebook),
            onPressed: () => {print('facebook share')},
          ),
        ),
        Expanded(
          child: IconButton(
            icon: const Icon(Icons.wechat),
            onPressed: () => {print('wechat share')},
          ),
        )
      ],
    );
  }
}
