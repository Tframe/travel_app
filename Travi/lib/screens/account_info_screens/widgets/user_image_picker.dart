/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: User Profile user image widget.
 * Allows user to tap image to upload new images and
 * save as profile image.
 */
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:groupy/providers/user_provider.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File pickedImage) imagePickFn;
  final User user;
  final UserProvider _loadeduser;

  UserImagePicker(this.imagePickFn, this.user, this._loadeduser);

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File _pickedImage;

  //Get image and store as new profile pic
  void _getImage(bool takePhoto) async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
      source: takePhoto ? ImageSource.camera : ImageSource.gallery,
    );
    File pickedImageFile = File(pickedImage.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    widget.imagePickFn(pickedImageFile);

    //stores image in firebase storage
    final ref = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child(widget.user.uid + '.jpg');

    //gets the newly stored image's url
    await ref.putFile(_pickedImage).onComplete;
    final url = await ref.getDownloadURL();

    //saves/updates new profile picture url
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .update({
      'profilePicUrl': url,
    });
    Navigator.of(context).pop();
  }

  _showMaterialDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Photo'),
        content: const Text('Take a new photo or select one from your gallery'),
        actions: [
          FlatButton(
            onPressed: () => _getImage(true),
            child: const Text(
              'Take a new photo',
            ),
          ),
          FlatButton(
            onPressed: () => _getImage(false),
            child: const Text(
              'Choose from gallery',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: _showMaterialDialog,
      child: Padding(
        padding: EdgeInsets.only(top: screenHeight * 0.075),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: screenWidth * 0.17,
          child: CircleAvatar(
            radius: screenWidth * 0.16,
            backgroundColor: Colors.grey,
            backgroundImage: (_pickedImage != null
                ? FileImage(_pickedImage)
                : widget._loadeduser.profilePicUrl != null
                    ? NetworkImage(widget._loadeduser.profilePicUrl)
                    //Make a No Image ImageProvider
                    : null),
          ),
        ),
      ),
    );
  }
}
