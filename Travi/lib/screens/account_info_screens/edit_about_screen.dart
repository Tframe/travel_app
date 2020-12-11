/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: User Profile edit the
 * about section scren.
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/user_provider.dart';

class EditAboutScreen extends StatefulWidget {
  static const routeName = '/edit-about-screen';
  @override
  _EditAboutScreenState createState() => _EditAboutScreenState();
}

class _EditAboutScreenState extends State<EditAboutScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _aboutFocusNode = FocusNode();

  User user;
  var userValues = UserProvider(
    id: null,
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    location: '',
    about: '',
  );

  @override
  void dispose() {
    _aboutFocusNode.dispose();
    super.dispose();
  }

  //saves the form data
  void _saveContact() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();

    try {
      await Provider.of<UserProvider>(context, listen: false)
          .updateAbout(userValues, user.uid);
    } catch (error) {
      print(error);
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    user = arguments['user'];
    final _loadedUser = arguments['loadedUser'];
    setState(() {
      userValues = _loadedUser;
    });
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit About'),
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
                  Container(
                    height: screenHeight * 0.15,
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
                          TextFormField(
                            cursorColor: Theme.of(context).buttonColor,
                            initialValue: userValues.about,
                            decoration: InputDecoration(
                              labelText: 'About',
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
                            focusNode: _aboutFocusNode,
                            maxLines: 5,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter some information about yourself.';
                              }
                              if (value.length > 200) {
                                return 'Enter less than 200 characters';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              userValues.about = value;
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
                              onPressed: _saveContact,
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
