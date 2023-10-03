import 'dart:io';

import 'package:flutter/material.dart';

class ImageMessageTile extends StatelessWidget {
  final int index;
  final String imagePath;
  final String sender;
  final bool sentByMe;
  final int time;

  ImageMessageTile({
    required this.index,
    required this.imagePath,
    required this.sender,
    required this.sentByMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Customize the appearance of the image message tile as needed
      // You can display the image using `Image.file` or `Image.network`
      // depending on how the image is stored.
      child: Image.file(File(imagePath)),
    );
  }
}
