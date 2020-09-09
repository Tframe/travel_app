import 'dart:async';

import 'package:flutter/material.dart';
import 'package:groupy/screens/add_trip_screen/group_invite_screen.dart';
import 'package:provider/provider.dart';
import '../../widgets/places.dart';
import '../../providers/trip_provider.dart';
import '../../providers/country_provider.dart';
import '../../providers/countries_provider.dart';
import '../../providers/cities_provider.dart';
import '../../providers/city_provider.dart';

class AddTripCitiesScreen extends StatefulWidget {
  static const routeName = '/add-trip-cities-screen';

  @override
  _AddTripCitiesScreenState createState() => _AddTripCitiesScreenState();
}

class _AddTripCitiesScreenState extends State<AddTripCitiesScreen> {
  final _listViewController = ScrollController();
  bool _countryPicker = false;
  bool _cityPicker = true;
  var _numberPlaces = List<Container>();
  var _numberCountries = 0;
  var _cityIndex = 0;
  var _countryIndex = 0;
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
        cities: [
          City(
            id: null,
            city: null,
            longitude: null,
            latitude: null,
            places: null,
          ),
        ],
      ),
    ],
    description: null,
  );

  //Function to add city to trip values.
  Future<void> _addCity() async {
    //get city saved in provider, asign to tripValues then remove city from
    //provider to save next set of cities
    final newCity = Provider.of<Cities>(context, listen: false).cities;
    tripValues.countries[_countryIndex].cities = newCity;
    final removed =
        await Provider.of<Cities>(context, listen: false).removeAllCities();

    //Change country index to get list of cities for next country
    if(_countryIndex < (tripValues.countries.length - 1)){
      setState(() {
        _countryIndex++;
        _numberPlaces = [];
      });
      return;
    }

    //After going through each country, navigate to group invite page
    Navigator.of(context)
          .pushNamed(GroupInviteScreen.routeName, arguments: tripValues);
  }

  //adds a field for the country
  void _addCityField() {
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
              Places(_countryPicker, _cityPicker, tripValues.countries[_countryIndex].country),
            ],
          ),
        ),
      );
    setState(() {
      _placesIndex++;
    });
    Timer(Duration(milliseconds: 50), () => _scrollToBottom());
  }

  //Function to scroll ListView of Places text fields to automatically scroll
  //to the bottom with an animation
  void _scrollToBottom() {
    _listViewController.animateTo(
      _listViewController.position.maxScrollExtent + 50,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  //Removes the last city field
  void _removeCityField() {
    if (_placesIndex == _numberPlaces.length) {
      Provider.of<Cities>(context, listen: false)
          .removeCity(_numberPlaces.length - 1);
    }
    setState(() {
      _numberPlaces = List.from(_numberPlaces)..removeLast();
      _placesIndex--;
    });
  }

  //Pop back a page and clear out provider
  void _backPage() async {
    if (_countryIndex > 0) {
      setState(() {
        _countryIndex--;
      });
      return;
    }
    final removed =
        await Provider.of<Cities>(context, listen: false).removeAllCities();
    Navigator.of(context).pop();
  }

  //Skip button feature if user doesn't know any cities to stop.
  void _skipButton() {
    if (_cityIndex == _numberCountries - 1) {
      Navigator.of(context)
           .pushNamed(GroupInviteScreen.routeName, arguments: tripValues);
      return;
    }
    setState(() {
      _countryIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    tripValues = ModalRoute.of(context).settings.arguments;
    _numberCountries = tripValues.countries.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cities',
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
              horizontal: screenWidth * 0.05,
            ),
            width: screenWidth,
            decoration: BoxDecoration(
                // color: Theme.of(context).accentColor,
                ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: screenHeight * 0.015,
                  ),
                  Text(
                    'Cities in ${tripValues.countries[_countryIndex].country}?',
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
                        'Add City',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      onPressed: () => _addCityField(),
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
                        'Remove Last City',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      onPressed: _removeCityField,
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
                        _numberPlaces.length == 0 ? 'Skip' : 'Next',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      onPressed:
                          _numberPlaces.length == 0 ? _skipButton : _addCity,
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
