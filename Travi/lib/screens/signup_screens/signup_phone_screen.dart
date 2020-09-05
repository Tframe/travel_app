import 'package:flutter/material.dart';

import '../../providers/user_provider.dart';
import '../../providers/country_provider.dart';
import './signup_email_screen.dart';

class SignUpPhoneScreen extends StatefulWidget {
  static const routeName = '/signup-phone-screen';
  @override
  _SignUpPhoneScreenState createState() => _SignUpPhoneScreenState();
}

class _SignUpPhoneScreenState extends State<SignUpPhoneScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var _isLoading = false;
  var userValues = UserProvider(
    id: null,
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    location: [
      Country(
        id: null,
        country: null,
        latitude: null,
        longitude: null,
      ),
    ],
  );

  void _savePhone() {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    Navigator.of(context)
        .pushNamed(SignUpEmailScreen.routeName, arguments: userValues);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    userValues = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mobile Number',
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
                    'Add your mobile number',
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
                    child: Text(
                      'Adding your mobile number will help with authentication.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                      ),
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
                              labelText: 'Mobile number',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value.isEmpty || value.length != 10) {
                                return 'Please enter a valid mobile number!';
                              }
                            },
                            onSaved: (value) {
                              userValues.phone = value.trim();
                            },
                          ),
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
                              onPressed: _savePhone,
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
