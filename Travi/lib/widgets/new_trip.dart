import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


//TODO LOOK INTO DATE RANGE
// import 'package:syncfusion_flutter_core/core.dart';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../providers/trip_provider.dart';
import '../providers/trips_provider.dart';

const kGoogleApiKey = "AIzaSyDCPPoOx6ihjBCfPF5nWPsUJ3OWO83u-QM";

final homeScaffoldKey = GlobalKey<ScaffoldState>();
final searchScaffoldKey = GlobalKey<ScaffoldState>();

class NewTrip extends StatefulWidget {
  final Function addTrip;
  NewTrip(this.addTrip);

  @override
  _NewTripState createState() => _NewTripState();
}

class _NewTripState extends State<NewTrip> {
  final _formKey = GlobalKey<FormState>();
  final _lastDate = DateTime.now().add(Duration(days: 365));
  // Mode _mode = Mode.overlay;
  // ignore: unused_field
  var _isLoading = false;

  var tripValues = TripProvider(
    id: null,
    title: '',
    startDate: null,
    endDate: null,
    description: '',
  );

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
        _showEndDatePicker();
      }
    });
  }

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

  // void onError(PlacesAutocompleteResponse response) {
  //   homeScaffoldKey.currentState.showSnackBar(
  //     SnackBar(content: Text(response.errorMessage)),
  //   );
  // }

  Future<void> _saveForm(String userId) async {
    final isValid = _formKey.currentState.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<TripsProvider>(context, listen: false)
          .addTrip(tripValues, userId);
    } catch (error) {
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occured'),
          content: Text('Something went wrong'),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  // List<String> _parseDestination(String destination) {
  //   var parsedDestination = destination.split(', ');
  //   var lengthParsedDestination = parsedDestination.length;
  //   var parsedCountry = parsedDestination[lengthParsedDestination - 1];
  //   var parsedState = '';
  //   var parsedCity = '';
  //   if (lengthParsedDestination == 2) {
  //     parsedCity = parsedDestination[0];
  //   } else if (lengthParsedDestination > 2) {
  //     parsedCity = parsedDestination[lengthParsedDestination - 3];
  //     parsedState = parsedDestination[lengthParsedDestination - 2];
  //   }

  //   return [
  //     // Destination(
  //     //   id: null,
  //     //   country: parsedCountry,
  //     //   city: parsedCity,
  //     //   state: parsedState,
  //     // )
  //     'string', 'String', 'string',
  //   ];
  // }

  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser;
    return Card(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.only(
            top: 10,
            left: 10,
            right: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 7),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.only(top: 10),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 8.0,
                ),
                child: Text(
                  'New Trip',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ),
              TextFormField(
                initialValue: tripValues.title,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(
                    fontSize: 15,
                  ),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please provide a title';
                  } else {
                    return null;
                  }
                },
                onSaved: (value) {
                  tripValues = TripProvider(
                    id: null,
                    title: value,
                    startDate: tripValues.startDate,
                    endDate: tripValues.endDate,
                    description: tripValues.description,
                  );
                },
              ),
              // Places(),
              //Container for Start Date
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Choose a Start Date:',
                      style: TextStyle(
                        color: Colors.grey[600],
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
                      'Choose a End Date:',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(left: 5),
                      child: IconButton(
                        icon: Icon(Icons.calendar_today),
                        color: Colors.green,
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
                child: RaisedButton(
                  child: Text('Create'),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: () => _saveForm(user.uid),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
