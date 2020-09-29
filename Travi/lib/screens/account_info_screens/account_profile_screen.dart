import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../providers/user_provider.dart';

import './widgets/user_image_picker.dart';
import './widgets/personal_info.dart';
import './widgets/about_section.dart';
import './widgets/contact_info.dart';
import './edit_personal_info_screen.dart';

class AccountProfileScreen extends StatefulWidget {
  static const routeName = '/account-profile-screen';
  @override
  _AccountProfileScreenState createState() => _AccountProfileScreenState();
}

class _AccountProfileScreenState extends State<AccountProfileScreen> {
  // ignore: unused_field
  File _userImageFile;
  User user;
  UserProvider _loadedUser;

  //sets image picked
  void _pickedImage(File image) {
    setState(() {
      _userImageFile = image;
      _setUser(user);
    });
  }

  //Sets the current user based on UserId
  Future<bool> _setUser(User user) async {
    try {
      _loadedUser = await Provider.of<UserProvider>(context, listen: false)
          .findUserById(user.uid);
    } catch (error) {
      print(error);
      return false;
    }
    return true;
  }

  @override
  void initState() {
    user = FirebaseAuth.instance.currentUser;
    _setUser(user);
    super.initState();
  }

  void _editPersonalInfo() {
    Navigator.of(context).pushNamed(
      EditPersonalInfoScreen.routeName,
      arguments: {'loadedUser': _loadedUser, 'user': user},
    ).then((value) {
      setState(() {
        //To rebuild with new user information...
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Account Profile',
          style: TextStyle(
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ),
        iconTheme: new IconThemeData(
          color: Theme.of(context).secondaryHeaderColor,
        ),
      ),
      body: FutureBuilder(
        future: _setUser(user),
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        height: screenHeight * 0.18,
                        width: double.infinity,
                        color: Colors.grey[400],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: screenWidth * (0.5 - 0.17),
                                bottom: screenHeight * 0.0125),
                            child: UserImagePicker(
                                _pickedImage, user, _loadedUser),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.18),
                            child: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: _editPersonalInfo,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  PersonalInfo(_loadedUser, user),
                  Divider(
                    thickness: 8,
                  ),
                  AboutSection(_loadedUser, user),
                  Divider(
                    thickness: 8,
                  ),
                  ContactInfo(_loadedUser, user),
                  Divider(
                    thickness: 8,
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
