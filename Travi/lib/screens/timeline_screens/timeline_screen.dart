import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../providers/trip_provider.dart';
import '../../providers/lodging_provider.dart';
import '../../providers/flight_provider.dart';
import '../../providers/transportation_provider.dart';
import '../../providers/activity_provider.dart';
import '../../providers/restaurant_provider.dart';

class TimelineScreen extends StatefulWidget {
  static const routeName = '/timeline-screen';
  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  TripProvider loadedTrip;
  Lodging tempLodge;
  Flight tempFlight;
  Transportation tempTransportation;
  Activity tempActivity;
  Restaurant tempRestaurant;

  DateTime startChildDate = DateTime(1970, 1, 1);
  DateTime tempChildDate = DateTime(1970, 1, 1);
  String endChildText = '';

  var countryTrackerIndex = 0;
  var lodgingTrackerIndex = 0;
  var transportationTrackerIndex = 0;
  var flightTrackerIndex = 0;
  var activitiesTrackerIndex = 0;
  var restaruantsTrackerIndex = 0;

  var _totalEvents = 0;
  var _totalLodges = 0;
  var _totalTransportation = 0;
  var _totalFlights = 0;
  var _totalActivities = 0;
  var _totalRestaurants = 0;

  void getTotals() {
    for (int i = 0; i < loadedTrip.countries.length; i++) {
      for (int j = 0; j < loadedTrip.countries[i].cities.length; j++) {
        _totalLodges = loadedTrip.countries[i].cities[j].lodgings.length;
        _totalTransportation =
            loadedTrip.countries[i].cities[j].transportations.length;
        _totalActivities = loadedTrip.countries[i].cities[j].activities.length;
        _totalFlights = loadedTrip.countries[i].flights.length;
        _totalRestaurants =
            loadedTrip.countries[i].cities[j].restaurants.length;
        _totalEvents = _totalLodges +
            _totalTransportation +
            _totalActivities +
            _totalFlights +
            _totalRestaurants;
      }
    }
  }

  //Returns a string to indicate which event should be displayed next
  //in the timeline. Increments the event index to compare next dates.
  String getEarliestEvent() {
    DateTime earliestDate = loadedTrip.endDate.add(Duration(days: 1));
    String eventTracker = '';

    for (int i = 0; i < loadedTrip.countries.length; i++) {
      for (int j = 0; j < loadedTrip.countries[i].cities.length; j++) {
        if (loadedTrip.countries[i].flights.isNotEmpty) {
          if (loadedTrip.countries[i].flights.length > flightTrackerIndex) {
            earliestDate = loadedTrip
                .countries[i].flights[flightTrackerIndex].departureDateTime;
            eventTracker = 'Flight';
          }
        }
        if (loadedTrip.countries[i].cities[j].lodgings.isNotEmpty) {
          if (loadedTrip.countries[i].cities[j].lodgings.length >
              lodgingTrackerIndex) {
            if (earliestDate.isAfter(loadedTrip.countries[i].cities[j]
                .lodgings[lodgingTrackerIndex].checkInDateTime)) {
              earliestDate = loadedTrip.countries[i].cities[j]
                  .lodgings[lodgingTrackerIndex].checkInDateTime;
              eventTracker = 'Lodging';
            }
          }
        }
        if (loadedTrip.countries[i].cities[j].transportations.isNotEmpty) {
          if (loadedTrip.countries[i].cities[j].transportations.length >
              transportationTrackerIndex) {
            if (earliestDate.isAfter(loadedTrip
                .countries[i]
                .cities[j]
                .transportations[transportationTrackerIndex]
                .startingDateTime)) {
              earliestDate = loadedTrip.countries[i].cities[j]
                  .transportations[transportationTrackerIndex].startingDateTime;
              eventTracker = 'Transportation';
            }
          }
        }
        if (loadedTrip.countries[i].cities[j].activities.isNotEmpty) {
          if (loadedTrip.countries[i].cities[j].activities.length >
              activitiesTrackerIndex) {
            if (earliestDate.isAfter(loadedTrip.countries[i].cities[j]
                .activities[activitiesTrackerIndex].startingDateTime)) {
              earliestDate = loadedTrip.countries[i].cities[j]
                  .activities[activitiesTrackerIndex].startingDateTime;
              eventTracker = 'Activity';
            }
          }
        }
        if (loadedTrip.countries[i].cities[j].restaurants.isNotEmpty) {
          if (loadedTrip.countries[i].cities[j].restaurants.length >
              restaruantsTrackerIndex) {
            if (earliestDate.isAfter(loadedTrip.countries[i].cities[j]
                .restaurants[restaruantsTrackerIndex].startingDateTime)) {
              earliestDate = loadedTrip.countries[i].cities[j]
                  .restaurants[restaruantsTrackerIndex].startingDateTime;
              eventTracker = 'Restaurant';
            }
          }
        }
      }
    }

    if (eventTracker == 'Flight') {
      flightTrackerIndex++;
      return 'Flight';
    } else if (eventTracker == 'Transportation') {
      transportationTrackerIndex++;
      return 'Transportation';
    } else if (eventTracker == 'Lodging') {
      lodgingTrackerIndex++;
      return 'Lodging';
    } else if (eventTracker == 'Activity') {
      activitiesTrackerIndex++;
      return 'Activity';
    } else if (eventTracker == 'Restaurant') {
      restaruantsTrackerIndex++;
      return 'Restaurant';
    }
    return null;
  }

  void setStartChildDate(String eventTracker) {
    tempChildDate = startChildDate;
    for (int i = 0; i < loadedTrip.countries.length; i++) {
      for (int j = 0; j < loadedTrip.countries[i].cities.length; j++) {
        if (eventTracker == 'Flight') {
          startChildDate = loadedTrip
              .countries[i].flights[flightTrackerIndex - 1].departureDateTime;
        } else if (eventTracker == 'Transportation') {
          startChildDate = loadedTrip.countries[i].cities[j]
              .transportations[transportationTrackerIndex - 1].startingDateTime;
        } else if (eventTracker == 'Lodging') {
          startChildDate = loadedTrip.countries[i].cities[j]
              .lodgings[lodgingTrackerIndex - 1].checkInDateTime;
        } else if (eventTracker == 'Activity') {
          startChildDate = loadedTrip.countries[i].cities[j]
              .activities[activitiesTrackerIndex - 1].startingDateTime;
        } else if (eventTracker == 'Restaurant') {
          startChildDate = loadedTrip.countries[i].cities[j]
              .restaurants[restaruantsTrackerIndex - 1].startingDateTime;
        }
      }
    }
  }

  void setEndChildText(String eventTracker) {
    for (int i = 0; i < loadedTrip.countries.length; i++) {
      for (int j = 0; j < loadedTrip.countries[i].cities.length; j++) {
        if (eventTracker == 'Flight') {
          endChildText =
              loadedTrip.countries[i].flights[flightTrackerIndex - 1].airline;
        } else if (eventTracker == 'Transportation') {
          endChildText = loadedTrip.countries[i].cities[j]
              .transportations[transportationTrackerIndex - 1].company;
        } else if (eventTracker == 'Lodging') {
          endChildText = loadedTrip
              .countries[i].cities[j].lodgings[lodgingTrackerIndex - 1].name;
        } else if (eventTracker == 'Activity') {
          endChildText = loadedTrip.countries[i].cities[j]
              .activities[activitiesTrackerIndex - 1].title;
        } else if (eventTracker == 'Restaurant') {
          endChildText = loadedTrip.countries[i].cities[j]
              .restaurants[restaruantsTrackerIndex - 1].name;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    loadedTrip = arguments['loadedTrip'];
    getTotals();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Timeline',
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
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.015,
            ),
            Container(
              padding: const EdgeInsets.only(
                left: 28,
              ),
              alignment: Alignment.centerLeft,
              height: screenHeight * 0.075,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${loadedTrip.title}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${DateFormat.yMMMd().format(loadedTrip.startDate)} - ${DateFormat.yMMMd().format(loadedTrip.endDate)}',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            _totalEvents <= 0
                ? Container(
                    width: screenWidth * 0.65,
                    padding: const EdgeInsets.only(top: 150.0),
                    child: Text(
                      'There are no events to display. Go add some events!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _totalEvents,
                      itemBuilder: (BuildContext ctx, int index) {
                        String event = getEarliestEvent();
                        setStartChildDate(event);
                        setEndChildText(event);
                        return TimelineTile(
                          alignment: TimelineAlign.manual,
                          isFirst: index == 0 ? true : false,
                          isLast: index == _totalEvents - 1 ? true : false,
                          lineXY: 0.35,
                          indicatorStyle: IndicatorStyle(
                            width: 37,
                            iconStyle: IconStyle(
                                iconData: event == 'Flight'
                                    ? Icons.airplanemode_active
                                    : event == 'Lodging'
                                        ? Icons.hotel
                                        : event == 'Transportation'
                                            ? Icons.train
                                            : event == 'Restaurant'
                                                ? Icons.restaurant
                                                : event == 'Activity'
                                                    ? Icons.local_activity
                                                    : Icons.place),
                            color: Theme.of(context).buttonColor,
                          ),
                          beforeLineStyle: LineStyle(
                            color: Theme.of(context).buttonColor,
                          ),
                          afterLineStyle: LineStyle(
                            color: Theme.of(context).buttonColor,
                          ),
                          startChild: Container(
                            alignment: Alignment.center,
                            child: tempChildDate.day == startChildDate.day &&
                                    tempChildDate.month ==
                                        startChildDate.month &&
                                    tempChildDate.year == startChildDate.year &&
                                    (tempChildDate.hour !=
                                            startChildDate.hour ||
                                        tempChildDate.minute !=
                                            startChildDate.minute)
                                ? Text(
                                    '${DateFormat.jm().format(startChildDate)}')
                                : Text(
                                    '${DateFormat.MMMEd().format(startChildDate)}'),
                          ),
                          endChild: Container(
                            constraints: const BoxConstraints(
                              minHeight: 75,
                            ),
                            child: Text(endChildText),
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.05,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
