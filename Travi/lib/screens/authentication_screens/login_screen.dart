/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: Screen for adding logging in
 * using firebase authentication with email. 
 */
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login-screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  var _isLoading = false;

  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext ctx) async {
    // ignore: unused_local_variable
    UserCredential authResult;
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    try {
      authResult = await _auth.signInWithEmailAndPassword(
        email: _authData['email'],
        password: _authData['password'],
      );
      Navigator.of(context).pop();
    } on PlatformException catch (error) {
      var message = 'An error ocurred, please check your credentials!';
      if (error.message != null) {
        message = error.message;
      }
      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print(error);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: screenHeight,
              width: screenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: screenHeight * 0.15,
                  ),
                  Icon(
                    Icons.lightbulb_outline,
                    color: Theme.of(context).buttonColor,
                    size: screenHeight * 0.075,
                  ),
                  SizedBox(
                    height: screenHeight * 0.1,
                  ),
                  Container(
                    width: screenWidth * 0.75,
                    alignment: Alignment.center,
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            TextFormField(
                              cursorColor: Theme.of(context).buttonColor,
                              decoration: InputDecoration(
                                labelText: 'E-Mail',
                                labelStyle: TextStyle(
                                  color: Colors.grey[600],
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).buttonColor,
                                  ),
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              focusNode: _emailFocusNode,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(_passwordFocusNode);
                              },
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value.isEmpty || !value.contains('@')) {
                                  return 'Invalid email!';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _authData['email'] = value;
                              },
                            ),
                            TextFormField(
                              cursorColor: Theme.of(context).buttonColor,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                  color: Colors.grey[600],
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).buttonColor,
                                  ),
                                ),
                              ),
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              focusNode: _passwordFocusNode,
                              controller: _passwordController,
                              validator: (value) {
                                if (value.isEmpty || value.length < 7) {
                                  return 'Password is too short!';
                                }
                                if (!value.contains(new RegExp(r'[A-Z]')) &&
                                    !value.contains(new RegExp(r'[0-9]'))) {
                                  return 'Password must meet all requirements';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _authData['password'] = value;
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            if (_isLoading)
                              CircularProgressIndicator()
                            else
                              Column(
                                children: <Widget>[
                                  Container(
                                    width: screenWidth * 0.75,
                                    child: RaisedButton(
                                      child: Text(
                                        'SIGN IN',
                                        style: TextStyle(
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                      onPressed: () => _submit(context),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 30.0, vertical: 8.0),
                                      color: Theme.of(context).buttonColor,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                    child: Divider(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  //facebook and google signin buttons, not implemented yet
                  // Column(
                  //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //   children: <Widget>[
                  //     Container(
                  //       width: screenWidth * 0.75,
                  //       child: FacebookSignInButton(
                  //         //TODO
                  //         onPressed: () {},
                  //       ),
                  //     ),
                  //     Container(
                  //       width: screenWidth * 0.75,
                  //       child: GoogleSignInButton(
                  //         //TODO
                  //         onPressed: () {},
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
