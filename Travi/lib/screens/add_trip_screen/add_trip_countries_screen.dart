import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/places.dart';
import '../../providers/trip_provider.dart';
import '../../providers/country_provider.dart';
import '../../providers/countries_provider.dart';
import './add_trip_cities_screen.dart';

class AddTripCountriesScreen extends StatefulWidget {
  static const routeName = '/add-trip-countries-screen';

  @override
  _AddTripCountriesScreenState createState() => _AddTripCountriesScreenState();
}

class _AddTripCountriesScreenState extends State<AddTripCountriesScreen> {

  final _listViewController = ScrollController();
  bool _countryPicker = true;
  var _numberPlaces = List<Container>();
  int _placesIndex = 0;

  var tripValues = TripProvider(
    id: null,
    title: null,
    startDate: null,
    endDate: null,
    countries: [
      Country(
        id: null,
        country: null,
        latitude: null,
        longitude: null,
      ),
    ],
    description: null,
  );

  Future<void> _addCountry() async {
    final newCountry = Provider.of<Countries>(context, listen: false).countries;
    tripValues.countries = newCountry;
    print(newCountry.length);
    print(_placesIndex);
    if (newCountry.length != _placesIndex) {
      return showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Missing Selection'),
              content: const Text(
                  'Missing one or more selections. Tap any suggestion.'),
              actions: [
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }

    Navigator.of(context)
        .pushNamed(AddTripCitiesScreen.routeName, arguments: tripValues);
  }

  //adds a field for the country
  Future<void> _addCountryField(String presetCountry) async {
    _numberPlaces = List.from(_numberPlaces)
      ..add(
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Places(_countryPicker, presetCountry),
            ],
          ),
        ),
      );
    setState(() {
      _placesIndex++;
    });
    Timer(Duration(milliseconds: 50), () => _scrollToBottom());
  }

  void _scrollToBottom() {
    _listViewController.animateTo(
      _listViewController.position.maxScrollExtent + 50,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  //Remove last country field.
  void _removeCountryField() {
    if (_placesIndex == _numberPlaces.length) {
      Provider.of<Countries>(context, listen: false)
          .removeCountry(_numberPlaces.length - 1);
    }
    setState(() {
      _numberPlaces = List.from(_numberPlaces)..removeLast();
      _placesIndex--;
    });
  }


  //Pop back a page and clear out provider
  void _backPage() async {
    final removed = await Provider.of<Countries>(context, listen: false).removeAllCountries();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    tripValues = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Countries',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: _backPage,
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(
              horizontal: 10,
            ),
            width: screenWidth,
            decoration: BoxDecoration(
                // color: Theme.of(context).accentColor,
                ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: screenHeight * 0.035,
                  ),
                  Text(
                    'Which countries will you be traveling to?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Divider(
                    thickness: 3,
                    color: Theme.of(context).primaryColor,
                  ),
                  Container(
                    height: screenHeight * 0.50,
                    margin: EdgeInsets.only(bottom: 25),
                    child: ListView(
                      controller: _listViewController,
                      children: _numberPlaces,
                    ),
                  ),
                  Divider(
                    thickness: 3,
                    color: Theme.of(context).primaryColor,
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    width: screenWidth,
                    child: FlatButton(
                      child: Text(
                        'Add Another Country',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      onPressed:() => _addCountryField(''),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    width: screenWidth,
                    child: FlatButton(
                      child: Text(
                        'Remove Last',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      onPressed: _removeCountryField,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    width: screenWidth,
                    child: FlatButton(
                      child: Text(
                        'Next',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      onPressed: _addCountry,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                      color: Theme.of(context).primaryColor,
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
