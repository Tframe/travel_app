import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/http_exception.dart';
import '../../providers/auth.dart';
import '../../providers/country_provider.dart';
import '../../providers/user_provider.dart';

const kGoogleApiKey = "AIzaSyDCPPoOx6ihjBCfPF5nWPsUJ3OWO83u-QM";

final homeScaffoldKey = GlobalKey<ScaffoldState>();
final searchScaffoldKey = GlobalKey<ScaffoldState>();

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup-screen';

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  // Mode _mode = Mode.overlay;

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

  var _isLoading = false;
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occured'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Auth>(context, listen: false).signup(
        userValues.email,
        userValues.password,
        userValues.location,
        userValues.firstName,
        userValues.lastName,
        userValues.phone,
      );
      Navigator.of(context).pop();
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address.';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak';
      } else if (error.toString().contains('EMAIL_NOT_FOUND') ||
          error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid email address or password.';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage = 'Could not authenticate. Please try again later.';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  // void onError(PlacesAutocompleteResponse response) {
  //   homeScaffoldKey.currentState.showSnackBar(
  //     SnackBar(content: Text(response.errorMessage)),
  //   );
  // }

  // Object _parseDestination(String destination) {
  //   var parsedDestination = destination.split(', ');
  //   var lengthParsedDestination = parsedDestination.length;
  //   var parsedCountry = parsedDestination[lengthParsedDestination - 1];
  //   var parsedState = '';
  //   var parsedCity = '';
  //   if (lengthParsedDestination == 2) {
  //     parsedCity = parsedDestination[0];
  //   } else if (lengthParsedDestination > 2) {
  //     parsedCity = parsedDestination[lengthParsedDestination - 3];
  //     parsedState = parsedDestination[lengthParsedDestination - 2];
  //   }
  //   return [
  //     Destination(
  //       id: null,
  //       country: parsedCountry,
  //       state: parsedState,
  //       city: parsedCity,
  //     )
  //   ];
  // }

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
            child: SingleChildScrollView(
              //TODO look into wrapping container with SizeTransition
              child: Container(
                height: screenHeight * 1.25,
                width: screenWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: screenHeight * 0.10,
                    ),
                    Icon(
                      Icons.lightbulb_outline,
                      color: Theme.of(context).primaryColor,
                      size: screenHeight * 0.075,
                    ),
                    SizedBox(
                      height: screenHeight * 0.015,
                    ),
                    Container(
                      width: screenWidth * 0.75,
                      alignment: Alignment.center,
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              TextFormField(
                                cursorColor: Theme.of(context).primaryColor,
                                decoration: InputDecoration(
                                  labelText: 'First Name',
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor),
                                  ),
                                ),
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(_lastNameFocusNode);
                                },
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter your first name!';
                                  }
                                },
                                onSaved: (value) {
                                  userValues.firstName = value;
                                },
                              ),
                              TextFormField(
                                cursorColor: Theme.of(context).primaryColor,
                                decoration: InputDecoration(
                                  labelText: 'Last Name',
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor),
                                  ),
                                ),
                                textInputAction: TextInputAction.done,
                                focusNode: _lastNameFocusNode,
                                // onFieldSubmitted: (_) {
                                //   FocusScope.of(context)
                                //       .requestFocus(_emailFocusNode);
                                // },
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter your Last name!';
                                  }
                                },
                                onSaved: (value) {
                                  userValues.lastName = value;
                                },
                              ),
                              // PlacesAutocompleteFormField(
                              //   apiKey: kGoogleApiKey,
                              //   onError: onError,
                              //   mode: _mode,
                              //   language: "en",
                              //   inputDecoration: InputDecoration(
                              //     labelText: 'Location',
                              //     labelStyle: TextStyle(
                              //       fontSize: 20,
                              //     ),
                              //   ),
                              //   validator: (value) {
                              //     if (value.isEmpty) {
                              //       return 'Please provide your location';
                              //     } else {
                              //       return null;
                              //     }
                              //   },
                              //   onSaved: (value) async {
                              //     userValues.location =
                              //         _parseDestination(value);
                              //   },
                              // ),
                              TextFormField(
                                cursorColor: Theme.of(context).primaryColor,
                                decoration: InputDecoration(
                                  labelText: 'E-Mail',
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor),
                                  ),
                                ),
                                textInputAction: TextInputAction.next,
                                focusNode: _emailFocusNode,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(_phoneFocusNode);
                                },
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value.isEmpty || !value.contains('@')) {
                                    return 'Invalid email!';
                                  }
                                },
                                onSaved: (value) {
                                  userValues.email = value;
                                },
                              ),
                              TextFormField(
                                cursorColor: Theme.of(context).primaryColor,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor),
                                  ),
                                ),
                                textInputAction: TextInputAction.next,
                                focusNode: _phoneFocusNode,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(_passwordFocusNode);
                                },
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Invalid phone number!';
                                  }
                                },
                                onSaved: (value) {
                                  userValues.phone = value;
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    width: screenWidth * .62,
                                    child: TextFormField(
                                      cursorColor:
                                          Theme.of(context).primaryColor,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor),
                                        ),
                                      ),
                                      obscureText: true,
                                      textInputAction: TextInputAction.next,
                                      focusNode: _passwordFocusNode,
                                      onFieldSubmitted: (_) {
                                        FocusScope.of(context).requestFocus(
                                            _confirmPasswordFocusNode);
                                      },
                                      controller: _passwordController,
                                      validator: (value) {
                                        if (value.isEmpty || value.length < 7) {
                                          return 'Password is too short!';
                                        }
                                        if (!value.contains(
                                                new RegExp(r'[A-Z]')) &&
                                            !value.contains(
                                                new RegExp(r'[0-9]'))) {
                                          return 'Password must meet all requirements';
                                        }
                                      },
                                      onSaved: (value) {
                                        userValues.password = value;
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.lightbulb_outline,
                                    ),
                                    onPressed: null,
                                  ),
                                ],
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                width: screenWidth * 0.62,
                                child: TextFormField(
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
                                  },
                                ),
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
                                          'SIGN UP',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).accentColor,
                                          ),
                                        ),
                                        onPressed: _submit,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 30.0, vertical: 8.0),
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
