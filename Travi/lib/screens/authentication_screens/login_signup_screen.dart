import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

import '../signup_screens/signup_intro_screen.dart';
import './login_screen.dart';

class LoginSignupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).buttonColor,
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
                    height: screenHeight * 0.35,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.lightbulb_outline,
                        color: Theme.of(context).accentColor,
                        size: screenHeight * 0.05,
                      ),
                      Text(
                        'Travi',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.22,
                  ),
                  FlatButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(SignUpIntroScreen.routeName),
                    child: Container(
                      alignment: Alignment.center,
                      height: screenHeight * 0.06,
                      width: screenWidth * 0.7,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2.5,
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            8.0,
                          ),
                        ),
                      ),
                      child: Text(
                        'SIGN UP',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.025,
                  ),
                  FlatButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(LoginScreen.routeName),
                    child: Container(
                      alignment: Alignment.center,
                      height: screenHeight * 0.06,
                      width: screenWidth * 0.7,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.white,
                          width: 2.5,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            8.0,
                          ),
                        ),
                      ),
                      child: Text(
                        'SIGN IN',
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).buttonColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.025,
                  ),
                  Container(
                    width: screenWidth * 0.7,
                    child: FacebookSignInButton(
                      //TODO
                      onPressed: () {},
                    ),
                  ),      
                  Container(
                    width: screenWidth * 0.7,
                    child: GoogleSignInButton(
                      //TODO
                      onPressed: () {},
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
