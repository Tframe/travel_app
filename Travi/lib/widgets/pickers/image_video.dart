/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: widget for picking either an image or video
 */
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';

class ImageVideo {
  //gets and returns file information for image
  Future<File> getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: source);
    File pickedImageFile = File(pickedImage.path);
    return pickedImageFile;
  }

  //gets and returns the file information for video
  Future<File> getVideo(ImageSource source) async {
    final picker = ImagePicker();
    final pickedVideo = await picker.getVideo(source: source);
    await VideoCompress.setLogLevel(0);
    final info = await VideoCompress.compressVideo(
      pickedVideo.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
      includeAudio: true,
    );
    if (info != null) {
      File pickedVideoFile = File(info.path);
      return pickedVideoFile;
    } else {
      return null;
    }
  }
}
