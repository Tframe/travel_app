import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:groupy/providers/user_provider.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File pickedImage) imagePickFn;
  User user;
  UserProvider _loadeduser;

  UserImagePicker(this.imagePickFn, this.user, this._loadeduser);

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File _pickedImage;

  //Get image and store as new profile pic
  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.camera);
    File pickedImageFile = File(pickedImage.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    widget.imagePickFn(pickedImageFile);

    final ref = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child(widget.user.uid + '.jpg');

    await ref.putFile(_pickedImage).onComplete;
    final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .update({
      'profilePicUrl': url,
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: _pickImage,
      child: Padding(
        padding: EdgeInsets.only(top: screenHeight * 0.075),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: screenWidth * 0.17,
          child: CircleAvatar(
            radius: screenWidth * 0.16,
            backgroundColor: Colors.grey,
            backgroundImage: widget._loadeduser.profilePicUrl != null
                ? NetworkImage(widget._loadeduser.profilePicUrl)
                //Make a No Image ImageProvider
                : (_pickedImage != null ? FileImage(_pickedImage) : null),
          ),
        ),
      ),
    );
  }
}
