import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/flight_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/trips_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/notification_provider.dart';
import './widgets/group_avatars.dart';

class AddOrEditFlightScreen extends StatefulWidget {
  static const routeName = '/add-or-edit-flight-screen';
  @override
  _AddOrEditFlightScreenState createState() => _AddOrEditFlightScreenState();
}

class _AddOrEditFlightScreenState extends State<AddOrEditFlightScreen> {
  double screenHeight;
  double screenWidth;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _airlineFocusNode = FocusNode();
  final _airlinePhoneNumberFocusNode = FocusNode();
  final _airlineWebsiteFocusNode = FocusNode();
  final _flightNumberFocusNode = FocusNode();
  final _departureAirportFocusNode = FocusNode();
  final _departureTerminalFocusNode = FocusNode();
  final _departureGateFocusNode = FocusNode();
  final _arrivalAirportFocusNode = FocusNode();
  final _arrivalTerminalFocusNode = FocusNode();
  final _arrivalGateFocusNode = FocusNode();
  final _confirmationNumberFocusNode = FocusNode();
  bool _suggestion = false;

  TripProvider loadedTrip;
  bool edit = false;
  int editIndex = -1;
  int countryIndex = 0;

  List<DropdownMenuItem<int>> transportationType = [];
  Flight newFlight = Flight(
    chosen: false,
    organizerId: null,
    airline: null,
    flightNumber: null,
    airlinePhoneNumber: null,
    airlineWebsite: null,
    departureAirport: null,
    departureDateTime: null,
    departureTerminal: null,
    departureGate: null,
    arrivalAirport: null,
    arrivalDateTime: null,
    arrivalTerminal: null,
    arrivalGate: null,
    participants: [],
  );

  // ignore: avoid_init_to_null
  TimeOfDay _departureTime = null;
  // ignore: avoid_init_to_null
  TimeOfDay _arrivalTime = null;

  @override
  void dispose() {
    _airlineFocusNode.dispose();
    _flightNumberFocusNode.dispose();
    _airlinePhoneNumberFocusNode.dispose();
    _airlineWebsiteFocusNode.dispose();
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
            initialDate: loadedTrip.startDate.isBefore(DateTime.now())
                ? DateTime.now()
                : loadedTrip.startDate,
            firstDate: loadedTrip.startDate.isBefore(DateTime.now())
                ? DateTime.now()
                : loadedTrip.startDate,
            lastDate: loadedTrip.endDate)
        .then((selectedDate) {
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
  void _addOrEditFlight() async {
    if (!_formKey.currentState.validate()) {
      return;
    } else {
      _formKey.currentState.save();
      try {
        String userId = await Provider.of<UserProvider>(context, listen: false)
            .getCurrentUserId();
        UserProvider loggedInUser =
            Provider.of<UserProvider>(context, listen: false).loggedInUser;

        newFlight.organizerId = userId;
        newFlight.participants =
            Provider.of<UserProvider>(context, listen: false).getParticipants;
        newFlight.chosen = !_suggestion;

        //get current list of trips to update
        List<TripProvider> trips =
            Provider.of<TripsProvider>(context, listen: false).trips;
        var tripIndex = trips.indexWhere((trip) => trip.id == loadedTrip.id);

        if (edit) {
          await Provider.of<Flight>(context, listen: false).editFlight(
            loadedTrip.id,
            loadedTrip.organizerId,
            loadedTrip.countries[countryIndex].id,
            newFlight,
            newFlight.id,
          );
          //update flight to trip data
          List<Flight> flights =
              Provider.of<Flight>(context, listen: false).flights;
          trips[tripIndex].countries[countryIndex].flights = flights;
        } else {
          await Provider.of<Flight>(context, listen: false).addFlight(
            loadedTrip.id,
            loadedTrip.organizerId,
            loadedTrip.countries[countryIndex].id,
            newFlight,
          );
          //add flight to trip data
          trips[tripIndex].countries[countryIndex].flights.add(newFlight);
        }
        Provider.of<TripsProvider>(context, listen: false).setTripsList(trips);
        //create notification to be sent to other companions
        for (int i = 0; i < loadedTrip.group.length; i++) {
          //if not the user that is logged in, send notification
          if (loggedInUser.id != loadedTrip.group[i].id) {
            NotificationProvider newNotification;
            //create the add activity notification
            if (!edit) {
              newNotification =
                  Provider.of<NotificationProvider>(context, listen: false)
                      .createAddEventNotification(
                loggedInUser.id,
                loggedInUser.firstName,
                loggedInUser.lastName,
                loadedTrip.id,
                loadedTrip.title,
                'flight',
              );
            } else {
              newNotification =
                  Provider.of<NotificationProvider>(context, listen: false)
                      .createEditEventNotification(
                loggedInUser.id,
                loggedInUser.firstName,
                loggedInUser.lastName,
                loadedTrip.id,
                loadedTrip.title,
                newFlight.airline,
                'flight',
              );
            }

            //add notification to each companion added
            await Provider.of<NotificationProvider>(context, listen: false)
                .addNotification(loadedTrip.group[i].id, newNotification);
          }
        }
        //reset participant list
        Provider.of<UserProvider>(context, listen: false)
            .resetParticipantsList();
      } catch (error) {
        print(error);
        return;
      }
    }
    Navigator.of(context).pop();
  }

  //Container with horizontal scrollable cards
  Widget cardScroller(
    String cardTitle,
    double avatarMultiplier,
    Widget widget,
    BuildContext ctx,
  ) {
    return Container(
      padding: const EdgeInsets.only(
        top: 18,
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Choose companions to add',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              top: 18,
            ),
            height: screenHeight * 0.225 * avatarMultiplier,
            child: widget,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    loadedTrip = arguments['loadedTrip'];
    editIndex = arguments['editIndex'];
    if (editIndex > -1) {
      setState(() {
        edit = true;
        newFlight = loadedTrip.countries[countryIndex].flights[editIndex];
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: edit
            ? const Text('Edit Flight')
            : const Text(
                'Add Flight',
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
                    width: screenWidth * 0.85,
                    alignment: Alignment.center,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 18.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _suggestion,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      _suggestion = newValue;
                                    });
                                  },
                                  activeColor: Theme.of(context).buttonColor,
                                ),
                                Text(
                                  'Suggestion',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).buttonColor,
                            decoration: InputDecoration(
                              labelText: 'Airline',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).buttonColor,
                                ),
                              ),
                            ),
                            initialValue: newFlight.airline,
                            textInputAction: TextInputAction.next,
                            focusNode: _airlineFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_airlinePhoneNumberFocusNode);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Enter an airline';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              newFlight.airline = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).buttonColor,
                            decoration: InputDecoration(
                              labelText: 'Airline Phone # (Optional)',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).buttonColor,
                                ),
                              ),
                            ),
                            initialValue: newFlight.airlinePhoneNumber,
                            textInputAction: TextInputAction.next,
                            focusNode: _airlinePhoneNumberFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_airlineWebsiteFocusNode);
                            },
                            onSaved: (value) {
                              newFlight.airlinePhoneNumber = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).buttonColor,
                            decoration: InputDecoration(
                              labelText: 'Airline Website (Optional)',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).buttonColor,
                                ),
                              ),
                            ),
                            initialValue: newFlight.airlineWebsite,
                            textInputAction: TextInputAction.next,
                            focusNode: _airlineWebsiteFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_flightNumberFocusNode);
                            },
                            onSaved: (value) {
                              newFlight.airlineWebsite = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).buttonColor,
                            decoration: InputDecoration(
                              labelText: 'Flight #',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).buttonColor,
                                ),
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
                              if (value.isEmpty) {
                                return 'Enter a flight #';
                              } else if (value.length != 4) {
                                return 'Flight # must be 4 digits long';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              newFlight.flightNumber = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).buttonColor,
                            decoration: InputDecoration(
                              labelText: 'Confirmation # (Optional)',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).buttonColor,
                                ),
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
                            cursorColor: Theme.of(context).buttonColor,
                            decoration: InputDecoration(
                              labelText: 'Departure Airport',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).buttonColor,
                                ),
                              ),
                            ),
                            textInputAction: TextInputAction.done,
                            focusNode: _departureAirportFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_departureTerminalFocusNode);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
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
                            cursorColor: Theme.of(context).buttonColor,
                            decoration: InputDecoration(
                              labelText: 'Departure Terminal (Optional)',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).buttonColor,
                                ),
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
                            cursorColor: Theme.of(context).buttonColor,
                            decoration: InputDecoration(
                              labelText: 'Departure Gate (Optional)',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).buttonColor,
                                ),
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
                            cursorColor: Theme.of(context).buttonColor,
                            decoration: InputDecoration(
                              labelText: 'Arrival Airport',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).buttonColor,
                                ),
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
                              if (value.isEmpty) {
                                return 'Enter an arrival airport';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              newFlight.arrivalAirport = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).buttonColor,
                            decoration: InputDecoration(
                              labelText: 'Arrival Terminal (Optional)',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).buttonColor,
                                ),
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
                            cursorColor: Theme.of(context).buttonColor,
                            decoration: InputDecoration(
                              labelText: 'Arrival Gate (Optional)',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).buttonColor,
                                ),
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
                          cardScroller(
                            'Group',
                            .65,
                            GroupAvatars(
                              loadedTrip,
                              editIndex,
                              loadedTrip.countries[countryIndex].flights,
                            ),
                            context,
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                              top: 12,
                              bottom: 18,
                            ),
                            width: screenWidth,
                            child: FlatButton(
                              child: Text(
                                'Submit',
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                              onPressed: () => _addOrEditFlight(),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 30.0, vertical: 8.0),
                              color: Theme.of(context).buttonColor,
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
