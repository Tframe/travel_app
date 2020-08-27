import 'package:flutter/material.dart';

import '../../providers/user_provider.dart';
import '../../providers/destination_provider.dart';

class SignUpPasswordScreen extends StatefulWidget {
  static const routeName = '/signup-password-screen';
  @override
  _SignUpPasswordScreen createState() => _SignUpPasswordScreen();
}

class _SignUpPasswordScreen extends State<SignUpPasswordScreen> {
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  var _isLoading = false;
  var userValues = User(
    id: null,
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    location: [
      Destination(
        id: null,
        country: '',
        city: '',
        state: '',
      ),
    ],
  );

  void _saveEmail() {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    // Navigator.of(context)
    //     .pushNamed(SignUpEmailScreen.routeName, arguments: userValues);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    userValues = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Password',
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
                    'Choose a password',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.025,
                  ),
                  Container(
                    width: screenWidth * 0.8,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Password Criteria',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '* Must be between 6-32 characters in length.',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '* Include at least 1 Uppercase letter.',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '* Include at least 1 number.',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.025,
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
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                            focusNode: _passwordFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_confirmPasswordFocusNode);
                            },
                            controller: _passwordController,
                            validator: (value) {
                              if (value.isEmpty || value.length < 7) {
                                return 'Password is too short!';
                              }
                              if (!value.contains(new RegExp(r'[A-Z]')) &&
                                  !value.contains(new RegExp(r'[0-9]'))) {
                                return 'Password must meet all requirements';
                              }
                            },
                            onSaved: (value) {
                              userValues.password = value;
                            },
                          ),
                          TextFormField(
                              cursorColor: Theme.of(context).primaryColor,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .secondaryHeaderColor),
                                ),
                              ),
                              obscureText: true,
                              focusNode: _confirmPasswordFocusNode,
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match!';
                                }
                              }),
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
                              onPressed: _saveEmail,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30.0, vertical: 8.0),
                              color: Theme.of(context).primaryColor,
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
