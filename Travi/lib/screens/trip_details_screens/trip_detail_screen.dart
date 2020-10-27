import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:groupy/widgets/notification_end_drawer.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../providers/trip_provider.dart';
import '../../providers/trips_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/notification_provider.dart';
import './edit_trip_screen.dart';
import './edit_lodgings_screen.dart';
import './add_or_edit_lodging_screen.dart';
import './edit_transportations_screen.dart';
import './add_or_edit_transportation_screen.dart';
import './edit_activities_screen.dart';
import './add_or_edit_activity_screen.dart';
import './edit_group_screen.dart';
import './add_companion_screen.dart';
import './edit_restaurants_screen.dart';
import './add_or_edit_restaurant_screen.dart';
import './edit_flights_screen.dart';
import './add_or_edit_flight_screen.dart';
import '../timeline_screens/timeline_screen.dart';
import '../../widgets/launchers.dart';

//Destination Popup Menu Options
enum FilterDestinationOptions {
  EditDestinations,
  CountriesOnly,
  CitiesOnly,
  CountriesCities,
}

//Group Popup Menu Options
enum FilterGroupOptions {
  EditGroup,
}

//Flight Popup Menu Options
enum FilterFlightOptions {
  EditFlight,
}

//Restaurant Popup Menu Options
enum FilterRestaurantOptions {
  EditRestaurant,
}

//Lodging Popup Menu Options
enum FilterLodgingOptions {
  EditLodging,
  MarkComplete,
}

//Transportation Popup Menu Options
enum FilterTransportationOptions {
  EditTransporation,
  MarkComplete,
}

//Activity Popup Menu Options
enum FilterActivityOptions {
  EditActivity,
  MarkComplete,
}

class TripDetailsScreen extends StatefulWidget {
  static const routeName = '/trip-details';

  @override
  _TripDetailsScreenState createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  UserProvider currentLoggedInUser;
  List<NotificationProvider> notifications;
  String tripId;
  // TripProvider trip;
  TripProvider loadedTrip;
  double screenWidth = 0;
  double screenHeight = 0;
  bool _loadedTrip = false;

  //Bool Values for filtering by countries and/or cities
  bool _countriesOnly = false;
  bool _citiesOnly = true;

  //Bool Values for Marking complete
  bool _transportationsComplete = false;
  bool _lodgingsComplete = false;
  bool _activitiesComplete = false;

  User user = FirebaseAuth.instance.currentUser;

  //get the trip details as arguments from trip list screen
  @override
  void didChangeDependencies() {
    currentLoggedInUser =
        Provider.of<UserProvider>(context, listen: false).loggedInUser;
    notifications =
        Provider.of<NotificationProvider>(context, listen: false).notifications;
    if (!_loadedTrip) {
      tripId = ModalRoute.of(context).settings.arguments;
      _loadedTrip = true;
      loadedTrip = Provider.of<TripsProvider>(
        context,
      ).findById(tripId);
    }
    super.didChangeDependencies();
  }

  //Returns a text string of countries
  String listCountries() {
    String textString = '';
    for (int i = 0; i < loadedTrip.countries.length; i++) {
      textString = textString +
          '${loadedTrip.countries[i].country}${loadedTrip.countries.length > 1 && loadedTrip.countries.length != i + 1 ? ', ' : ''}';
    }
    return textString;
  }

  //reusable function to create a badding container with text, padding, and height
  Widget paddingText(String text, double topPadding, double fontSize,
      FontWeight weight, TextAlign alignment) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
        ),
        textAlign: alignment,
      ),
    );
  }

  //reusable flatbutton to with button text and functions on pressed.
  Widget flatButton(
      Icon icon, String buttonText, Function onPressed, BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      child: FlatButton(
        onPressed: onPressed,
        child: Row(
          children: <Widget>[
            icon,
            Padding(
              padding: EdgeInsets.only(
                right: 3.5,
              ),
            ),
            Text(
              buttonText,
              style: TextStyle(
                color: Theme.of(ctx).secondaryHeaderColor,
              ),
            ),
          ],
        ),
        color: Theme.of(ctx).buttonColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
      ),
    );
  }

  //Returns widget for creating avatar for group
  Widget groupAvatar(List<UserProvider> group) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: group.length,
      itemBuilder: (ctx, index) {
        if (group[index].invitationStatus == 'Accepted') {
          return Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              bottom: 10,
            ),
            child: Column(
              children: [
                group[index].profilePicUrl.isEmpty
                    ? CircleAvatar(
                        radius: 30,
                        child: Icon(
                          Icons.person,
                        ),
                      )
                    : ClipOval(
                        child: Image.network(
                          group[index].profilePicUrl,
                          fit: BoxFit.cover,
                          height: 60,
                          width: 60,
                        ),
                      ),
                Spacer(),
                Text('${group[index].firstName} ${group[index].lastName[0]}.'),
              ],
            ),
          );
        } else if (group[index].invitationStatus == 'pending') {
          return Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              bottom: 10,
            ),
            child: Column(
              children: [
                group[index].profilePicUrl.isEmpty
                    ? CircleAvatar(
                        radius: 30,
                        child: Icon(
                          Icons.person,
                        ),
                      )
                    : ClipOval(
                        child: Image.network(
                          group[index].profilePicUrl,
                          fit: BoxFit.cover,
                          height: 60,
                          width: 60,
                          color: Color.fromRGBO(255, 255, 255, 0.5),
                          colorBlendMode: BlendMode.modulate,
                        ),
                      ),
                Spacer(),
                Text('Pending...'),
              ],
            ),
          );
        }
        return null;
      },
    );
  }

  //Returns listtile for flight or transportation information
  Widget flightOrTransportationTile(String type) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: type == 'Flight'
          ? loadedTrip.flights.length
          : type == 'Transportation' ? loadedTrip.transportations.length : 0,
      itemBuilder: (BuildContext ctx, int index) {
        return Container(
          height: screenHeight,
          width: screenWidth,
          child: Container(
            width: screenWidth * 0.75,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                type == 'Flight'
                    ? Text(
                        loadedTrip.flights[index].airline,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Text(
                        loadedTrip.transportations[index].company,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                type == 'Flight'
                    ? Text(
                        loadedTrip.flights[index].flightNumber,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      )
                    : Text(''),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 18.0,
                      ),
                      child: type == 'Flight'
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                    loadedTrip.flights[index].departureAirport),
                                Text(
                                    '${DateFormat.yMd().format(loadedTrip.flights[index].departureDateTime)}'),
                                Text(
                                    '${DateFormat.jm().format(loadedTrip.flights[index].departureDateTime)}'),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(loadedTrip.transportations[index].company),
                                Text(
                                    '${DateFormat.yMd().format(loadedTrip.transportations[index].startingDateTime)}'),
                                Text(
                                    '${DateFormat.jm().format(loadedTrip.transportations[index].startingDateTime)}'),
                              ],
                            ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        height: 1.0,
                        width: screenWidth * 0.11,
                        color: Colors.black,
                      ),
                    ),
                    Transform.rotate(
                      angle: type == 'Flight' ? 90 * math.pi / 180 : 0,
                      child: Icon(
                        type == 'Flight'
                            ? Icons.airplanemode_active
                            : type == 'Transportation'
                                ? loadedTrip.transportations[index]
                                            .transportationType ==
                                        'train'
                                    ? Icons.train
                                    : loadedTrip.transportations[index]
                                                .transportationType ==
                                            'boat'
                                        ? Icons.directions_boat
                                        : loadedTrip.transportations[index]
                                                    .transportationType ==
                                                'carRental'
                                            ? Icons.directions_car
                                            : Icons.local_taxi
                                : Icons.device_unknown,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        height: 1.0,
                        width: screenWidth * 0.11,
                        color: Colors.black,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 18.0,
                      ),
                      child: type == 'Flight'
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(loadedTrip.flights[index].arrivalAirport),
                                Text(
                                    '${DateFormat.yMd().format(loadedTrip.flights[index].arrivalDateTime)}'),
                                Text(
                                    '${DateFormat.jm().format(loadedTrip.flights[index].arrivalDateTime)}'),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(loadedTrip.transportations[index].company),
                                Text(
                                    '${DateFormat.yMd().format(loadedTrip.transportations[index].endingDateTime)}'),
                                Text(
                                    '${DateFormat.jm().format(loadedTrip.transportations[index].endingDateTime)}'),
                              ],
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //Returns Containers for Destination, Travel, Lodging, and Activities
  Widget cardWidget(String cardTitle) {
    var _totalCities = 0;
    var _totalDestinations = 0;
    for (int i = 0; i < loadedTrip.countries.length; i++) {
      _totalCities = _totalCities + loadedTrip.countries[i].cities.length;
    }
    _totalDestinations = _totalCities + loadedTrip.countries.length;
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cardTitle == 'Destinations'
            ? ((_countriesOnly && !_citiesOnly)
                ? loadedTrip.countries.length
                : ((!_countriesOnly && _citiesOnly)
                    ? _totalCities
                    : ((!_countriesOnly && !_citiesOnly)
                        ? _totalDestinations
                        : 0)))
            : ((cardTitle == 'Lodgings')
                ? loadedTrip.lodgings.length
                : ((cardTitle == 'Transportations')
                    ? loadedTrip.transportations.length
                    : ((cardTitle == 'Activities')
                        ? loadedTrip.activities.length
                        : ((cardTitle == 'Restaurants')
                            ? loadedTrip.restaurants.length
                            : 0)))),
        itemBuilder: (ctx, index) {
          return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 0.0,
                horizontal: 0.0,
              ),
              child: cardTitle == 'Destinations'
                  ? ((_countriesOnly && !_citiesOnly)
                      ? destinationCardImageAndInfo(index, 'Country')
                      : ((!_countriesOnly && _citiesOnly)
                          ? destinationCardImageAndInfo(index, 'City')
                          : 0))
                  : ((cardTitle == 'Lodgings')
                      ? cardImageAndInfo(index, 'Lodgings')
                      : ((cardTitle == 'Activities')
                          ? cardImageAndInfo(index, 'Activities')
                          : ((cardTitle == 'Restaurants')
                              ? cardImageAndInfo(index, 'Restaurants')
                              : 0))));
        });
  }

  //Returns a widget that will display image and name of destiantion, lodging,
  //activity, transportation.
  Widget cardImageAndInfo(int index, String cardType) {
    //Create a temp list of all cities to display
    List<String> allCities = [];
    for (int i = 0; i < loadedTrip.countries.length; i++) {
      for (int j = 0; j < loadedTrip.countries[i].cities.length; j++) {
        allCities.add(loadedTrip.countries[i].cities[j].city);
      }
    }
    return Container(
      width: screenWidth,
      height: screenHeight,
      padding: EdgeInsets.only(
        left: 28,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                child: cardImage(
                  cardType,
                  index,
                  allCities,
                  screenHeight,
                  screenWidth,
                ),
                //TODO THE BELOW IMAGE CHARGES... NEED TO FIX SLOW LOADING....
                //cardType == 'Country ? PlacesImages(foundTrip.countries[0].id) : cardType == 'City' ? PlacesImages(foundTrip.countries[0].id) : null,
              ),
              Container(
                width: screenWidth * 0.625,
                height: screenHeight * 0.125,
                padding: const EdgeInsets.only(
                  left: 15,
                ),
                child: cardTextInfo(cardType, index),
              ),
            ],
          ),
          Container(
            width: screenWidth * 0.75,
            padding: const EdgeInsets.only(
              top: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  child: Column(
                    children: [
                      Icon(Icons.phone),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 10,
                        ),
                      ),
                      const Text(
                        'Call',
                      ),
                    ],
                  ),
                  onTap: () {
                    cardType == 'Lodgings'
                        ? Launchers().phoneLauncher(
                            'tel:${loadedTrip.lodgings[index].phoneNumber}')
                        : cardType == 'Activities'
                            ? Launchers().phoneLauncher(
                                'tel:${loadedTrip.activities[index].phoneNumber}')
                            : cardType == 'Restaurants'
                                ? Launchers().phoneLauncher(
                                    'tel:${loadedTrip.restaurants[index].phoneNumber}')
                                // ignore: unnecessary_statements
                                : () {};
                  },
                ),
                GestureDetector(
                  child: Column(
                    children: [
                      Icon(
                        Icons.directions,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 10,
                        ),
                      ),
                      const Text(
                        'Directions',
                      ),
                    ],
                  ),
                  onTap: () async {
                    List<AvailableMap> availableMaps =
                        await Launchers().getAvailableMaps();
                    String title;
                    double latitude;
                    double longitude;

                    if (cardType == 'Lodgings') {
                      title = loadedTrip.lodgings[index].name;
                      latitude = loadedTrip.lodgings[index].latitude;
                      longitude = loadedTrip.lodgings[index].longitude;
                    } else if (cardType == 'Activities') {
                      title = loadedTrip.activities[index].title;
                      latitude = loadedTrip.activities[index].latitude;
                      longitude = loadedTrip.activities[index].longitude;
                    } else if (cardType == 'Restaurants') {
                      title = loadedTrip.restaurants[index].name;
                      latitude = loadedTrip.restaurants[index].latitude;
                      longitude = loadedTrip.restaurants[index].longitude;
                    }

                    return showModalBottomSheet(
                      context: context,
                      builder: (BuildContext ctx) {
                        return SafeArea(
                          child: SingleChildScrollView(
                            child: Container(
                              child: Wrap(
                                children: <Widget>[
                                  for (var map in availableMaps)
                                    ListTile(
                                      onTap: () => map.showMarker(
                                        coords: Coords(latitude, longitude),
                                        title: title,
                                      ),
                                      title: Text(map.mapName),
                                      leading: Image(
                                        image: map.icon,
                                        height: 30.0,
                                        width: 30.0,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                GestureDetector(
                  child: Column(
                    children: [
                      Icon(
                        Icons.open_in_browser,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 10,
                        ),
                      ),
                      const Text('Website'),
                    ],
                  ),
                  onTap: () {
                    cardType == 'Lodgings'
                        ? Launchers()
                            .urlLauncher(loadedTrip.lodgings[index].website)
                        : cardType == 'Activities'
                            ? Launchers().urlLauncher(
                                loadedTrip.activities[index].website)
                            : cardType == 'Restaurants'
                                ? Launchers().urlLauncher(
                                    loadedTrip.restaurants[index].website)
                                // ignore: unnecessary_statements
                                : () {};
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget cardTextInfo(String cardType, int index) {
    return cardType == 'Lodgings'
        ? Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loadedTrip.lodgings[index].name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${DateFormat.yMd().format(loadedTrip.lodgings[index].checkInDateTime)}',
              ),
              Text(
                '${DateFormat.jm().format(loadedTrip.lodgings[index].checkInDateTime)}',
              ),
            ],
          )
        : cardType == 'Activities'
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loadedTrip.activities[index].title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${DateFormat.yMd().format(loadedTrip.activities[index].startingDateTime)}',
                  ),
                  Text(
                    '${DateFormat.jm().format(loadedTrip.activities[index].startingDateTime)}',
                  ),
                ],
              )
            : cardType == 'Restaurants'
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loadedTrip.restaurants[index].name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${DateFormat.yMd().format(loadedTrip.restaurants[index].startingDateTime)}',
                      ),
                      Text(
                        '${DateFormat.jm().format(loadedTrip.restaurants[index].startingDateTime)}',
                      ),
                    ],
                  )
                : Container();
  }

  //Returns a widget that will display image and name of destiantion, lodging,
  //activity, transportation.
  Widget destinationCardImageAndInfo(int index, String cardType) {
    //Create a temp list of all cities to display
    List<String> allCities = [];
    for (int i = 0; i < loadedTrip.countries.length; i++) {
      for (int j = 0; j < loadedTrip.countries[i].cities.length; j++) {
        allCities.add(loadedTrip.countries[i].cities[j].city);
      }
    }
    return Container(
      width: screenWidth,
      height: screenHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
            child: cardImage(
              cardType,
              index,
              allCities,
              screenHeight,
              screenWidth,
            ),
            //TODO THE BELOW IMAGE CHARGES... NEED TO FIX SLOW LOADING....
            //cardType == 'Country ? PlacesImages(foundTrip.countries[0].id) : cardType == 'City' ? PlacesImages(foundTrip.countries[0].id) : null,
          ),
        ],
      ),
    );
  }

  //Returns a flexible widget used for displaying
  //card info.
  Widget flexibleCardInfo(String text) {
    return Flexible(
      flex: 1,
      fit: FlexFit.tight,
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }

  //Displays the appropriate card image based on type of event
  Widget cardImage(
    String type,
    int index,
    List<String> allCities,
    double screenHeight,
    double screenWidth,
  ) {
    if (type == 'Country') {
      if (loadedTrip.countries[index].countryImageUrl != null) {
        return Container(
          alignment: Alignment.center,
          height: screenHeight * 0.225,
          width: screenWidth,
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Image.network(
                  loadedTrip.countries[index].countryImageUrl,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  loadedTrip.countries[index].country,
                ),
              )
            ],
          ),
        );
      } else {
        return Container(
          width: screenWidth * 0.5,
          height: screenHeight * 0.2,
          child: IconButton(
            icon: Icon(Icons.photo_camera),
            //TODO
            onPressed: () {},
          ),
          color: Colors.grey,
        );
      }
    } else if (type == 'City') {
      if (loadedTrip.countries[0].cities[0].cityImageUrl != null) {
        return Container(
          alignment: Alignment.center,
          height: screenHeight * 0.225,
          width: screenWidth,
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Image.network(
                  loadedTrip.countries[0].cities[0].cityImageUrl,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  loadedTrip.countries[0].cities[0].city,
                ),
              ),
            ],
          ),
        );
      } else {
        return Container(
          width: screenWidth * 0.5,
          height: screenHeight * 0.2,
          child: IconButton(
            icon: Icon(Icons.photo_camera),
            //TODO
            onPressed: () {},
          ),
          color: Colors.grey,
        );
      }
    } else if (type == 'Lodgings') {
      if (loadedTrip.lodgings[index].lodgingImageUrl != null) {
        return Image.network(
          loadedTrip.lodgings[index].lodgingImageUrl,
        );
      }
    } else if (type == 'Activities') {
      if (loadedTrip.activities[index].activityImageUrl != null) {
        return Image.network(
          loadedTrip.activities[index].activityImageUrl,
        );
      }
    } else if (type == 'Restaurants') {
      if (loadedTrip.restaurants[index].restaurantImageUrl != null) {
        return Image.network(
          loadedTrip.restaurants[index].restaurantImageUrl,
        );
      }
    }
    return Container(
      width: screenWidth * 0.275,
      height: screenHeight * 0.125,
      child: IconButton(
        icon: Icon(Icons.photo_camera),
        //TODO
        onPressed: () {},
      ),
      color: Colors.grey,
    );
  }

  //Container with horizontal scrollable cards
  Widget cardScroller(
    String cardTitle,
    double avatarMultiplier,
    Widget widget,
    BuildContext ctx,
  ) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: paddingText(
                  cardTitle,
                  0,
                  18,
                  FontWeight.bold,
                  TextAlign.left,
                ),
              ),
              Row(
                children: [
                  Container(
                    height: screenHeight * 0.065,
                    child: cardTitle == 'Destinations'
                        ? _destinationMenuButton(cardTitle)
                        : (cardTitle == 'Group'
                            ? _groupMenuButton(loadedTrip)
                            : (cardTitle == 'Flights'
                                ? _flightMenuButton(loadedTrip)
                                : (cardTitle == 'Lodging'
                                    ? _lodgingMenuButton(loadedTrip)
                                    : (cardTitle == 'Transportation'
                                        ? _transportationMenuButton(loadedTrip)
                                        : (cardTitle == 'Activities'
                                            ? _activitiesMenuButton(loadedTrip)
                                            : (cardTitle == 'Restaurants'
                                                ? _restaurantsMenuButton(
                                                    loadedTrip)
                                                : null)))))),
                  ),
                ],
              ),
            ],
          ),
          Container(
            height: cardTitle == 'Group' || cardTitle == 'Flights'
                ? screenHeight * 0.185 * avatarMultiplier
                : screenHeight * 0.25 * avatarMultiplier,
            child: widget,
          ),
        ],
      ),
    );
  }

  Widget _displayMessage(String sectionTitle) {
    return IconButton(
      icon: Icon(
        Icons.message,
      ),
      onPressed: () {},
    );
  }

  //Menu button built based on section
  Widget _destinationMenuButton(String sectionTitle) {
    return PopupMenuButton(
      onSelected: (FilterDestinationOptions _filterSelected) {
        if (_filterSelected == FilterDestinationOptions.EditDestinations) {
          //Navigate to add/remove destinations -> Countries then Cities
        } else if (_filterSelected == FilterDestinationOptions.CountriesOnly) {
          setState(() {
            _countriesOnly = true;
            _citiesOnly = false;
          });
        } else if (_filterSelected == FilterDestinationOptions.CitiesOnly) {
          setState(() {
            _countriesOnly = false;
            _citiesOnly = true;
          });
        }
      },
      icon: Icon(
        Icons.more_vert,
      ),
      //Menu Items to filter by destinations or edit them
      itemBuilder: (BuildContext ctx) => [
        PopupMenuItem(
          child: Text('Edit Destinations'),
          value: FilterDestinationOptions.EditDestinations,
        ),
        PopupMenuItem(
          child: Text('Show Countries Only'),
          value: FilterDestinationOptions.CountriesOnly,
        ),
        PopupMenuItem(
          child: Text('Show Cities Only'),
          value: FilterDestinationOptions.CitiesOnly,
        ),
      ],
    );
  }

  //Menu button for adding group members
  Widget _groupMenuButton(TripProvider loadedTrip) {
    return PopupMenuButton(
      onSelected: (FilterGroupOptions selectedOption) {
        if (selectedOption == FilterGroupOptions.EditGroup) {
          Navigator.of(context).pushNamed(
            EditGroupScreen.routeName,
            arguments: {'loadedTrip': loadedTrip},
          );
        }
      },
      icon: Icon(
        Icons.more_vert,
      ),
      itemBuilder: (BuildContext ctx) => [
        PopupMenuItem(
          child: Text('Edit Group'),
          value: FilterGroupOptions.EditGroup,
        )
      ],
    );
  }

  //Menu button for adding group members
  Widget _flightMenuButton(TripProvider loadedTrip) {
    return PopupMenuButton(
      onSelected: (FilterFlightOptions selectedOption) {
        if (selectedOption == FilterFlightOptions.EditFlight) {
          Navigator.of(context).pushNamed(
            EditFlightsScreen.routeName,
            arguments: {'loadedTrip': loadedTrip},
          );
        }
      },
      icon: Icon(
        Icons.more_vert,
      ),
      itemBuilder: (BuildContext ctx) => [
        PopupMenuItem(
          child: Text('Edit Flight'),
          value: FilterFlightOptions.EditFlight,
        )
      ],
    );
  }

  //Menu button for adding group members
  Widget _lodgingMenuButton(TripProvider loadedTrip) {
    return PopupMenuButton(
      onSelected: (FilterLodgingOptions _selectedOption) {
        if (_selectedOption == FilterLodgingOptions.EditLodging) {
          Navigator.of(context).pushNamed(
            EditLodgingsScreen.routeName,
            arguments: {'loadedTrip': loadedTrip},
          );
        } else if (_selectedOption == FilterLodgingOptions.MarkComplete) {
          setState(() {
            _lodgingsComplete = !_lodgingsComplete;
            updateTask('lodgingsComplete', _lodgingsComplete);
          });
        }
      },
      icon: Icon(
        Icons.more_vert,
      ),
      itemBuilder: (BuildContext ctx) => [
        PopupMenuItem(
          child: Text('Edit Lodgings'),
          value: FilterLodgingOptions.EditLodging,
        ),
        PopupMenuItem(
          child: _lodgingsComplete
              ? Text('Mark Incomplete')
              : Text('Mark Complete'),
          value: FilterLodgingOptions.MarkComplete,
        ),
      ],
    );
  }

  //Menu button for adding group members
  Widget _transportationMenuButton(TripProvider loadedTrip) {
    return PopupMenuButton(
      onSelected: (FilterTransportationOptions _selectedOption) {
        if (_selectedOption == FilterTransportationOptions.EditTransporation) {
          Navigator.of(context).pushNamed(
            EditTransportationsScreen.routeName,
            arguments: {'loadedTrip': loadedTrip},
          );
        } else if (_selectedOption ==
            FilterTransportationOptions.MarkComplete) {
          setState(() {
            _transportationsComplete = !_transportationsComplete;
            updateTask('transportationsComplete', _transportationsComplete);
          });
        }
      },
      icon: Icon(
        Icons.more_vert,
      ),
      itemBuilder: (BuildContext ctx) => [
        PopupMenuItem(
          child: Text('Edit Transportations'),
          value: FilterTransportationOptions.EditTransporation,
        ),
        PopupMenuItem(
          child: _transportationsComplete
              ? Text('Mark Incomplete')
              : Text('Mark Complete'),
          value: FilterTransportationOptions.MarkComplete,
        ),
      ],
    );
  }

  //Menu button for adding group members
  Widget _activitiesMenuButton(TripProvider loadedTrip) {
    return PopupMenuButton(
      onSelected: (FilterActivityOptions selectedOption) {
        if (selectedOption == FilterActivityOptions.EditActivity) {
          Navigator.of(context).pushNamed(
            EditActivitiesScreen.routeName,
            arguments: {'loadedTrip': loadedTrip},
          );
        } else if (selectedOption == FilterActivityOptions.MarkComplete) {
          setState(() {
            _activitiesComplete = !_activitiesComplete;
            updateTask('activitiesComplete', _activitiesComplete);
          });
        }
      },
      icon: Icon(
        Icons.more_vert,
      ),
      itemBuilder: (BuildContext ctx) => [
        PopupMenuItem(
          child: Text('Edit Activities'),
          value: FilterActivityOptions.EditActivity,
        ),
        PopupMenuItem(
          child: _activitiesComplete
              ? Text('Mark Incomplete')
              : Text('Mark Complete'),
          value: FilterActivityOptions.MarkComplete,
        ),
      ],
    );
  }

  //Menu button for adding group members
  Widget _restaurantsMenuButton(TripProvider loadedTrip) {
    return PopupMenuButton(
      onSelected: (FilterActivityOptions selectedOption) {
        if (selectedOption == FilterActivityOptions.EditActivity) {
          Navigator.of(context).pushNamed(
            EditRestaurantsScreen.routeName,
            arguments: {'loadedTrip': loadedTrip},
          );
        }
      },
      icon: Icon(
        Icons.more_vert,
      ),
      itemBuilder: (BuildContext ctx) => [
        PopupMenuItem(
          child: Text('Edit Restaurants'),
          value: FilterActivityOptions.EditActivity,
        ),
      ],
    );
  }

  //Method to update completedItem on Firestore
  Future<void> updateTask(String taskCompleted, bool mark) async {
    try {
      await Provider.of<TripsProvider>(context, listen: false)
          .updateTripCompleted(tripId, taskCompleted, mark, user);
    } catch (error) {
      throw error;
    }
  }

  //Navigate to timeline screen
  void _timeLine() async {
    Navigator.of(context).pushNamed(
      TimelineScreen.routeName,
      arguments: {
        'loadedTrip': loadedTrip,
      },
    );
  }

  //Displays a bottom modal sheet for user to add event to trip
  Future<Widget> showBottomModalAddTrip(BuildContext context) async {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: screenHeight * 0.9,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppBar(
                  title: Text(
                    'Add to trip',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  automaticallyImplyLeading: false,
                  iconTheme: new IconThemeData(
                    color: Colors.white,
                  ),
                  actions: [
                    SizedBox(),
                  ],
                ),
                ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Theme.of(context).secondaryHeaderColor,
                    size: screenHeight * .065,
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Companion',
                      style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  //NAVIGATION TO NEW SCREEN
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AddCompanionScreen.routeName,
                      arguments: {'loadedTrip': loadedTrip},
                    ).then((value) {
                      setState(() {
                        print('updated and popped');
                      });
                      Navigator.of(context).pop();
                    });
                  },
                ),
                Divider(
                  thickness: 2,
                ),
                ListTile(
                  leading: Icon(
                    Icons.place,
                    color: Theme.of(context).secondaryHeaderColor,
                    size: screenHeight * .065,
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Destination',
                      style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  //NAVIGATION TO NEW SCREEN
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                Divider(
                  thickness: 2,
                ),
                ListTile(
                  leading: Icon(
                    Icons.flight,
                    color: Theme.of(context).secondaryHeaderColor,
                    size: screenHeight * .065,
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Flight',
                      style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  //NAVIGATION TO NEW SCREEN
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AddOrEditFlightScreen.routeName,
                      arguments: {
                        'loadedTrip': loadedTrip,
                        'editIndex': -1,
                      },
                    ).then((value) {
                      setState(() {
                        print('updated and popped');
                      });
                      Navigator.of(context).pop();
                    });
                  },
                ),
                Divider(
                  thickness: 2,
                ),
                ListTile(
                  leading: Icon(
                    Icons.hotel,
                    color: Theme.of(context).secondaryHeaderColor,
                    size: screenHeight * .065,
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Lodging',
                      style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  //NAVIGATION TO NEW SCREEN
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AddOrEditLodgingScreen.routeName,
                      arguments: {
                        'loadedTrip': loadedTrip,
                        'editIndex': -1,
                      },
                    ).then((value) {
                      setState(() {
                        print('updated and popped');
                      });
                      Navigator.of(context).pop();
                    });
                  },
                ),
                Divider(
                  thickness: 2,
                ),
                ListTile(
                  leading: Icon(
                    Icons.local_activity,
                    color: Theme.of(context).secondaryHeaderColor,
                    size: screenHeight * .065,
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Activity',
                      style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  //NAVIGATION TO NEW SCREEN
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AddOrEditActivityScreen.routeName,
                      arguments: {
                        'loadedTrip': loadedTrip,
                        'editIndex': -1,
                      },
                    ).then((value) {
                      setState(() {
                        print('updated and popped');
                      });
                      Navigator.of(context).pop();
                    });
                  },
                ),
                Divider(
                  thickness: 2,
                ),
                ListTile(
                  leading: Icon(
                    Icons.restaurant,
                    color: Theme.of(context).secondaryHeaderColor,
                    size: screenHeight * .065,
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Restaurant',
                      style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  //NAVIGATION TO NEW SCREEN
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AddOrEditRestaurantScreen.routeName,
                      arguments: {
                        'loadedTrip': loadedTrip,
                        'editIndex': -1,
                      },
                    ).then((value) {
                      setState(() {
                        print('updated and popped');
                      });
                      Navigator.of(context).pop();
                    });
                  },
                ),
                Divider(
                  thickness: 2,
                ),
                ListTile(
                  leading: Icon(
                    Icons.tram,
                    color: Theme.of(context).secondaryHeaderColor,
                    size: screenHeight * .065,
                  ),
                  title: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Transportation',
                      style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  //NAVIGATION TO NEW SCREEN
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AddOrEditTransportationScreen.routeName,
                      arguments: {
                        'loadedTrip': loadedTrip,
                        'editIndex': -1,
                      },
                    ).then((value) {
                      setState(() {
                        print('updated and popped');
                      });
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    final tripId = ModalRoute.of(context).settings.arguments as String;
    // final tripId = routeArgs['id'];
    final loadedTrip = Provider.of<TripsProvider>(
      context,
    ).findById(tripId);
    setState(() {
      _activitiesComplete = loadedTrip.activitiesComplete;
      _lodgingsComplete = loadedTrip.lodgingsComplete;
      _transportationsComplete = loadedTrip.transportationsComplete;
    });
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          '${loadedTrip.title}',
          style: TextStyle(
            color: Theme.of(context).secondaryHeaderColor,
          ),
        ),
        iconTheme: new IconThemeData(
          color: Theme.of(context).secondaryHeaderColor,
        ),
        actions: <Widget>[
          Stack(
            fit: StackFit.loose,
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications,
                  size: 30,
                ),
                onPressed: () {
                  _scaffoldKey.currentState.openEndDrawer();
                  if (_scaffoldKey.currentState.isEndDrawerOpen) {
                    setState(() {
                      Provider.of<NotificationProvider>(context, listen: false)
                          .clearNotificationsList();
                    });
                  }
                },
              ),
              notifications
                          .where((notification) => notification.unread)
                          .length >
                      0
                  ? Container(
                      height: 25,
                      width: 25,
                      child: Card(
                        elevation: 5,
                        color: Colors.red,
                        child: Text(
                          '${notifications.where((notification) => notification.unread).length}',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: screenHeight * 0.25,
              alignment: Alignment.center,
              padding: EdgeInsets.only(
                top: screenHeight * 0.03,
                right: screenWidth * 0.03,
                left: screenWidth * 0.03,
              ),
              child: loadedTrip.tripImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                      child: Container(
                        child: IconButton(
                          icon: Icon(Icons.photo_camera),
                          //TODO
                          onPressed: () {},
                        ),
                        color: Colors.grey,
                        height: double.infinity,
                        width: double.infinity,
                      ),
                      //TODO THE BELOW IMAGE CHARGES... NEED TO FIX SLOW LOADING....
                      //PlacesImages(loadedTrip.countries[0].id),
                    )
                  : Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                          ),
                          child: Hero(
                            tag: loadedTrip.id,
                            child: Image.network(
                              'https://traveloregon.com/wp-content/uploads/2018/08/2018BendFall_oldmill.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            child: IconButton(
                              icon: Icon(Icons.photo_camera),
                              color: Colors.black,
                              //TODO
                              onPressed: () {},
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            paddingText(
              loadedTrip.title,
              8,
              19,
              FontWeight.bold,
              TextAlign.center,
            ),
            paddingText(
              listCountries(),
              6.5,
              17,
              FontWeight.bold,
              TextAlign.center,
            ),
            paddingText(
              '${DateFormat.yMMMd().format(loadedTrip.startDate)} - ${DateFormat.yMMMd().format(loadedTrip.endDate)}',
              6.5,
              17,
              FontWeight.bold,
              TextAlign.center,
            ),
            Container(
              width: screenWidth * 0.9,
              padding: EdgeInsets.symmetric(
                vertical: 8,
              ),
              child: paddingText(
                loadedTrip.description == null
                    ? 'Enter a descritpion'
                    : '${loadedTrip.description}',
                6.5,
                15,
                FontWeight.normal,
                TextAlign.left,
              ),
            ),
            Container(
              width: screenWidth * 0.9,
              child: FlatButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    EditTripScreen.routeName,
                    arguments: {'trip': loadedTrip, 'user': user},
                  );
                },
                child: Text(
                  'Edit Trip',
                  style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: screenHeight * 0.023,
                  ),
                ),
                color: Theme.of(context).buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 8,
              ),
            ),
            Divider(
              thickness: 10,
            ),
            loadedTrip.group.length > 0
                ? cardScroller(
                    'Group',
                    .65,
                    groupAvatar(loadedTrip.group),
                    context,
                  )
                : Container(),
            loadedTrip.group.length > 0
                ? Divider(
                    thickness: 10,
                  )
                : Container(),
            Container(
              height: screenHeight * 0.065,
              padding: EdgeInsets.symmetric(
                vertical: 7,
                horizontal: 7,
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  flatButton(
                    Icon(
                      Icons.timeline,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                    'Timeline',
                    //TODO
                    _timeLine,
                    context,
                  ),
                  flatButton(
                    Icon(
                      Icons.note,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                    'Notes',
                    //TODO
                    () {},
                    context,
                  ),
                  flatButton(
                    Icon(
                      Icons.lightbulb_outline,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                    'Tips',
                    //TODO
                    () {},
                    context,
                  ),
                  flatButton(
                    Icon(
                      Icons.photo,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                    'Photos',
                    //TODO
                    () {},
                    context,
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 10,
            ),
            loadedTrip.flights.length > 0
                ? cardScroller(
                    'Flights',
                    1,
                    flightOrTransportationTile(
                      'Flight',
                    ),
                    context,
                  )
                : Container(),
            loadedTrip.flights.length > 0
                ? Divider(
                    thickness: 10,
                  )
                : Container(),
            loadedTrip.countries.length > 0
                ? cardScroller(
                    'Destinations',
                    1,
                    cardWidget('Destinations'),
                    context,
                  )
                : Container(),
            loadedTrip.lodgings.length > 0 ||
                    loadedTrip.activities.length > 0 ||
                    loadedTrip.transportations.length > 0
                ? Divider(
                    thickness: 10,
                  )
                : Container(),
            loadedTrip.lodgings.length > 0
                ? cardScroller(
                    'Lodging',
                    1,
                    cardWidget('Lodgings'),
                    context,
                  )
                : Container(),
            loadedTrip.lodgings.length > 0
                ? Divider(
                    thickness: 10,
                  )
                : Container(),
            loadedTrip.activities.length > 0
                ? cardScroller(
                    'Activities',
                    1,
                    cardWidget('Activities'),
                    context,
                  )
                : Container(),
            loadedTrip.restaurants.length > 0
                ? Divider(
                    thickness: 10,
                  )
                : Container(),
            loadedTrip.restaurants.length > 0
                ? cardScroller(
                    'Restaurants',
                    1,
                    cardWidget('Restaurants'),
                    context,
                  )
                : Container(),
            loadedTrip.transportations.length > 0
                ? Divider(
                    thickness: 10,
                  )
                : Container(),
            loadedTrip.transportations.length > 0
                ? cardScroller(
                    'Transportation',
                    1,
                    flightOrTransportationTile(
                      'Transportation',
                    ),
                    context,
                  )
                : Container(),
            Padding(
              padding: EdgeInsets.only(bottom: 75),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.add,
          color: Theme.of(context).secondaryHeaderColor,
        ),
        onPressed: () {
          showBottomModalAddTrip(context);
        },
      ),
      endDrawerEnableOpenDragGesture: false,
      endDrawer: Container(
        width: screenWidth * 0.9,
        child: NotificationEndDrawer(currentLoggedInUser),
      ),
    );
  }
}
