import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/trip_provider.dart';
import '../providers/trips_provider.dart';
import '../screens/edit_trip_screen.dart';

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

  //get the trip details as arguments from trip list screen
  @override
  void didChangeDependencies() {
    if (!_loadedTrip) {
      tripId = ModalRoute.of(context).settings.arguments;
      _loadedTrip = true;
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

  //grey spacer between containers
  Widget spacer() {
    return Column(
      children: <Widget>[
        Container(
          height: 9,
          color: Colors.grey[400],
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 5,
          ),
        ),
      ],
    );
  }

  //Returns widget for creating avatar for group
  Widget groupAvatar() {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        itemBuilder: (ctx, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 30,
              child: Icon(Icons.person),
            ),
          );
        });
  }

  //Returns Containers for Destination, Travel, Lodging, and Activities
  Widget cardWidget(double screenHeight, double screenWidth, String cardTitle) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cardTitle.length,
        itemBuilder: (ctx, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 10,
            ),
            child: Container(
              height: screenHeight * 0.095,
              width: screenWidth * 0.45,
              alignment: Alignment.center,
              color: Colors.grey[200],
              child: Text(
                cardTitle[index],
                textAlign: TextAlign.center,
              ),
            ),
          );
        });
  }

  //Container with horizontal scrollable cards
  Widget cardScroller(String cardTitle, double screenHeight, double screenWidth,
      double avatarMultiplier, Widget widget, BuildContext ctx) {
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
                child: IconButton(
                  iconSize: screenHeight * 0.040,
                  icon: Icon(Icons.add),
                  color: Theme.of(ctx).primaryColor,
                  //TODO
                  onPressed: () {},
                ),
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final tripId = ModalRoute.of(context).settings.arguments as String;
    // final tripId = routeArgs['id'];
    final loadedTrip = Provider.of<TripsProvider>(
      context,
    ).findById(tripId);
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
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).secondaryHeaderColor,
              ),
              //TODO...... CREATE EDIT FUNCTION
              onPressed: () {})
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: screenHeight * 0.3,
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
            Padding(
              padding: EdgeInsets.only(top: 10),
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
                  Navigator.of(context).pushNamed(EditTripScreen.routeName,
                      arguments: loadedTrip.id);
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
            spacer(),
            cardScroller(
              'Group',
              screenHeight,
              screenWidth,
              .65,
              groupAvatar(),
              context,
            ),
            spacer(),
            Container(
              height: screenHeight * 0.05,
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
            Padding(
              padding: EdgeInsets.only(
                top: 8,
              ),
            ),
            spacer(),
            cardScroller(
              'Destinations',
              screenHeight,
              screenWidth,
              1,
              cardWidget(screenHeight, screenWidth, 'Destinations'),
              context,
            ),
            spacer(),
            cardScroller(
              'Lodging',
              screenHeight,
              screenWidth,
              1,
              cardWidget(screenHeight, screenWidth, 'Lodging'),
              context,
            ),
            spacer(),
            cardScroller(
              'Transportation',
              screenHeight,
              screenWidth,
              1,
              cardWidget(screenHeight, screenWidth, 'Transportation'),
              context,
            ),
            spacer(),
            cardScroller(
              'Activities',
              screenHeight,
              screenWidth,
              1,
              cardWidget(screenHeight, screenWidth, 'Activities'),
              context,
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
