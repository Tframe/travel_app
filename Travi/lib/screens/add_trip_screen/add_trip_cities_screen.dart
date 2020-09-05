import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/places.dart';
import '../../providers/trip_provider.dart';
import '../../providers/country_provider.dart';
import '../../providers/countries_provider.dart';

class AddTripCitiesScreen extends StatefulWidget {
  static const routeName = '/add-trip-cities-screen';

  @override
  _AddTripCitiesScreenState createState() => _AddTripCitiesScreenState();
}

class _AddTripCitiesScreenState extends State<AddTripCitiesScreen> {

  bool _countryPicker = false;
  var _numberPlaces = List<Container>();
  var _numberCountries = 0;
  var _countryIndex = 0;
  int _placesIndex = 1;

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

  void _addDestination() {
    final newCountry =
        Provider.of<Countries>(context, listen: false).countries;
    tripValues.countries = newCountry;
    print(tripValues.countries[0].country);
    print(tripValues.countries[1].country);
    print(tripValues.countries[2].country);

    // Navigator.of(context)
    //      .pushNamed(SignUpLocationScreen.routeName, arguments: tripValues);
  }

  //adds a field for the country
  void _addCountryField(String presetCountry) {
    _numberPlaces = List.from(_numberPlaces)
      ..add(
        Container(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Places(_countryPicker, presetCountry),
              IconButton(
                alignment: Alignment.center,
                icon: Icon(Icons.remove),
                onPressed: () => _removeCountryField(_placesIndex),
              ),
            ],
          ),
        ),
      );
    setState(() {
      ++_placesIndex;
    });
  }

  void _removeCountryField(int index) {
    setState(() {
      _numberPlaces = List.from(_numberPlaces)..removeAt(0);
      --_placesIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    tripValues = ModalRoute.of(context).settings.arguments;
    _numberCountries = tripValues.countries.length;
    for(int i = 0; i < _numberCountries; i++){
      print(tripValues.countries[i].country);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cities',
          style: TextStyle(
            color: Colors.black,
          ),
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
                  SizedBox(
                    height: screenHeight * 0.055,
                  ),
                  Text(
                    'Do you know which cities you want to see in ${tripValues.countries[_countryIndex].country} ?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.90,
                    alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: screenHeight * 0.55,
                            child: ListView(
                              children: _numberPlaces,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.only(top: 20),
                                width: screenWidth,
                                child: FlatButton(
                                  child: Text(
                                    'Add Another Country',
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                    ),
                                  ),
                                  onPressed: () => _addCountryField(''),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 30.0, vertical: 8.0),
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 20),
                                width: screenWidth,
                                child: FlatButton(
                                  child: Text(
                                    'Next',
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                    ),
                                  ),
                                  onPressed: _addDestination,
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
                        ],
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
