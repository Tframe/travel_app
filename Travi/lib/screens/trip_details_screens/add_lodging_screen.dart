import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../providers/trip_provider.dart';
import '../../providers/lodging_provider.dart';

class AddLodgingScreen extends StatefulWidget {
  static const routeName = '/add-lodging-screen';
  @override
  _AddLodgingScreenState createState() => _AddLodgingScreenState();
}

class _AddLodgingScreenState extends State<AddLodgingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _nameFocusNode = FocusNode();
  final _countryFocusNode = FocusNode();
  final _cityFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _reservationIdFocusNode = FocusNode();

  final _lastDate = DateTime.now().add(Duration(days: 365));

  TripProvider loadedTrip;

  Lodging tempLodging = Lodging(
    id: null,
    name: null,
    country: null,
    city: null,
    address: null,
    checkInDate: null,
    checkInTime: null,
    checkOutDate: null,
    checkOutTime: null,
    reservationID: null,
  );

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _countryFocusNode.dispose();
    _cityFocusNode.dispose();
    _addressFocusNode.dispose();
    _reservationIdFocusNode.dispose();
    super.dispose();
  }

  void _saveContact() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();

    try {
      // await Provider.of<UserProvider>(context, listen: false)
      //     .updateAbout(userValues, user.uid);
    } catch (error) {
      print(error);
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _showStartDatePicker() async {
    await showDatePicker(
      context: context,
      helpText: 'Start Date',
      initialDate: loadedTrip.startDate,
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
          tempLodging.checkInDate = selectedDate;
        });
        _showEndDatePicker();
      }
    });
  }

  Future<void> _showEndDatePicker() async {
    if (loadedTrip.startDate == null) {
      await _showStartDatePicker();
    }
    showDatePicker(
      context: context,
      helpText: 'End Date',
      initialDate: loadedTrip.endDate,
      firstDate: DateTime.now(),
      lastDate: loadedTrip.endDate,
    ).then((selectedDate) {
      if (selectedDate == null) {
        return;
      } else {
        setState(() {
          tempLodging.checkOutDate = selectedDate;
        });
      }
    });
  }

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
          tempLodging.checkInTime = selectedTime;
        });
      }
    });
  }

  Future<void> _showCheckoutTimePicker() async {
    showTimePicker(
      context: context,
      helpText: 'Checkout Time',
      initialTime: TimeOfDay(hour: 00, minute: 00),
    ).then((selectedTime) {
      if (selectedTime == null) {
        return;
      } else {
        setState(() {
          tempLodging.checkOutTime = selectedTime;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    loadedTrip = arguments['loadedTrip'];
    return Scaffold(
      appBar: AppBar(title: Text('Add Lodging')),
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
                            textInputAction: TextInputAction.next,
                            focusNode: _nameFocusNode,
                            // validator: (value) {
                            //   if (value.isEmpty) {
                            //     return 'Please enter the lodging name.';
                            //   }
                            //   return null;
                            // },
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_countryFocusNode);
                            },
                            onSaved: (value) {
                              tempLodging.name = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                              labelText: 'Country',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            focusNode: _countryFocusNode,
                            // validator: (value) {
                            //   if (value.isEmpty) {
                            //     return 'Please enter the country.';
                            //   }
                            //   return null;
                            // },
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_cityFocusNode);
                            },
                            onSaved: (value) {
                              tempLodging.country = value;
                            },
                          ),
                          TextFormField(
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                              labelText: 'City',
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            focusNode: _cityFocusNode,
                            // validator: (value) {
                            //   if (value.isEmpty) {
                            //     return 'Please enter a city.';
                            //   }
                            //   return null;
                            // },
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_addressFocusNode);
                            },
                            onSaved: (value) {
                              tempLodging.city = value;
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
                            textInputAction: TextInputAction.next,
                            focusNode: _addressFocusNode,
                            // validator: (value) {
                            //   if (value.isEmpty) {
                            //     return 'Please enter an address.';
                            //   }
                            //   return null;
                            // },
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
                            textInputAction: TextInputAction.next,
                            focusNode: _reservationIdFocusNode,
                            // validator: (value) {
                            //   if (value.isEmpty) {
                            //     return 'Please enter some information about yourself.';
                            //   }
                            //   return null;
                            // },
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
                                    'Checkin Date:',
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
                                  padding: const EdgeInsets.only(right: 30),
                                  width: screenWidth * 0.4,
                                  child: tempLodging.checkInDate == null
                                      ? Text('')
                                      : Text(
                                          '${DateFormat.yMd().format(tempLodging.checkInDate)}',
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: screenWidth * 0.25,
                                  child: Text(
                                    'Checkin Time:',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  child: IconButton(
                                    icon: Icon(Icons.access_time),
                                    color: Colors.green,
                                    onPressed: _showCheckinTimePicker,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(right: 30),
                                  width: screenWidth * 0.4,
                                  child: tempLodging.checkInTime == null
                                      ? Text('')
                                      : Text(
                                          '${tempLodging.checkInTime.format(context)}',
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
                                    'Checkout Date:',
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
                                  padding: const EdgeInsets.only(right: 30),
                                  width: screenWidth * 0.4,
                                  child: tempLodging.checkOutDate == null
                                      ? Text('')
                                      : Text(
                                          '${DateFormat.yMd().format(tempLodging.checkOutDate)}',
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  width: screenWidth * 0.25,
                                  child: Text(
                                    'Checkout Time:',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(left: 5),
                                  child: IconButton(
                                    icon: Icon(Icons.access_time),
                                    color: Colors.green,
                                    onPressed: _showCheckoutTimePicker,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(right: 30),
                                  width: screenWidth * 0.4,
                                  child: tempLodging.checkOutTime == null
                                      ? Text('')
                                      : Text(
                                          '${tempLodging.checkOutTime.format(context)}',
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
                                'Save',
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                              onPressed: _saveContact,
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
