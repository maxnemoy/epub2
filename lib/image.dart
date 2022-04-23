import 'dart:typed_data';

import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final List<int> bytes;
  const ImageViewer({Key? key, required this.bytes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Image(image: MemoryImage(Uint8List.fromList(bytes)), fit: BoxFit.fitHeight,)),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        )
      ],
    ));
  }
}
