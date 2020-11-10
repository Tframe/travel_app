import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../providers/trip_provider.dart';
import '../providers/country_provider.dart';
import '../providers/city_provider.dart';
import '../screens/trip_details_screens/trip_detail_screen.dart';

class CurrentTripItem extends StatefulWidget {
  @override
  _CurrentTripItemState createState() => _CurrentTripItemState();
}

class _CurrentTripItemState extends State<CurrentTripItem> {
  UserProvider user;
  String userId;
  TripProvider foundTrip;
  List<Country> countryList;
  bool _isInit = true;
  bool _isLoading = false;

  Future<void> getCitiesData() async {
    //for each country get list of cities
    for (int i = 0; i < countryList.length; i++) {
      await Provider.of<City>(context, listen: false).fetchAndSetCities(
        foundTrip.organizerId,
        foundTrip.id,
        countryList[i].id,
      );
      List<City> cityList = Provider.of<City>(context, listen: false).cities;
      setState(() {
        countryList[i].cities = cityList;
        _isLoading = false;
      });
    }
  }

  Future<void> getCountryData() async {
    await Provider.of<Country>(context, listen: false).fetchAndSetCountries(
      foundTrip.organizerId,
      foundTrip.id,
    );

    countryList = Provider.of<Country>(context, listen: false).countries;
    await getCitiesData();
    setState(() {
      foundTrip.countries = countryList;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    setState(() {
      _isLoading = true;
    });
    if (_isInit) {
      user = Provider.of<UserProvider>(context, listen: false).loggedInUser;
      userId = user.id;
      foundTrip = Provider.of<TripProvider>(context, listen: false);
      getCountryData();
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    void selectTrip(BuildContext ctx) {
      Navigator.of(ctx).pushNamed(
        TripDetailsScreen.routeName,
        arguments: foundTrip.id,
      );
    }

    List<Widget> listCountries() {
      List<Widget> textList = [];
      for (int i = 0; i < foundTrip.countries.length; i++) {
        textList.add(
          Text(
            '${foundTrip.countries[i].country}${foundTrip.countries.length > 1 && foundTrip.countries.length != i + 1 ? ', ' : ''}',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Theme.of(context).secondaryHeaderColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
      return textList;
    }

    return _isLoading
        ? CircularProgressIndicator()
        : Column(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                //Create a card that will display trip data
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 5,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: InkWell(
                      //navigate to trip detail screen
                      onTap: () => selectTrip(context),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: screenHeight * 0.22,
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: foundTrip.tripImageUrl == null ||
                                    foundTrip.tripImageUrl == ''
                                ? ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8.0),
                                      topRight: Radius.circular(8.0),
                                    ),

                                    child: Container(
                                      color: Colors.grey,
                                      child: IconButton(
                                        icon: Icon(Icons.photo_camera),
                                        //TODO
                                        onPressed: () {},
                                      ),
                                      height: double.infinity,
                                      width: double.infinity,
                                    ),
                                    //TODO THE BELOW IMAGE CHARGES... NEED TO FIX SLOW LOADING....
                                    //PlacesImages(foundTrip.countries[0].id),
                                  )
                                : (foundTrip.countries[0].id != ''
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8.0),
                                          topRight: Radius.circular(8.0),
                                        ),
                                        child: Hero(
                                          tag: foundTrip.id,
                                          child: Image.network(
                                            foundTrip.tripImageUrl,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        child: IconButton(
                                          icon: Icon(Icons.photo_camera),
                                          //TODO
                                          onPressed: () {},
                                        ),
                                        color: Colors.grey,
                                        height: double.infinity,
                                        width: double.infinity,
                                      )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 10.0,
                            ),
                            child: Container(
                              padding: EdgeInsets.only(left: screenWidth * .02),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(bottom: 5),
                                        width: screenWidth * 0.85,
                                        child: Text(
                                          '${foundTrip.title}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(bottom: 2.5),
                                        width: screenWidth * 0.85,
                                        child: Row(
                                          children: listCountries(),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(bottom: 2.5),
                                        width: screenWidth * 0.85,
                                        child: Text(
                                          '${DateFormat.yMMMd().format(foundTrip.startDate)} - ${' ' + DateFormat.yMMMd().format(foundTrip.endDate)}',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.timer,
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                          ),
                                          Text(
                                            'Days Left: ${foundTrip.startDate.difference(DateTime.now()).inDays + 1}',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                              top: screenHeight * 0.015,
                              bottom: 10,
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(
                                    left: screenWidth * 0.015,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    children: <Widget>[
                                      Icon(
                                        foundTrip.transportationsComplete
                                            ? Icons.check_circle
                                            : Icons.check_circle_outline,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                      ),
                                      Text(
                                        'Transportation',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: <Widget>[
                                      Icon(
                                        foundTrip.lodgingsComplete
                                            ? Icons.check_circle
                                            : Icons.check_circle_outline,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                      ),
                                      Text(
                                        'Lodging',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                    right: screenWidth * 0.015,
                                  ),
                                  alignment: Alignment.centerRight,
                                  child: Column(
                                    children: <Widget>[
                                      Icon(
                                        foundTrip.activitiesComplete
                                            ? Icons.check_circle
                                            : Icons.check_circle_outline,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                      ),
                                      Text(
                                        'Activities',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Divider(
                color: Colors.grey[250],
                thickness: 10,
                height: 10,
              ),
            ],
          );
  }
}
