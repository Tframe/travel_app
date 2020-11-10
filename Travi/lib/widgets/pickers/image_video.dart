import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImageVideo {

  Future<File> getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: source);
    File pickedImageFile = File(pickedImage.path);
    return pickedImageFile;
  }

  Future<File> getVideo(ImageSource source) async {
    final picker = ImagePicker();
    final pickedVideo = await picker.getVideo(source: source);
    File pickedVideoFile = File(pickedVideo.path);
    return pickedVideoFile;
  }

}