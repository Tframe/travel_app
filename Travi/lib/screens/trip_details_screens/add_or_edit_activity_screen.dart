import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/trip_provider.dart';
import '../../providers/activity_provider.dart';
import '../../providers/trips_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/notification_provider.dart';
import './widgets/group_avatars.dart';

class AddOrEditActivityScreen extends StatefulWidget {
  static const routeName = '/add-activity-screen';

  @override
  _AddOrEditActivityScreenState createState() =>
      _AddOrEditActivityScreenState();
}

class _AddOrEditActivityScreenState extends State<AddOrEditActivityScreen> {
  double screenHeight;
  double screenWidth;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _titleFocusNode = FocusNode();
  final _phoneNumberFocusNode = FocusNode();
  final _websiteFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _reservationIdFocusNode = FocusNode();

  TripProvider loadedTrip;
  bool edit = false;
  int editIndex = -1;
  bool _suggestion = false;

  Activity newActivity = Activity(
    chosen: false,
    id: null,
    title: null,
    phoneNumber: null,
    website: null,
    reservationID: null,
    address: null,
    startingDateTime: null,
    endingDateTime: null,
    organizerId: null,
    participants: [],
  );

  // ignore: avoid_init_to_null
  TimeOfDay _startTime = null;
  // ignore: avoid_init_to_null
  TimeOfDay _endTime = null;

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    _websiteFocusNode.dispose();
    _addressFocusNode.dispose();
    _reservationIdFocusNode.dispose();
    super.dispose();
  }

  //Saves lodging information
  void _saveActivity() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();

    try {
      String userId = await Provider.of<UserProvider>(context, listen: false)
          .getCurrentUserId();
      UserProvider loggedInUser =
          Provider.of<UserProvider>(context, listen: false).loggedInUser;
      newActivity.organizerId = userId;
      newActivity.participants =
          Provider.of<UserProvider>(context, listen: false).getParticipants;
      newActivity.chosen = !_suggestion;

      //add or edit activity
      await Provider.of<TripsProvider>(context, listen: false)
          .addOrEditActivity(
        loadedTrip,
        loadedTrip.organizerId,
        newActivity,
        edit ? editIndex : -1,
      );

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
              'activity',
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
              newActivity.title,
              'activity',
            );
          }

          //add notification to each companion added
          await Provider.of<NotificationProvider>(context, listen: false)
              .addNotification(loadedTrip.group[i].id, newNotification);
        }
      }

      Provider.of<UserProvider>(context, listen: false).resetParticipantsList();
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
      initialDate: loadedTrip.startDate.isBefore(DateTime.now())
          ? DateTime.now()
          : loadedTrip.startDate,
      firstDate: loadedTrip.startDate.isBefore(DateTime.now())
          ? DateTime.now()
          : loadedTrip.startDate,
      lastDate: loadedTrip.endDate,
    ).then((selectedDate) {
      if (selectedDate == null) {
        return;
      } else {
        setState(() {
          newActivity.startingDateTime = selectedDate;
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
      initialDate:
          edit ? newActivity.endingDateTime : newActivity.startingDateTime,
      firstDate: newActivity.startingDateTime,
      lastDate: loadedTrip.endDate,
    ).then((selectedDate) {
      if (selectedDate == null) {
        return;
      } else {
        setState(() {
          newActivity.endingDateTime = selectedDate;
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
        setDateTime(true, newActivity.startingDateTime, _startTime);
      }
    });
  }

  //Displays the time picker for the checkout time
  Future<void> _showCheckoutTimePicker() async {
    showTimePicker(
      context: context,
      helpText: 'Checkout Time',
      initialTime:
          _startTime == null ? TimeOfDay(hour: 00, minute: 00) : _startTime,
    ).then((selectedTime) {
      if (selectedTime == null) {
        return;
      } else {
        setState(() {
          _endTime = selectedTime;
        });
        setDateTime(false, newActivity.endingDateTime, _endTime);
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
        newActivity.startingDateTime = newDateTime;
      });
    } else if (checkIn == false) {
      setState(() {
        newActivity.endingDateTime = newDateTime;
      });
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
        newActivity = loadedTrip.activities[editIndex];
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: edit
            ? const Text(
                'Edit Activity',
              )
            : const Text(
                'Add Activity',
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
                                  activeColor: Theme.of(context).primaryColor,
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
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                              labelText: 'Title',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                            initialValue: newActivity.title,
                            textInputAction: TextInputAction.next,
                            focusNode: _titleFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_phoneNumberFocusNode);
                            },
                            onSaved: (value) {
                              newActivity.title = value;
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
                            initialValue: newActivity.phoneNumber,
                            textInputAction: TextInputAction.next,
                            focusNode: _phoneNumberFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_websiteFocusNode);
                            },
                            onSaved: (value) {
                              newActivity.phoneNumber = value;
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
                            initialValue: newActivity.website,
                            textInputAction: TextInputAction.next,
                            focusNode: _websiteFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_addressFocusNode);
                            },
                            onSaved: (value) {
                              newActivity.website = value;
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
                            initialValue: newActivity.address,
                            textInputAction: TextInputAction.next,
                            focusNode: _addressFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_reservationIdFocusNode);
                            },
                            onSaved: (value) {
                              newActivity.address = value;
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
                            initialValue: newActivity.reservationID,
                            textInputAction: TextInputAction.done,
                            focusNode: _reservationIdFocusNode,
                            onSaved: (value) {
                              newActivity.reservationID = value;
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
                                  child: newActivity.startingDateTime == null
                                      ? Text('')
                                      : Text(
                                          '${DateFormat.yMd().add_jm().format(newActivity.startingDateTime)}',
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
                                  child: newActivity.endingDateTime == null
                                      ? Text('')
                                      : Text(
                                          '${DateFormat.yMd().add_jm().format(newActivity.endingDateTime)}',
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
                                loadedTrip, editIndex, loadedTrip.activities),
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
                              onPressed: _saveActivity,
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
