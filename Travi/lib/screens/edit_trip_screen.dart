import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';

import '../providers/trips_provider.dart';
import '../providers/trip_provider.dart';
import '../providers/auth.dart';

const kGoogleApiKey = "AIzaSyDCPPoOx6ihjBCfPF5nWPsUJ3OWO83u-QM";

final homeScaffoldKey = GlobalKey<ScaffoldState>();
final searchScaffoldKey = GlobalKey<ScaffoldState>();

class EditTripScreen extends StatefulWidget {
  static const routeName = '/edit-trip';
  @override
  _EditTripScreenState createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<EditTripScreen> {
  // Mode _mode = Mode.overlay;
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _startDateFocusNode = FocusNode();
  final _endDateFocusNode = FocusNode();
  final _destinationFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final _lastDate = DateTime.now().add(Duration(days: 365));
  
  var _editedTrip = TripProvider(
    id: null,
    title: '',
    startDate: null,
    endDate: null,
    countries: [],
    image: '',
    description: '',
    group: [],
    lodgings: [],
    activities: [],
    transportations: [],
  );
  var _isInit = true;

  var _initValues = {
    'title': '',
    'startDate': null,
    'endDate': null,
    // 'destinations': [
    //   {
    //     'city': '',
    //     'state': '',
    //     'country': '',
    //   }
    // ],
    'image': '',
    'description': '',
    'group': [],
    'lodgings': [],
    'activities': [],
    'transportations': [],
  };


  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final tripId = ModalRoute.of(context).settings.arguments as String;
      if (tripId != null) {
        _editedTrip =
            Provider.of<TripsProvider>(context, listen: false).findById(tripId);
        _initValues = {
          'title': _editedTrip.title,
          'startDate': _editedTrip.startDate,
          'endDate': _editedTrip.endDate,
          // 'destinations': [
          //   {
          //     'city': _editedTrip.destinations[0].city,
          //     'state': _editedTrip.destinations[0].state,
          //     'country': _editedTrip.destinations[0].country,
          //   },
          // ],
          'description': _editedTrip.description,
        };
        
      }
    }

    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _startDateFocusNode.dispose();
    _endDateFocusNode.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  //function to save new form data to state and database
  Future<void> _saveForm(String userId) async {
    final isValid = _formKey.currentState.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedTrip.id != null) {
      try {
        //await Provider.of<TripsProvider>(context, listen: false)
            //.updateTrip(_editedTrip.id, _editedTrip, userId);
      } catch (error) {
        throw error;
      }
    } else {
      try {
        await Provider.of<TripsProvider>(context, listen: false)
            .addTrip(_editedTrip, userId);
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
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  // void onError(PlacesAutocompleteResponse response) {
  //   homeScaffoldKey.currentState.showSnackBar(
  //     SnackBar(content: Text(response.errorMessage)),
  //   );
  // }

  // List<Destination> _parseDestination(String destination) {
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
  //   setState(() {
  //     // _editedTrip.destinations[0].city = parsedCity;
  //     // _editedTrip.destinations[0].state = parsedState;
  //     // _editedTrip.destinations[0].country = parsedCountry;
  //   });
  //   return [
  //     Destination(
  //       id: null,
  //       country: parsedCountry,
  //       city: parsedCity,
  //       state: parsedState,
  //     )
  //   ];
  // }

  Future<void> _showStartDatePicker() async {
    await showDatePicker(
      context: context,
      helpText: 'Start Date',
      initialDate: _initValues['startDate'],
      firstDate: DateTime.now(),
      lastDate: _lastDate,
    ).then((selectedDate) {
      if (selectedDate == null) {
        return;
      } else {
        setState(() {
          _editedTrip.startDate = selectedDate;
          _initValues['startDate'] = selectedDate;
        });
        _showEndDatePicker();
      }
    });
  }

  Future<void> _showEndDatePicker() async {
    if (_initValues['startDate'] == null) {
      await _showStartDatePicker();
    }
    showDatePicker(
      context: context,
      helpText: 'End Date',
      initialDate: _initValues['endDate'],
      firstDate: DateTime.now(),
      lastDate: _lastDate,
    ).then((selectedDate) {
      if (selectedDate == null) {
        return;
      } else {
        setState(() {
          _editedTrip.endDate = selectedDate;
          _initValues['endDate'] = selectedDate;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<Auth>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Trip'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => _saveForm(authData.userId),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_titleFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a title';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        _editedTrip = TripProvider(
                          title: value,
                          image: _editedTrip.image,
                          startDate: _editedTrip.startDate,
                          endDate: _editedTrip.endDate,
                          description: _editedTrip.description,
                          id: _editedTrip.id,
                          countries: _editedTrip.countries,
                        );
                      },
                    ),
                    // PlacesAutocompleteFormField(
                    //   apiKey: kGoogleApiKey,
                    //   onError: onError,
                    //   mode: _mode,
                    //   language: "en",
                    //   initialValue:
                    //       '${_initDestinationValues['city'] + (_initDestinationValues['state'] == null ? '' : ', ' + _initDestinationValues['state']) + ', ' + _initDestinationValues['country']}',
                    //   inputDecoration: InputDecoration(
                    //     labelText: 'Destination',
                    //     labelStyle: TextStyle(
                    //       fontSize: 20,
                    //     ),
                    //   ),
                    //   validator: (value) {
                    //     if (value.isEmpty) {
                    //       return 'Please provide a destination';
                    //     } else {
                    //       return null;
                    //     }
                    //   },
                    //   onSaved: (value) async {
                    //     _editedTrip = TripProvider(
                    //       id: _editedTrip.id,
                    //       image: _editedTrip.image,
                    //       title: _editedTrip.title,
                    //       startDate: _editedTrip.startDate,
                    //       endDate: _editedTrip.endDate,
                    //       destinations: null,//_parseDestination(value),
                    //       description: _editedTrip.description,
                    //     );
                    //   },
                    // ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(labelText: 'Description'),
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      maxLines: 4,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a desecription';
                        }
                        if (value.length < 10) {
                          return 'Descripion must be 10 characters or longer';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        _editedTrip = TripProvider(
                          id: _editedTrip.id,
                          title: _editedTrip.title,
                          image: _editedTrip.image,
                          startDate: _editedTrip.startDate,
                          endDate: _editedTrip.endDate,
                          countries: _editedTrip.countries,
                          description: value,
                        );
                      },
                    ),
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
                            child: _initValues['startDate'] == null
                                ? Text('')
                                : Text(
                                    '${DateFormat.yMd().format(_initValues['startDate'])}',
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
                            child: _initValues['endDate'] == null
                                ? Text('')
                                : Text(
                                    '${DateFormat.yMd().format(_initValues['endDate'])}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
