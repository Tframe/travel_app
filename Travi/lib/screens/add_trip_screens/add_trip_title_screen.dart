import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../providers/trip_provider.dart';
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
  final _lastDate = DateTime.now().add(Duration(days: 365));

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

  //TODO PUT DATEPICKER IN HELPER

  //Function to show start date picker
  Future<void> _showStartDatePicker() async {
    await showDatePicker(
            context: context,
            helpText: 'Start Date',
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: _lastDate)
        .then((selectedDate) {
      if (selectedDate == null) {
        return;
      } else {
        setState(() {
          tripValues.startDate = selectedDate;
        });
      }
    });
  }

  //Function to show end date picker
  Future<void> _showEndDatePicker() async {
    if (tripValues.startDate == null) {
      await _showStartDatePicker();
    }
    showDatePicker(
            context: context,
            helpText: 'End Date',
            initialDate: tripValues.startDate,
            firstDate: tripValues.startDate,
            lastDate: _lastDate)
        .then((selectedDate) {
      if (selectedDate == null) {
        return;
      } else {
        setState(() {
          tripValues.endDate = selectedDate;
        });
      }
    });
  }

  //saves form data
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: screenHeight * 0.055,
                      ),
                      Text(
                        'Title',
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
                          return null;
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
                        'Description',
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
                          return null;
                        },
                        onSaved: (value) {
                          tripValues.description = value;
                        },
                      ),
                      SizedBox(
                        height: screenHeight * 0.055,
                      ),
                      Text(
                        'Dates',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          top: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Start Date:',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: IconButton(
                                icon: Icon(Icons.calendar_today),
                                color: Theme.of(context).primaryColor,
                                onPressed: _showStartDatePicker,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 20),
                              width: 100,
                              child: tripValues.startDate == null
                                  ? Text('')
                                  : Text(
                                      '${DateFormat.yMd().format(tripValues.startDate)}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                            ),
                          ],
                        ),
                      ),
                      //Container for End Date
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'End Date:',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(left: 5),
                              child: IconButton(
                                icon: Icon(Icons.calendar_today),
                                color: Theme.of(context).primaryColor,
                                onPressed: _showEndDatePicker,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 20),
                              width: 100,
                              child: tripValues.endDate == null
                                  ? Text('')
                                  : Text(
                                      '${DateFormat.yMd().format(tripValues.endDate)}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                            ),
                          ],
                        ),
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
