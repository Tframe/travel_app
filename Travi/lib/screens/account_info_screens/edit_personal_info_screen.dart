/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: User Profile edit personal
 * information screen
 */
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../providers/user_provider.dart';
import './widgets/user_image_picker.dart';

class EditPersonalInfoScreen extends StatefulWidget {
  static const routeName = '/edit-personal-info-screen';
  @override
  _EditPersonalInfoScreenState createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState extends State<EditPersonalInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _locationFocusNode = FocusNode();
  User user;
  var userValues = UserProvider(
    id: null,
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    location: '',
  );

  // ignore: unused_field
  File _userImageFile;
  UserProvider _loadedUser;

  //sets image picked
  void _pickedImage(File image) {
    _userImageFile = image;
  }

  @override
  void dispose() {
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }

  void _saveNameAddress() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();

    try {
      await Provider.of<UserProvider>(context, listen: false)
          .updateUserNameLocation(userValues, user.uid);
    } catch (error) {
      print(error);
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    //final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    user = arguments['user'];
    _loadedUser = arguments['loadedUser'];
    setState(() {
      userValues = _loadedUser;
    });
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Personal Information'),
        bottom: PreferredSize(
          child: Container(
            color: Colors.grey[400],
            height: 1,
          ),
          preferredSize: Size.fromHeight(1.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: new IconThemeData(
          color: Theme.of(context).secondaryHeaderColor,
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
                  UserImagePicker(_pickedImage, user, _loadedUser),
                  Container(
                    width: screenWidth * 0.85,
                    alignment: Alignment.center,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          TextFormField(
                            cursorColor: Theme.of(context).buttonColor,
                            initialValue: userValues.firstName,
                            decoration: InputDecoration(
                              labelText: 'First Name',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).buttonColor,
                                ),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            focusNode: _firstNameFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_lastNameFocusNode);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your first name!';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              userValues.firstName = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).buttonColor,
                            initialValue: userValues.lastName,
                            decoration: InputDecoration(
                              labelText: 'Last Name',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).buttonColor,
                                ),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            focusNode: _lastNameFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_locationFocusNode);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your Last name!';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              userValues.lastName = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).buttonColor,
                            initialValue: userValues.location,
                            decoration: InputDecoration(
                              labelText: 'Location',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).buttonColor,
                                ),
                              ),
                            ),
                            textInputAction: TextInputAction.done,
                            focusNode: _locationFocusNode,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your location!';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              userValues.location = value;
                            },
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 40),
                            width: screenWidth,
                            child: FlatButton(
                              child: Text(
                                'Save',
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                              onPressed: _saveNameAddress,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30.0, vertical: 8.0),
                              color: Theme.of(context).buttonColor,
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
