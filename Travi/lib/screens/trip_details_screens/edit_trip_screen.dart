/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: screen for editing trip info
 */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../providers/trips_provider.dart';
import '../../providers/trip_provider.dart';

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

  User user;

  var _editedTrip = TripProvider(
    id: null,
    title: '',
    startDate: null,
    endDate: null,
    countries: [],
    tripImageUrl: '',
    description: '',
    group: [],
  );

  var _isLoading = false;

  // @override
  // void didChangeDependencies() {
  //   if (_isInit) {
  //     final tripId = ModalRoute.of(context).settings.arguments as String;
  //     if (tripId != null) {
  //       _editedTrip =
  //           Provider.of<TripsProvider>(context, listen: false).findById(tripId);
  //       _initValues = {
  //         'title': _editedTrip.title,
  //         'startDate': _editedTrip.startDate,
  //         'endDate': _editedTrip.endDate,
  //         'description': _editedTrip.description,
  //         'countries': _editedTrip.countries,
  //       };
  //     }
  //   }

  //   _isInit = false;

  //   super.didChangeDependencies();
  // }

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
  void _saveForm() async {
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
          .updateTripDetails(_editedTrip, user);
    } catch (error) {
      throw error;
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  Future<void> _showStartDatePicker() async {
    await showDatePicker(
      context: context,
      helpText: 'Start Date',
      initialDate: _editedTrip.startDate,
      firstDate: DateTime.now(),
      lastDate: _lastDate,
    ).then((selectedDate) {
      if (selectedDate == null) {
        return;
      } else {
        setState(() {
          _editedTrip.startDate = selectedDate;
        });
        _showEndDatePicker();
      }
    });
  }

  Future<void> _showEndDatePicker() async {
    if (_editedTrip.startDate == null) {
      await _showStartDatePicker();
    }
    showDatePicker(
      context: context,
      helpText: 'End Date',
      initialDate: _editedTrip.endDate,
      firstDate: DateTime.now(),
      lastDate: _lastDate,
    ).then((selectedDate) {
      if (selectedDate == null) {
        return;
      } else {
        setState(() {
          _editedTrip.endDate = selectedDate;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    user = arguments['user'];
    final trip = arguments['trip'];
    setState(() {
      _editedTrip = trip;
    });
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Trip'),
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
                      cursorColor: Theme.of(context).buttonColor,
                      initialValue: _editedTrip.title,
                      decoration: InputDecoration(
                        labelText: 'Title',
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
                        _editedTrip.title = value;
                      },
                    ),

                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: screenWidth * 0.25,
                            child: Text(
                              'Start Date:',
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
                            width: screenWidth * 0.40,
                            child: _editedTrip.startDate == null
                                ? Text('')
                                : Text(
                                    '${DateFormat.yMd().format(_editedTrip.startDate)}',
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
                              'End Date:',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: Icon(Icons.calendar_today),
                              color: Colors.green,
                              onPressed: _showEndDatePicker,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 30),
                            width: screenWidth * 0.40,
                            child: _editedTrip.endDate == null
                                ? Text('')
                                : Text(
                                    '${DateFormat.yMd().format(_editedTrip.endDate)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    TextFormField(
                      initialValue: _editedTrip.description,
                      cursorColor: Theme.of(context).buttonColor,
                      decoration: InputDecoration(
                        labelText: 'Description',
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
                        _editedTrip.description = value;
                      },
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
                        onPressed: _saveForm,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 8.0),
                        color: Theme.of(context).buttonColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
