import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/flight_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/trips_provider.dart';
import '../../providers/user_provider.dart';

class AddOrEditFlightScreen extends StatefulWidget {
  static const routeName = '/add-or-edit-flight-screen';
  @override
  _AddOrEditFlightScreenState createState() => _AddOrEditFlightScreenState();
}

class _AddOrEditFlightScreenState extends State<AddOrEditFlightScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _airlineFocusNode = FocusNode();
  final _flightNumberFocusNode = FocusNode();
  final _departureAirportFocusNode = FocusNode();
  final _departureTerminalFocusNode = FocusNode();
  final _departureGateFocusNode = FocusNode();
  final _arrivalAirportFocusNode = FocusNode();
  final _arrivalTerminalFocusNode = FocusNode();
  final _arrivalGateFocusNode = FocusNode();
  final _confirmationNumberFocusNode = FocusNode();

  TripProvider loadedTrip;
  bool edit = false;
  int editIndex = -1;

  List<DropdownMenuItem<int>> transportationType = [];
  Flight newFlight = Flight(
    airline: null,
    flightNumber: null,
    departureAirport: null,
    departureDateTime: null,
    departureTerminal: null,
    departureGate: null,
    arrivalAirport: null,
    arrivalDateTime: null,
    arrivalTerminal: null,
    arrivalGate: null,
  );

  // ignore: avoid_init_to_null
  TimeOfDay _departureTime = null;
  // ignore: avoid_init_to_null
  TimeOfDay _arrivalTime = null;

  @override
  void dispose() {
    _airlineFocusNode.dispose();
    _flightNumberFocusNode.dispose();
    _departureAirportFocusNode.dispose();
    _departureTerminalFocusNode.dispose();
    _departureGateFocusNode.dispose();
    _arrivalAirportFocusNode.dispose();
    _arrivalTerminalFocusNode.dispose();
    _arrivalGateFocusNode.dispose();
    _confirmationNumberFocusNode.dispose();
    super.dispose();
  }

  //Displays the datepicker for the departure date
  Future<void> _showStartDatePicker() async {
    await showDatePicker(
      context: context,
      helpText: 'Departure Date',
      initialDate: loadedTrip.startDate,
      firstDate: loadedTrip.startDate,
      lastDate: loadedTrip.endDate,
    ).then((selectedDate) {
      if (selectedDate == null) {
        return;
      } else {
        setState(() {
          newFlight.departureDateTime = selectedDate;
        });
        _showCheckinTimePicker();
      }
    });
  }

  //Displays the datepicker for the arrival date
  Future<void> _showEndDatePicker() async {
    if (loadedTrip.startDate == null || newFlight.departureDateTime == null) {
      await _showStartDatePicker();
    }
    showDatePicker(
      context: context,
      helpText: 'Arrival Date',
      initialDate: newFlight.departureDateTime,
      firstDate: newFlight.departureDateTime,
      lastDate: loadedTrip.endDate,
    ).then((selectedDate) {
      if (selectedDate == null) {
        return;
      } else {
        setState(() {
          newFlight.arrivalDateTime = selectedDate;
        });
        _showCheckoutTimePicker();
      }
    });
  }

  //Displays the time picker for the checkin time
  Future<void> _showCheckinTimePicker() async {
    showTimePicker(
      context: context,
      helpText: 'Departure Time',
      initialTime: TimeOfDay(hour: 00, minute: 00),
    ).then((selectedTime) {
      if (selectedTime == null) {
        return;
      } else {
        setState(() {
          _departureTime = selectedTime;
        });
        setDateTime(true, newFlight.departureDateTime, _departureTime);
      }
    });
  }

  //Displays the time picker for the checkout time
  Future<void> _showCheckoutTimePicker() async {
    showTimePicker(
      context: context,
      helpText: 'Arrival Time',
      initialTime: TimeOfDay(hour: 00, minute: 00),
    ).then((selectedTime) {
      if (selectedTime == null) {
        return;
      } else {
        setState(() {
          _arrivalTime = selectedTime;
        });
        setDateTime(false, newFlight.arrivalDateTime, _arrivalTime);
      }
    });
  }

  //Adds selected Time to date
  void setDateTime(bool endDate, DateTime date, TimeOfDay time) {
    DateTime newDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (endDate == true) {
      setState(() {
        newFlight.departureDateTime = newDateTime;
      });
    } else if (endDate == false) {
      setState(() {
        newFlight.arrivalDateTime = newDateTime;
      });
    }
  }

  //Saves transporation
  void _addOrEditTransportation() async {
    if (!_formKey.currentState.validate()) {
      return;
    } else {
      _formKey.currentState.save();
      try {
        String userId = await Provider.of<UserProvider>(context, listen: false)
            .getCurrentUserId();
        await Provider.of<TripsProvider>(context, listen: false)
            .addOrEditFlight(
                loadedTrip, userId, newFlight, edit ? editIndex : -1);
      } catch (error) {
        print(error);
        return;
      }
    }
    Navigator.of(context).pop();
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
        newFlight = loadedTrip.flights[editIndex];
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: edit
            ? const Text('Edit Flight')
            : const Text(
                'Add Flight',
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
                      child: const Text(
                        'Enter the flight details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                              labelText: 'Airline',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                            initialValue: newFlight.airline,
                            textInputAction: TextInputAction.next,
                            focusNode: _airlineFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_flightNumberFocusNode);
                            },
                            validator: (value) {
                              if(value.isEmpty){
                                return 'Enter an airline';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              newFlight.airline = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                              labelText: 'Flight Number',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                            initialValue: newFlight.flightNumber,
                            textInputAction: TextInputAction.next,
                            focusNode: _flightNumberFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_confirmationNumberFocusNode);
                            },
                            validator: (value) {
                              if(value.isEmpty){
                                return 'Enter a flight number';
                              } else if(value.length != 4){
                                return 'Flight numbers must be 4 digits long';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              newFlight.flightNumber = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                              labelText: 'Confirmation Number (Optional)',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            focusNode: _confirmationNumberFocusNode,
                            initialValue: newFlight.confirmationNumber,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_departureAirportFocusNode);
                            },
                            onSaved: (value) {
                              newFlight.confirmationNumber = value;
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                              top: 18,
                            ),
                            height: screenHeight * 0.06,
                            child: const Text(
                              'Departure Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                              labelText: 'Departure Airport',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                            textInputAction: TextInputAction.done,
                            focusNode: _departureAirportFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_departureTerminalFocusNode);
                            },
                            validator: (value) {
                              if(value.isEmpty){
                                return 'Enter a departure airport';
                              }
                              return null;
                            },
                            initialValue: newFlight.departureAirport,
                            onSaved: (value) {
                              newFlight.departureAirport = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                              labelText: 'Departure Terminal (Optional)',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                            initialValue: newFlight.departureTerminal,
                            textInputAction: TextInputAction.next,
                            focusNode: _departureTerminalFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_departureGateFocusNode);
                            },
                            onSaved: (value) {
                              newFlight.departureTerminal = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                              labelText: 'Departure Gate (Optional)',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                            initialValue: newFlight.departureGate,
                            textInputAction: TextInputAction.done,
                            focusNode: _departureGateFocusNode,
                            onSaved: (value) {
                              newFlight.departureGate = value;
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                              top: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: screenWidth * 0.25,
                                  child: Text(
                                    'Departure Date and Time:',
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
                                  child: newFlight.departureDateTime == null
                                      ? const Text('')
                                      : Text(
                                          '${DateFormat.yMd().add_jm().format(newFlight.departureDateTime)}',
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
                            padding: const EdgeInsets.only(
                              top: 18,
                            ),
                            height: screenHeight * 0.06,
                            child: const Text(
                              'Arrival Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                              labelText: 'Arrival Airport',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            focusNode: _arrivalAirportFocusNode,
                            initialValue: newFlight.arrivalAirport,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_arrivalTerminalFocusNode);
                            },
                            validator: (value) {
                              if(value.isEmpty){
                                return 'Enter an arrival airport';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              newFlight.arrivalAirport = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                              labelText: 'Arrival Terminal (Optional)',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                            initialValue: newFlight.arrivalTerminal,
                            textInputAction: TextInputAction.next,
                            focusNode: _arrivalTerminalFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_arrivalGateFocusNode);
                            },
                            onSaved: (value) {
                              newFlight.arrivalTerminal = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                              labelText: 'Arrival Gate (Optional)',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                            initialValue: newFlight.arrivalGate,
                            textInputAction: TextInputAction.done,
                            focusNode: _arrivalGateFocusNode,
                            onSaved: (value) {
                              newFlight.arrivalGate = value;
                            },
                          ),
                          //Container for End Date
                          Container(
                            padding: const EdgeInsets.only(
                              top: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: screenWidth * 0.25,
                                  child: Text(
                                    'Arrival Date and Time:',
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
                                  child: newFlight.arrivalDateTime == null
                                      ? const Text('')
                                      : Text(
                                          '${DateFormat.yMd().add_jm().format(newFlight.arrivalDateTime)}',
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
                            padding: const EdgeInsets.only(top: 20),
                            width: screenWidth,
                            child: FlatButton(
                              child: Text(
                                'Submit',
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                              onPressed: () => _addOrEditTransportation(),
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
