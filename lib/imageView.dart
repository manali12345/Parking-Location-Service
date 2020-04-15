import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ViewImage extends StatelessWidget {
  File image;
  ViewImage(File image) {
    this.image = image;
  }

  @override
  Widget build(BuildContext context) {
    print(image);
    return Container(
        child: PhotoView(
          imageProvider: FileImage(image),
        )
    );
  }
}
