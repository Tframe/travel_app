import 'package:flutter/material.dart';
import 'package:groupy/screens/trip_details_screens/edit_lodgings_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../providers/trip_provider.dart';
import '../../providers/trips_provider.dart';
import '../../providers/user_provider.dart';
import './edit_trip_screen.dart';

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
  String tripId;
  // TripProvider trip;
  TripProvider loadedTrip;
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
    if (!_loadedTrip) {
      tripId = ModalRoute.of(context).settings.arguments;
      _loadedTrip = true;
      loadedTrip = Provider.of<TripsProvider>(
        context,
      ).findById(tripId);
    }
    super.didChangeDependencies();
  }

  String listCountries(TripProvider loadedTrip) {
    String textString = '';
    for (int i = 0; i < loadedTrip.countries.length; i++) {
      textString = textString +
          '${loadedTrip.countries[i].country}${loadedTrip.countries.length > 1 && loadedTrip.countries.length != i + 1 ? ', ' : ''}';
    }
    return textString;
  }

  //reusable function to create a badding container with text, padding, and height
  Widget paddingText(String text, double topPadding, double screenHeight,
      FontWeight weight, TextAlign alignment) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: topPadding),
      child: Text(
        text,
        style: TextStyle(
          fontSize: screenHeight,
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
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
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
                    : CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          group[index].profilePicUrl,
                        ),
                      ),
                Spacer(),
                Text('${group[index].firstName} ${group[index].lastName[0]}.'),
              ],
            ),
          );
        });
  }

  //Returns Containers for Destination, Travel, Lodging, and Activities
  Widget cardWidget(double screenHeight, double screenWidth, String cardTitle,
      TripProvider trip) {
    var _totalCities = 0;
    var _totalDestinations = 0;
    for (int i = 0; i < trip.countries.length; i++) {
      _totalCities = _totalCities + trip.countries[i].cities.length;
    }
    _totalDestinations = _totalCities + trip.countries.length;
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cardTitle == 'Destinations'
            ? ((_countriesOnly && !_citiesOnly)
                ? trip.countries.length
                : ((!_countriesOnly && _citiesOnly)
                    ? _totalCities
                    : ((!_countriesOnly && !_citiesOnly)
                        ? _totalDestinations
                        : (cardTitle == 'Lodgings'
                            ? trip.lodgings.length
                            : (cardTitle == 'Transportations'
                                ? trip.transportations.length
                                : (cardTitle == 'Activities'
                                    ? trip.activities.length
                                    : 0))))))
            : 0,
        itemBuilder: (ctx, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 10,
            ),
            child: cardTitle == 'Destinations'
                ? ((_countriesOnly && !_citiesOnly)
                    ? cardImage(trip, index, _totalDestinations, screenHeight,
                        screenWidth, 'Country')
                    : ((!_countriesOnly && _citiesOnly)
                        ? cardImage(trip, index, _totalDestinations,
                            screenHeight, screenWidth, 'City')
                        : (cardTitle == 'Lodgings'
                            ? Text('hi')
                            : (cardTitle == 'Transportations'
                                ? Text('hi')
                                : (cardTitle == 'Activities'
                                    ? Text('hi')
                                    : 0)))))
                : 0,
          );
        });
  }

  //Returns a widget that will display image and name of destiantion
  Widget cardImage(TripProvider trip, int index, int totalDestinations,
      double screenHeight, double screenWidth, String cardType) {
    //Create a temp list of all cities to display
    List<String> allCities = [];
    for (int i = 0; i < trip.countries.length; i++) {
      for (int j = 0; j < trip.countries[i].cities.length; j++) {
        allCities.add(trip.countries[i].cities[j].city);
      }
    }
    return Container(
      width: screenWidth * 0.4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
              child: Container(
                width: screenWidth * 0.4,
                height: screenHeight * 0.105,
                child: IconButton(
                  icon: Icon(Icons.photo_camera),
                  //TODO
                  onPressed: () {},
                ),
                color: Colors.grey,
              ),
              //TODO THE BELOW IMAGE CHARGES... NEED TO FIX SLOW LOADING....
              //cardType == 'Country ? PlacesImages(foundTrip.countries[0].id) : cardType == 'City' ? PlacesImages(foundTrip.countries[0].id) : null,
            ),
          ),
          if (cardType == 'Country')
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Text(
                trip.countries[index].country,
                textAlign: TextAlign.center,
              ),
            ),
          if (cardType == 'City')
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Text(
                allCities[index],
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  //Container with horizontal scrollable cards
  Widget cardScroller(
      String cardTitle,
      double screenHeight,
      double screenWidth,
      double avatarMultiplier,
      Widget widget,
      BuildContext ctx,
      TripProvider loadedTrip) {
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
                  5,
                  screenHeight * 0.025,
                  FontWeight.bold,
                  TextAlign.left,
                ),
              ),
              Container(
                height: screenHeight * 0.05,
                child: cardTitle == 'Destinations'
                    ? _destinationMenuButton(cardTitle)
                    : (cardTitle == 'Group'
                        ? _groupMenuButton(loadedTrip)
                        : (cardTitle == 'Lodging'
                            ? _lodgingMenuButton(loadedTrip)
                            : (cardTitle == 'Transportation'
                                ? _transportationMenuButton(loadedTrip)
                                : (cardTitle == 'Activities'
                                    ? _activitiesMenuButton(loadedTrip)
                                    : null)))),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 8),
          ),
          Container(
            height: screenHeight * 0.175 * avatarMultiplier,
            child: widget,
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
          ),
        ],
      ),
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
          //Navigator to add or remove companions
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
  Widget _lodgingMenuButton(TripProvider loadedTrip) {
    return PopupMenuButton(
      onSelected: (FilterLodgingOptions _selectedOption) {
        if (_selectedOption == FilterLodgingOptions.EditLodging) {
          //Navigator to add or remove lodgings
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
          //Navigator to add or remove transportations
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
          //Navigator to add or remove activities
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

  //Method to update completedItem on Firestore
  Future<void> updateTask(String taskCompleted, bool mark) async {
    try {
      await Provider.of<TripsProvider>(context, listen: false)
          .updateTripCompleted(tripId, taskCompleted, mark, user);
    } catch (error) {
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
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
        // actions: <Widget>[
        //   IconButton(
        //       icon: Icon(
        //         Icons.edit,
        //         color: Theme.of(context).secondaryHeaderColor,
        //       ),
        //       //TODO...... CREATE EDIT FUNCTION
        //       onPressed: () {})
        // ],
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
              child: loadedTrip.image == null
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
                              loadedTrip.image,
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
              screenHeight * 0.03,
              FontWeight.bold,
              TextAlign.center,
            ),
            paddingText(
              listCountries(loadedTrip),
              6.5,
              screenHeight * 0.025,
              FontWeight.bold,
              TextAlign.center,
            ),
            paddingText(
              '${DateFormat.yMMMd().format(loadedTrip.startDate)} - ${DateFormat.yMMMd().format(loadedTrip.endDate)}',
              6.5,
              screenHeight * 0.025,
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
                screenHeight * 0.023,
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
            cardScroller(
              'Group',
              screenHeight,
              screenWidth,
              .65,
              groupAvatar(loadedTrip.group),
              context,
              loadedTrip,
            ),
            Divider(
              thickness: 10,
            ),
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
                    () {},
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
            cardScroller(
              'Destinations',
              screenHeight,
              screenWidth,
              1,
              cardWidget(screenHeight, screenWidth, 'Destinations', loadedTrip),
              context,
              loadedTrip,
            ),
            Divider(
              thickness: 10,
            ),
            cardScroller(
              'Lodging',
              screenHeight,
              screenWidth,
              1,
              cardWidget(screenHeight, screenWidth, 'Lodging', loadedTrip),
              context,
              loadedTrip,
            ),
            Divider(
              thickness: 10,
            ),
            cardScroller(
              'Transportation',
              screenHeight,
              screenWidth,
              1,
              cardWidget(
                  screenHeight, screenWidth, 'Transportation', loadedTrip),
              context,
              loadedTrip,
            ),
            Divider(
              thickness: 10,
            ),
            cardScroller(
              'Activities',
              screenHeight,
              screenWidth,
              1,
              cardWidget(screenHeight, screenWidth, 'Activities', loadedTrip),
              context,
              loadedTrip,
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 12),
            ),
          ],
        ),
      ),
    );
  }
}
