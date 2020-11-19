import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/user_provider.dart';

class EditContactInfoScreen extends StatefulWidget {
  static const routeName = '/edit-contact-info-screen';
  @override
  _EditContactInfoScreenState createState() => _EditContactInfoScreenState();
}

class _EditContactInfoScreenState extends State<EditContactInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _phoneFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();

  User user;
  var userValues = UserProvider(
    id: null,
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    location: '',
  );

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _saveContact() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();

    try {
      await Provider.of<UserProvider>(context, listen: false)
          .updateUserContact(userValues, user.uid);
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
        title: Text('Edit Contact Information'),
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
                            initialValue: userValues.phone,
                            decoration: InputDecoration(
                              labelText: 'Mobile #',
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
                            focusNode: _phoneFocusNode,
                            keyboardType: TextInputType.phone,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_emailFocusNode);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter a mobile #!';
                              }
                              if (value.length != 10) {
                                return 'Invalid mobile #';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              userValues.phone = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).buttonColor,
                            initialValue: userValues.email,
                            decoration: InputDecoration(
                              labelText: 'Email',
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
                            keyboardType: TextInputType.emailAddress,
                            focusNode: _emailFocusNode,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your Last name!';
                              }
                              if (!value.contains('@')) {
                                return 'Invalid email';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              userValues.email = value;
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
                              padding: const EdgeInsets.symmetric(
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
