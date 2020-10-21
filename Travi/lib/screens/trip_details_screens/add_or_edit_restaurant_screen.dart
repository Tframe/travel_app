import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/trip_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/trips_provider.dart';
import '../../providers/user_provider.dart';

class AddOrEditRestaurantScreen extends StatefulWidget {
  static const routeName = '/add-or-edit-restaurant-screen';
  @override
  _AddOrEditRestaurantScreenState createState() => _AddOrEditRestaurantScreenState();
}

class _AddOrEditRestaurantScreenState extends State<AddOrEditRestaurantScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _nameFocusNode = FocusNode();
  final _phoneNumberFocusNode = FocusNode();
  final _websiteFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _reservationIdFocusNode = FocusNode();

  TripProvider loadedTrip;
  bool edit = false;
  int editIndex = -1;

  Restaurant newRestaurant = Restaurant(
    id: null,
    name: null,
    address: null,
    startingDateTime: null,
    reservationID: null,
  );

  // ignore: avoid_init_to_null
  TimeOfDay _checkInTime = null;

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    _websiteFocusNode.dispose();
    _addressFocusNode.dispose();
    _reservationIdFocusNode.dispose();
    super.dispose();
  }

  //adds lodging information
  void _addOrEditRestaurant() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();

    try {
      String userId = await Provider.of<UserProvider>(context, listen: false)
          .getCurrentUserId();
      await Provider.of<TripsProvider>(context, listen: false)
          .addOrEditRestaurant(loadedTrip, userId, newRestaurant, edit ? editIndex : -1);
    } catch (error) {
      print(error);
      return;
    }
    Navigator.of(context).pop();
  }

  //Displays the datepicker for the checkin date
  Future<void> _showStartDatePicker() async {
    await showDatePicker(
      context: context,
      helpText: 'Checkin Date',
      initialDate: edit ? newRestaurant.startingDateTime : loadedTrip.startDate,
      firstDate: DateTime.now(),
      lastDate: loadedTrip.endDate.subtract(
        Duration(
          days: 1,
        ),
      ),
    ).then((selectedDate) {
      if (selectedDate == null) {
        return;
      } else {
        setState(() {
          newRestaurant.startingDateTime = selectedDate;
        });
        _showCheckinTimePicker();
      }
    });
  }

  //Displays the time picker for the checkin time
  Future<void> _showCheckinTimePicker() async {
    showTimePicker(
      context: context,
      helpText: 'Reservation Time',
      initialTime: TimeOfDay(hour: 00, minute: 00),
    ).then((selectedTime) {
      if (selectedTime == null) {
        return;
      } else {
        setState(() {
          _checkInTime = selectedTime;
        });
        setDateTime(true, newRestaurant.startingDateTime, _checkInTime);
      }
    });
  }

  //Adds selected Time to date
  void setDateTime(bool checkIn, DateTime date, TimeOfDay time) {
    DateTime newDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (checkIn == true) {
      setState(() {
        newRestaurant.startingDateTime = newDateTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    loadedTrip = arguments['loadedTrip'];
    editIndex = arguments['editIndex'];
    if (editIndex > -1) {
      setState(() {
        edit = true;
        newRestaurant = loadedTrip.restaurants[editIndex];
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: edit ? const Text(
          'Edit Restaurant',
        ) : const Text(
          'Add Restaurant',
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
                    height: screenHeight * 0.075,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Text(
                        'Enter the restaurant details',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),
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
                              labelText: 'Name',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                            initialValue: newRestaurant.name,
                            textInputAction: TextInputAction.next,
                            focusNode: _nameFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_phoneNumberFocusNode);
                            },
                            onSaved: (value) {
                              newRestaurant.name = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                              labelText: 'Phone # (Optional)',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                            initialValue: newRestaurant.phoneNumber,
                            textInputAction: TextInputAction.next,
                            focusNode: _phoneNumberFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_websiteFocusNode);
                            },
                            onSaved: (value) {
                              newRestaurant.phoneNumber = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                              labelText: 'Website (Optional)',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                            initialValue: newRestaurant.website,
                            textInputAction: TextInputAction.next,
                            focusNode: _websiteFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_addressFocusNode);
                            },
                            onSaved: (value) {
                              newRestaurant.website = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                              labelText: 'Address',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                            initialValue: newRestaurant.address,
                            textInputAction: TextInputAction.next,
                            focusNode: _addressFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_reservationIdFocusNode);
                            },
                            onSaved: (value) {
                              newRestaurant.address = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                              labelText: 'Reservation ID',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                            initialValue: newRestaurant.reservationID,
                            textInputAction: TextInputAction.done,
                            focusNode: _reservationIdFocusNode,
                            onSaved: (value) {
                              newRestaurant.reservationID = value;
                            },
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: screenWidth * 0.25,
                                  child: Text(
                                    'Reservation Date and Time:',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  child: IconButton(
                                    icon: Icon(Icons.calendar_today),
                                    color: Colors.green,
                                    onPressed: _showStartDatePicker,
                                  ),
                                ),
                                Container(
                                  width: screenWidth * 0.4,
                                  child: newRestaurant.startingDateTime == null
                                      ? Text('')
                                      : Text(
                                          '${DateFormat.yMd().add_jm().format(newRestaurant.startingDateTime)}',
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
                            padding: const EdgeInsets.only(top: 40),
                            width: screenWidth,
                            child: FlatButton(
                              child: Text(
                                'Submit',
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                              onPressed: () => _addOrEditRestaurant(),
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