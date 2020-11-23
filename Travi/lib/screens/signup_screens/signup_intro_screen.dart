import 'package:flutter/material.dart';

import './signup_name_screen.dart';

class SignUpIntroScreen extends StatelessWidget {
  static const routeName = '/signup-intro-screen';

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign Up',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
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
            decoration: BoxDecoration(
                // color: Theme.of(context).accentColor,
                ),
            child: Container(
              width: screenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: screenHeight * 0.15,
                  ),
                  Container(
                    width: screenWidth * 0.6,
                    //TODO image placeholder
                    child: Image.network(
                      'https://cdn.pixabay.com/photo/2013/07/13/12/18/airbus-159588_1280.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.035,
                  ),
                  Text(
                    'Join Travi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.045,
                  ),
                  Container(
                    width: screenWidth * 0.8,
                    child: Text(
                      'Welcome! Let\'s start planning and organizing your next adventure. First, create a new account in just a few easy steps.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.045,
                  ),
                  Container(
                    width: screenWidth * 0.8,
                    child: FlatButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed(SignUpNameScreen.routeName),
                      color: Theme.of(context).buttonColor,
                      child: Text(
                        'Next',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(
              bottom: 10,
            ),
            child: new InkWell(
              child: Text(
                'Already have an account?',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              //TODO NAVIGATE TO LOGIN PAGE
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
