import 'dart:io';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

class ImageVideoPicker extends StatefulWidget {
  final void Function(File pickedImage) imagePickFn;

  ImageVideoPicker(this.imagePickFn);

  @override
  _ImageVideoPickerState createState() => _ImageVideoPickerState();
}

class _ImageVideoPickerState extends State<ImageVideoPicker> {
  File _pickedImage;

  Future<void> getImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.camera);
    File pickedImageFile = File(pickedImage.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    //widget.imagePickFn(pickedImageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('HI'),
    );
  }
}
