import 'dart:io';
import 'package:flutter/material.dart';

import '../../providers/user_provider.dart';
import './signup_location_screen.dart';
import '../../widgets/pickers/user_image_picker.dart';

class SignUpPhotoScreen extends StatefulWidget {
  static const routeName = '/signup-photo-screen';
  @override
  _SignUpPhotoScreenState createState() => _SignUpPhotoScreenState();
}

class _SignUpPhotoScreenState extends State<SignUpPhotoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  var userValues = UserProvider(
    id: null,
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    profilePicUrl: '',
    address: '',
  );

  File _userImageFile;

  void _saveName() {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    Navigator.of(context).pushNamed(SignUpLocationScreen.routeName,
        arguments: {'user': userValues, 'image': _userImageFile});
  }

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile Picture',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            width: screenWidth,
            decoration: BoxDecoration(
                // color: Theme.of(context).accentColor,
                ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: screenHeight * 0.055,
                  ),
                  Text(
                    'Add a profile picture',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.055,
                  ),
                  Container(
                    width: screenWidth * 0.85,
                    alignment: Alignment.center,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          UserImagePicker(_pickedImage),
                          Container(
                            padding: EdgeInsets.only(top: 40),
                            width: screenWidth,
                            child: FlatButton(
                              child: Text(
                                'Next',
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                              onPressed: _saveName,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30.0, vertical: 8.0),
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.025,
                          ),
                          Container(
                            alignment: Alignment.bottomCenter,
                            padding: EdgeInsets.only(
                              bottom: 10,
                            ),
                            child: new InkWell(
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              //TODO NAVIGATE TO NEXT SCREEN
                              onTap: () => Navigator.of(context).pushNamed(
                                  SignUpLocationScreen.routeName,
                                  arguments: userValues),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
