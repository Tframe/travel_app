/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: screen for displaying trip transportation.
 * user can choose to add new transportation, select transportation to
 * edit, or remove the transportation.
 */
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/trips_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/transportation_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/notification_provider.dart';
import './widgets/group_avatars.dart';

class AddOrEditTransportationScreen extends StatefulWidget {
  static const routeName = '/add-transportation-screen';

  @override
  _AddOrEditTransportationScreenState createState() =>
      _AddOrEditTransportationScreenState();
}

class _AddOrEditTransportationScreenState
    extends State<AddOrEditTransportationScreen> {
  double screenHeight;
  double screenWidth;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _companyFocusNode = FocusNode();
  final _reservationFocusNode = FocusNode();
  final _startingAddressFocusNode = FocusNode();
  final _endingAddressFocusNode = FocusNode();
  final _transportationTypeFocusNode = FocusNode();

  TripProvider loadedTrip;
  bool edit = false;
  int editIndex = -1;
  bool _suggestion = false;
  int countryIndex = 0;
  int cityIndex = 0;

  List<DropdownMenuItem<int>> transportationType = [];
  int _selectedTransportationType = 0;
  Transportation newTransportation = Transportation(
    id: null,
    chosen: false,
    company: null,
    reservationID: null,
    startingAddress: null,
    startingDateTime: null,
    endingAddress: null,
    endingDateTime: null,
    transportationType: null,
    organizerId: null,
    participants: [],
  );

  // ignore: avoid_init_to_null
  TimeOfDay _startTime = null;
  // ignore: avoid_init_to_null
  TimeOfDay _endTime = null;

  @override
  void initState() {
    transportationType = [];
    transportationType.add(
      new DropdownMenuItem(
        child: new Text(
          'Choose a transportation type',
        ),
        value: 0,
      ),
    );
    transportationType.add(
      new DropdownMenuItem(
        child: new Text(
          'Train',
        ),
        value: 1,
      ),
    );
    transportationType.add(
      new DropdownMenuItem(
        child: new Text(
          'Boat',
        ),
        value: 2,
      ),
    );
    transportationType.add(
      new DropdownMenuItem(
        child: new Text(
          'Car Pickup',
        ),
        value: 3,
      ),
    );
    transportationType.add(
      new DropdownMenuItem(
        child: new Text(
          'Car Rental',
        ),
        value: 4,
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    _companyFocusNode.dispose();
    _reservationFocusNode.dispose();
    _startingAddressFocusNode.dispose();
    _endingAddressFocusNode.dispose();
    _transportationTypeFocusNode.dispose();
    super.dispose();
  }

  //Displays the datepicker for the start date
  Future<void> _showStartDatePicker() async {
    await showDatePicker(
      context: context,
      helpText: 'Start Date',
      initialDate: loadedTrip.startDate.isBefore(DateTime.now())
          ? DateTime.now()
          : loadedTrip.startDate,
      firstDate: loadedTrip.startDate.isBefore(DateTime.now())
          ? DateTime.now()
          : loadedTrip.startDate,
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
          newTransportation.startingDateTime = selectedDate;
        });
        _showCheckinTimePicker();
      }
    });
  }

  //Displays the datepicker for the end date
  Future<void> _showEndDatePicker() async {
    if (loadedTrip.startDate == null) {
      await _showStartDatePicker();
    }
    showDatePicker(
      context: context,
      helpText: 'End Date',
      initialDate: newTransportation.startingDateTime,
      firstDate: newTransportation.startingDateTime,
      lastDate: loadedTrip.endDate,
    ).then((selectedDate) {
      if (selectedDate == null) {
        return;
      } else {
        setState(() {
          newTransportation.endingDateTime = selectedDate;
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
          _startTime = selectedTime;
        });
        setDateTime(true, newTransportation.startingDateTime, _startTime);
      }
    });
  }

  //Displays the time picker for the checkout time
  Future<void> _showCheckoutTimePicker() async {
    showTimePicker(
      context: context,
      helpText: 'Checkout Time',
      initialTime: _startTime,
    ).then((selectedTime) {
      if (selectedTime == null) {
        return;
      } else {
        setState(() {
          _endTime = selectedTime;
        });
        setDateTime(false, newTransportation.endingDateTime, _endTime);
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
        newTransportation.startingDateTime = newDateTime;
      });
    } else if (endDate == false) {
      setState(() {
        newTransportation.endingDateTime = newDateTime;
      });
    }
  }

  //Saves transporation
  void _addOrEditTransportation() async {
    if (!_formKey.currentState.validate()) {
      return;
    } else {
      _formKey.currentState.save();
      setTransportationType();
      try {
        String userId = await Provider.of<UserProvider>(context, listen: false)
            .getCurrentUserId();
        UserProvider loggedInUser =
            Provider.of<UserProvider>(context, listen: false).loggedInUser;

        newTransportation.organizerId = userId;
        newTransportation.participants =
            Provider.of<UserProvider>(context, listen: false).getParticipants;
        newTransportation.chosen = !_suggestion;

        //get current list of trips to update
        List<TripProvider> trips =
            Provider.of<TripsProvider>(context, listen: false).trips;
        var tripIndex = trips.indexWhere((trip) => trip.id == loadedTrip.id);

        if (edit) {
          await Provider.of<Transportation>(context, listen: false)
              .editTransportation(
            loadedTrip.id,
            loadedTrip.organizerId,
            loadedTrip.countries[countryIndex].id,
            loadedTrip.countries[countryIndex].cities[cityIndex].id,
            newTransportation,
            newTransportation.id,
          );
          //update transportation to trip data
          List<Transportation> transportations =
              Provider.of<Transportation>(context, listen: false)
                  .transportations;
          trips[tripIndex]
              .countries[countryIndex]
              .cities[cityIndex]
              .transportations = transportations;
        } else {
          await Provider.of<Transportation>(context, listen: false)
              .addTransportation(
            loadedTrip.id,
            loadedTrip.organizerId,
            loadedTrip.countries[countryIndex].id,
            loadedTrip.countries[countryIndex].cities[cityIndex].id,
            newTransportation,
          );

          if (trips[tripIndex]
                  .countries[countryIndex]
                  .cities[cityIndex]
                  .transportations ==
              null) {
            trips[tripIndex]
                .countries[countryIndex]
                .cities[cityIndex]
                .transportations = [];
          }
          //add activity to trip data
          trips[tripIndex]
              .countries[countryIndex]
              .cities[cityIndex]
              .transportations
              .add(newTransportation);
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
                'transportation',
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
                newTransportation.company,
                'transportation',
              );
            }

            //add notification to each companion added
            await Provider.of<NotificationProvider>(context, listen: false)
                .addNotification(loadedTrip.group[i].id, newNotification);
          }
        }

        Provider.of<UserProvider>(context, listen: false)
            .resetParticipantsList();
      } catch (error) {
        print(error);
        return;
      }
    }
    Navigator.of(context).pop();
  }

  //Takes value from drop down and sets it to enum
  void setTransportationType() {
    String tempType = '';
    if (_selectedTransportationType == 1) {
      tempType = 'train';
    } else if (_selectedTransportationType == 2) {
      tempType = 'boat';
    } else if (_selectedTransportationType == 3) {
      tempType = 'carPickup';
    } else if (_selectedTransportationType == 4) {
      tempType = 'carRental';
    }
    setState(() {
      newTransportation.transportationType = tempType;
    });
  }

  void setEditType() {
    if (newTransportation.transportationType == 'train') {
      _selectedTransportationType = 1;
    } else if (newTransportation.transportationType == 'boat') {
      _selectedTransportationType = 2;
    } else if (newTransportation.transportationType == 'carPickup') {
      _selectedTransportationType = 3;
    } else if (newTransportation.transportationType == 'carRental') {
      _selectedTransportationType = 4;
    }
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
        newTransportation = loadedTrip.countries[countryIndex].cities[cityIndex]
            .transportations[editIndex];
        setEditType();
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: edit
            ? const Text('Edit Transportation')
            : const Text(
                'Add Transportation',
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
                          DropdownButtonFormField(
                            decoration: InputDecoration(
                              labelText: 'Transportation Type',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).buttonColor,
                                ),
                              ),
                            ),
                            items: transportationType,
                            value: _selectedTransportationType,
                            validator: (value) {
                              if (value == 0) {
                                return 'Please choose a transportation type!';
                              }
                              return null;
                            },
                            onChanged: (selectedValue) {
                              FocusScope.of(context)
                                  .requestFocus(_companyFocusNode);
                              setState(() {
                                _selectedTransportationType = selectedValue;
                              });
                            },
                            focusNode: _transportationTypeFocusNode,
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).buttonColor,
                            decoration: InputDecoration(
                              labelText: 'Company',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).buttonColor,
                                ),
                              ),
                            ),
                            initialValue: newTransportation.company,
                            textInputAction: TextInputAction.next,
                            focusNode: _companyFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_startingAddressFocusNode);
                            },
                            onSaved: (value) {
                              newTransportation.company = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).buttonColor,
                            decoration: InputDecoration(
                              labelText: 'Starting Location Address',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).buttonColor,
                                ),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            focusNode: _startingAddressFocusNode,
                            initialValue: newTransportation.startingAddress,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_endingAddressFocusNode);
                            },
                            onSaved: (value) {
                              newTransportation.startingAddress = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).buttonColor,
                            decoration: InputDecoration(
                              labelText: 'Ending Location Address',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).buttonColor,
                                ),
                              ),
                            ),
                            initialValue:
                                edit ? newTransportation.endingAddress : '',
                            textInputAction: TextInputAction.next,
                            focusNode: _endingAddressFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_reservationFocusNode);
                            },
                            onSaved: (value) {
                              newTransportation.endingAddress = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).buttonColor,
                            decoration: InputDecoration(
                              labelText: 'Reservation ID',
                              labelStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).buttonColor,
                                ),
                              ),
                            ),
                            textInputAction: TextInputAction.done,
                            focusNode: _reservationFocusNode,
                            initialValue:
                                edit ? newTransportation.reservationID : '',
                            onSaved: (value) {
                              newTransportation.reservationID = value;
                            },
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: screenWidth * 0.25,
                                  child: Text(
                                    'Starting Date and Time:',
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
                                  child:
                                      newTransportation.startingDateTime == null
                                          ? Text('')
                                          : Text(
                                              '${DateFormat.yMd().add_jm().format(newTransportation.startingDateTime)}',
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
                                    'Ending Date and Time:',
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
                                  child:
                                      newTransportation.endingDateTime == null
                                          ? Text('')
                                          : Text(
                                              '${DateFormat.yMd().add_jm().format(newTransportation.endingDateTime)}',
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
                              loadedTrip.countries[countryIndex]
                                  .cities[cityIndex].transportations,
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
                              onPressed: () => _addOrEditTransportation(),
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
