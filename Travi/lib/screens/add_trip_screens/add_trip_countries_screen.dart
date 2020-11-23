import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/places.dart';
import '../../providers/trip_provider.dart';
import '../../providers/country_provider.dart';
import './add_trip_cities_screen.dart';
import './add_trip_group_invite_screen.dart';

class AddTripCountriesScreen extends StatefulWidget {
  static const routeName = '/add-trip-countries-screen';

  @override
  _AddTripCountriesScreenState createState() => _AddTripCountriesScreenState();
}

class _AddTripCountriesScreenState extends State<AddTripCountriesScreen> {
  final _listViewController = ScrollController();
  bool _countryPicker = true;
  bool _cityPicker = false;
  var _numberPlaces = List<Widget>();
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
    final newCountry = Provider.of<Country>(context, listen: false).countries;
    tripValues.countries = newCountry;
    if (newCountry.length != _placesIndex || newCountry.length == 0) {
      return showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: (newCountry.length == 0)
                  ? const Text('Add a country')
                  : const Text('Missing Selection'),
              content: (newCountry.length == 0)
                  ? const Text('Add a country')
                  : const Text(
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
  Future<void> _addCountryField() async {
    _numberPlaces = List.from(_numberPlaces)
      ..add(
        Dismissible(
          key: ValueKey(_numberPlaces),
          child: ListTile(
            title: Places(_countryPicker, _cityPicker, null, null),
            trailing: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.rotate(
                  angle: 90 * math.pi / 180,
                  child: Icon(
                    Icons.drag_handle,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    setState(() {
      _placesIndex++;
    });
    Timer(Duration(milliseconds: 50), () => _scrollToBottom());
  }

  //TODO below HELPERS

  //function to scroll to bottom of page
  void _scrollToBottom() {
    _listViewController.animateTo(
      _listViewController.position.maxScrollExtent + 50,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  //Skip button feature if user doesn't know any cities to stop.
  void _skipButton() async {
    await Provider.of<Country>(context, listen: false).removeAllCountries();
    Navigator.of(context)
        .pushNamed(AddTripGroupInviteScreen.routeName, arguments: tripValues);
  }

  //Pop back a page and clear out provider
  void _backPage() async {
    await Provider.of<Country>(context, listen: false).removeAllCountries();
    Navigator.of(context).pop();
  }

  //TODO HELPERS ABOVE

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    tripValues = ModalRoute.of(context).settings.arguments;
    final newCountry = Provider.of<Country>(context, listen: false).countries;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Countries',
          style: TextStyle(
            color: Colors.black,
          ),
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
            width: screenWidth,
            decoration: BoxDecoration(
                // color: Theme.of(context).accentColor,
                ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 200.0,
                      bottom: 12.0,
                      top: 5.0,
                    ),
                    child: Text(
                      'Add Countries',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    height: screenHeight * 0.50,
                    margin: EdgeInsets.only(
                      bottom: 25,
                      top: 15,
                    ),
                    child: ListView.builder(
                      itemCount: _numberPlaces.length,
                      controller: _listViewController,
                      itemBuilder: (BuildContext ctx, int index) {
                        return Dismissible(
                          key: ValueKey(_numberPlaces),
                          child: ListTile(
                            title: Places(
                              _countryPicker,
                              _cityPicker,
                              newCountry.length <= index
                                  ? null
                                  : (newCountry[index].country == ''
                                      ? null
                                      : newCountry[index].country),
                              null,
                            ),
                            trailing: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Transform.rotate(
                                  angle: 90 * math.pi / 180,
                                  child: Icon(
                                    Icons.drag_handle,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          background: Container(
                            color: Colors.red,
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (direction) {
                            setState(() {
                              _numberPlaces = List.from(_numberPlaces)
                                ..removeAt(index);
                              _placesIndex--;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    width: screenWidth * 0.85,
                    child: FlatButton(
                      child: Text(
                        'Add Country',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      onPressed: () => _addCountryField(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                      color: Theme.of(context).buttonColor,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    width: screenWidth * 0.85,
                    child: FlatButton(
                      child: Text(
                        _numberPlaces.length == 0 ? 'Skip' : 'Next',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      onPressed:
                          _numberPlaces.length == 0 ? _skipButton : _addCountry,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                      color: Theme.of(context).buttonColor,
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
