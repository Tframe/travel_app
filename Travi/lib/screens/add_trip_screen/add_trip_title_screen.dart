import 'package:flutter/material.dart';

import '../../providers/trip_provider.dart';
import '../../providers/country_provider.dart';
import 'add_trip_countries_screen.dart';

class AddTripTitleScreen extends StatefulWidget {
  static const routeName = '/add-trip-title-screen';

  @override
  _AddTripTitleScreenState createState() => _AddTripTitleScreenState();
}

class _AddTripTitleScreenState extends State<AddTripTitleScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  var tripValues = TripProvider(
    id: null,
    title: null,
    startDate: null,
    endDate: null,
    countries: null,
    description: null,
  );

  @override
  void dispose() {
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _saveName() {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    //TODO FIX THIS ROUTE

    Navigator.of(context)
        .pushNamed(AddTripCountriesScreen.routeName, arguments: tripValues);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Trip',
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
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 25,
                ),
                width: screenWidth * 0.85,
                alignment: Alignment.center,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: screenHeight * 0.055,
                      ),
                      Text(
                        'What should we call this next adventure?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      TextFormField(
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                          labelText: 'Trip Title',
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).secondaryHeaderColor),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        focusNode: _titleFocusNode,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a title!';
                          }
                        },
                        onSaved: (value) {
                          tripValues.title = value;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                      ),
                      SizedBox(
                        height: screenHeight * 0.055,
                      ),
                      Text(
                        'Give a quick description about this trip...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      TextFormField(
                        cursorColor: Theme.of(context).primaryColor,
                        maxLines: 7,
                        minLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Trip Description',
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).secondaryHeaderColor),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        focusNode: _descriptionFocusNode,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a description!';
                          }
                        },
                        onSaved: (value) {
                          tripValues.description = value;
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
                          onPressed: _saveName,
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
            ),
          ),
        ],
      ),
    );
  }
}