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
    _totalLodges = loadedTrip.lodgings.length;
    _totalTransportation = loadedTrip.transportations.length;
    _totalActivities = loadedTrip.activities.length;
    _totalFlights = loadedTrip.flights.length;
    _totalRestaurants = loadedTrip.restaurants.length;
    _totalEvents = _totalLodges +
        _totalTransportation +
        _totalActivities +
        _totalFlights +
        _totalRestaurants;
  }

  //Returns a string to indicate which event should be displayed next
  //in the timeline. Increments the event index to compare next dates.
  String getEarliestEvent() {
    DateTime earliestDate = loadedTrip.endDate.add(Duration(days: 1));
    String eventTracker = '';

    if (loadedTrip.flights.isNotEmpty) {
      if (loadedTrip.flights.length > flightTrackerIndex) {
        earliestDate = loadedTrip.flights[flightTrackerIndex].departureDateTime;
        eventTracker = 'Flight';
      }
    }
    if (loadedTrip.lodgings.isNotEmpty) {
      if (loadedTrip.lodgings.length > lodgingTrackerIndex) {
        if (earliestDate.isAfter(
            loadedTrip.lodgings[lodgingTrackerIndex].checkInDateTime)) {
          earliestDate =
              loadedTrip.lodgings[lodgingTrackerIndex].checkInDateTime;
          eventTracker = 'Lodging';
        }
      }
    }
    if (loadedTrip.transportations.isNotEmpty) {
      if (loadedTrip.transportations.length > transportationTrackerIndex) {
        if (earliestDate.isAfter(loadedTrip
            .transportations[transportationTrackerIndex].startingDateTime)) {
          earliestDate = loadedTrip
              .transportations[transportationTrackerIndex].startingDateTime;
          eventTracker = 'Transportation';
        }
      }
    }
    if (loadedTrip.activities.isNotEmpty) {
      if (loadedTrip.activities.length > activitiesTrackerIndex) {
        if (earliestDate.isAfter(
            loadedTrip.activities[activitiesTrackerIndex].startingDateTime)) {
          earliestDate =
              loadedTrip.activities[activitiesTrackerIndex].startingDateTime;
          eventTracker = 'Activity';
        }
      }
    }
    if (loadedTrip.restaurants.isNotEmpty) {
      if (loadedTrip.restaurants.length > restaruantsTrackerIndex) {
        if (earliestDate.isAfter(
            loadedTrip.restaurants[restaruantsTrackerIndex].startingDateTime)) {
          earliestDate =
              loadedTrip.restaurants[restaruantsTrackerIndex].startingDateTime;
          eventTracker = 'Restaurant';
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
    if (eventTracker == 'Flight') {
      startChildDate =
          loadedTrip.flights[flightTrackerIndex - 1].departureDateTime;
    } else if (eventTracker == 'Transportation') {
      startChildDate = loadedTrip
          .transportations[transportationTrackerIndex - 1].startingDateTime;
    } else if (eventTracker == 'Lodging') {
      startChildDate =
          loadedTrip.lodgings[lodgingTrackerIndex - 1].checkInDateTime;
    } else if (eventTracker == 'Activity') {
      startChildDate =
          loadedTrip.activities[activitiesTrackerIndex - 1].startingDateTime;
    } else if (eventTracker == 'Restaurant') {
      startChildDate =
          loadedTrip.restaurants[restaruantsTrackerIndex - 1].startingDateTime;
    }
  }

  void setEndChildText(String eventTracker) {
    if (eventTracker == 'Flight') {
      endChildText = loadedTrip.flights[flightTrackerIndex - 1].airline;
    } else if (eventTracker == 'Transportation') {
      endChildText =
          loadedTrip.transportations[transportationTrackerIndex - 1].company;
    } else if (eventTracker == 'Lodging') {
      endChildText = loadedTrip.lodgings[lodgingTrackerIndex - 1].name;
    } else if (eventTracker == 'Activity') {
      endChildText = loadedTrip.activities[activitiesTrackerIndex - 1].title;
    } else if (eventTracker == 'Restaurant') {
      endChildText = loadedTrip.restaurants[restaruantsTrackerIndex - 1].name;
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
                            color: Theme.of(context).primaryColor,
                          ),
                          beforeLineStyle: LineStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                          afterLineStyle: LineStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                          startChild: Container(
                            alignment: Alignment.center,
                            child: tempChildDate.day == startChildDate.day &&
                                    tempChildDate.month ==
                                        startChildDate.month &&
                                    tempChildDate.year ==
                                        startChildDate.year &&
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
