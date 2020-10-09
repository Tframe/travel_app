import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/trip_provider.dart';
import '../../providers/lodging_provider.dart';
import '../../providers/trips_provider.dart';
import '../../providers/user_provider.dart';

class AddOrEditLodgingScreen extends StatefulWidget {
  static const routeName = '/add-lodging-screen';
  @override
  _AddOrEditLodgingScreenState createState() => _AddOrEditLodgingScreenState();
}

class _AddOrEditLodgingScreenState extends State<AddOrEditLodgingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _nameFocusNode = FocusNode();

  final _addressFocusNode = FocusNode();
  final _reservationIdFocusNode = FocusNode();

  TripProvider loadedTrip;
  bool edit = false;
  int editIndex = -1;

  Lodging tempLodging = Lodging(
    id: null,
    name: null,
    address: null,
    checkInDateTime: null,
    checkOutDateTime: null,
    reservationID: null,
  );

  // ignore: avoid_init_to_null
  TimeOfDay _checkInTime = null;
  // ignore: avoid_init_to_null
  TimeOfDay _checkOutTime = null;

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _addressFocusNode.dispose();
    _reservationIdFocusNode.dispose();
    super.dispose();
  }

  //adds lodging information
  void _addOrEditLodging() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();

    try {
      String userId = await Provider.of<UserProvider>(context, listen: false)
          .getCurrentUserId();
      await Provider.of<TripsProvider>(context, listen: false)
          .addOrEditLodging(loadedTrip, userId, tempLodging, edit ? editIndex : -1);
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
      initialDate: edit ? tempLodging.checkInDateTime : loadedTrip.startDate,
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
          tempLodging.checkInDateTime = selectedDate;
        });
        _showCheckinTimePicker();
      }
    });
  }

  //Displays the datepicker for the checkout date
  Future<void> _showEndDatePicker() async {
    if (loadedTrip.startDate == null) {
      await _showStartDatePicker();
    }
    showDatePicker(
      context: context,
      helpText: 'Checkout Date',
      initialDate: edit ? tempLodging.checkOutDateTime : tempLodging.checkInDateTime,
      firstDate: DateTime.now(),
      lastDate: loadedTrip.endDate,
    ).then((selectedDate) {
      if (selectedDate == null) {
        return;
      } else {
        setState(() {
          tempLodging.checkOutDateTime = selectedDate;
        });
        _showCheckoutTimePicker();
      }
    });
  }

  //Displays the time picker for the checkin time
  Future<void> _showCheckinTimePicker() async {
    showTimePicker(
      context: context,
      helpText: 'Checkin Time',
      initialTime: TimeOfDay(hour: 00, minute: 00),
    ).then((selectedTime) {
      if (selectedTime == null) {
        return;
      } else {
        setState(() {
          _checkInTime = selectedTime;
        });
        setDateTime(true, tempLodging.checkInDateTime, _checkInTime);
      }
    });
  }

  //Displays the time picker for the checkout time
  Future<void> _showCheckoutTimePicker() async {
    showTimePicker(
      context: context,
      helpText: 'Checkout Time',
      initialTime: _checkInTime,
    ).then((selectedTime) {
      if (selectedTime == null) {
        return;
      } else {
        setState(() {
          _checkOutTime = selectedTime;
        });
        setDateTime(false, tempLodging.checkOutDateTime, _checkOutTime);
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
        tempLodging.checkInDateTime = newDateTime;
      });
    } else if (checkIn == false) {
      setState(() {
        tempLodging.checkOutDateTime = newDateTime;
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
        tempLodging = loadedTrip.lodgings[editIndex];
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: edit ? const Text(
          'Edit Lodging',
        ) : const Text(
          'Add Lodging',
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
                        'Enter the lodging details',
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
                            initialValue: tempLodging.name,
                            textInputAction: TextInputAction.next,
                            focusNode: _nameFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_addressFocusNode);
                            },
                            onSaved: (value) {
                              tempLodging.name = value;
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
                            initialValue: tempLodging.address,
                            textInputAction: TextInputAction.next,
                            focusNode: _addressFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_reservationIdFocusNode);
                            },
                            onSaved: (value) {
                              tempLodging.address = value;
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
                            initialValue: tempLodging.reservationID,
                            textInputAction: TextInputAction.done,
                            focusNode: _reservationIdFocusNode,
                            onSaved: (value) {
                              tempLodging.reservationID = value;
                            },
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: screenWidth * 0.25,
                                  child: Text(
                                    'Checkin Date and Time:',
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
                                  child: tempLodging.checkInDateTime == null
                                      ? Text('')
                                      : Text(
                                          '${DateFormat.yMd().add_jm().format(tempLodging.checkInDateTime)}',
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
                                Container(
                                  width: screenWidth * 0.25,
                                  child: Text(
                                    'Checkout Date and Time:',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(left: 5),
                                  child: IconButton(
                                    icon: Icon(Icons.calendar_today),
                                    color: Colors.green,
                                    onPressed: _showEndDatePicker,
                                  ),
                                ),
                                Container(
                                  width: screenWidth * 0.4,
                                  child: tempLodging.checkOutDateTime == null
                                      ? Text('')
                                      : Text(
                                          '${DateFormat.yMd().add_jm().format(tempLodging.checkOutDateTime)}',
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
                              onPressed: () => _addOrEditLodging(),
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
