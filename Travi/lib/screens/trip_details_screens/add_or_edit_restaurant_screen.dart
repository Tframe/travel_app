import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/trip_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/trips_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/notification_provider.dart';
import './widgets/group_avatars.dart';

class AddOrEditRestaurantScreen extends StatefulWidget {
  static const routeName = '/add-or-edit-restaurant-screen';
  @override
  _AddOrEditRestaurantScreenState createState() =>
      _AddOrEditRestaurantScreenState();
}

class _AddOrEditRestaurantScreenState extends State<AddOrEditRestaurantScreen> {
  double screenHeight;
  double screenWidth;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _nameFocusNode = FocusNode();
  final _phoneNumberFocusNode = FocusNode();
  final _websiteFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _reservationIdFocusNode = FocusNode();

  TripProvider loadedTrip;
  bool edit = false;
  int editIndex = -1;
  bool _suggestion = false;
  int countryIndex = 0;
  int cityIndex = 0;

  Restaurant newRestaurant = Restaurant(
    id: null,
    chosen: false,
    name: null,
    address: null,
    startingDateTime: null,
    reservationID: null,
    organizerId: null,
    participants: [],
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
      UserProvider loggedInUser =
          Provider.of<UserProvider>(context, listen: false).loggedInUser;
      newRestaurant.organizerId = userId;
      newRestaurant.participants =
          Provider.of<UserProvider>(context, listen: false).getParticipants;

      //get current list of trips to update
      List<TripProvider> trips =
          Provider.of<TripsProvider>(context, listen: false).trips;
      var tripIndex = trips.indexWhere((trip) => trip.id == loadedTrip.id);

      if (edit) {
        await Provider.of<Restaurant>(context, listen: false).editRestaurant(
          loadedTrip.id,
          loadedTrip.organizerId,
          loadedTrip.countries[countryIndex].id,
          loadedTrip.countries[countryIndex].cities[cityIndex].id,
          newRestaurant,
          newRestaurant.id,
        );
        //update restaurant to trip data
        List<Restaurant> restaurants =
            Provider.of<Restaurant>(context, listen: false).restaurants;
        trips[tripIndex].countries[countryIndex].cities[cityIndex].restaurants =
            restaurants;
      } else {
        await Provider.of<Restaurant>(context, listen: false).addRestaurant(
          loadedTrip.id,
          loadedTrip.organizerId,
          loadedTrip.countries[countryIndex].id,
          loadedTrip.countries[countryIndex].cities[cityIndex].id,
          newRestaurant,
        );
        //add activity to trip data
        trips[tripIndex]
            .countries[countryIndex]
            .cities[cityIndex]
            .restaurants
            .add(newRestaurant);
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
              'restaurant',
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
              newRestaurant.name,
              'restaurant',
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
        newRestaurant = loadedTrip
            .countries[countryIndex].cities[cityIndex].restaurants[editIndex];
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: edit
            ? const Text(
                'Edit Restaurant',
              )
            : const Text(
                'Add Restaurant',
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
                              labelText: 'Name',
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
                            cursorColor: Theme.of(context).buttonColor,
                            decoration: InputDecoration(
                              labelText: 'Phone # (Optional)',
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
                            cursorColor: Theme.of(context).buttonColor,
                            decoration: InputDecoration(
                              labelText: 'Website (Optional)',
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
                            cursorColor: Theme.of(context).buttonColor,
                            decoration: InputDecoration(
                              labelText: 'Address',
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
                          cardScroller(
                            'Group',
                            .65,
                            GroupAvatars(
                              loadedTrip,
                              editIndex,
                              loadedTrip.countries[countryIndex]
                                  .cities[cityIndex].restaurants,
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
                              onPressed: () => _addOrEditRestaurant(),
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
