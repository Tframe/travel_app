/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: screen for editing flight info
 */
import 'package:flutter/material.dart';
import 'package:groupy/providers/flight_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../providers/flight_provider.dart';
import '../../providers/trips_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/user_provider.dart';
import './add_or_edit_flight_screen.dart';

class EditFlightsScreen extends StatefulWidget {
  static const routeName = '/edit-flights-screen';
  @override
  _EditFlightsScreenState createState() => _EditFlightsScreenState();
}

class _EditFlightsScreenState extends State<EditFlightsScreen> {
  TripProvider loadedTrip;
  int countryIndex = 0;
  int cityIndex = 0;
  void addOrEditFlight(int editIndex) async {
    Navigator.of(context).pushNamed(
      AddOrEditFlightScreen.routeName,
      arguments: {
        'loadedTrip': loadedTrip,
        'editIndex': editIndex,
      },
    ).then((value) {
      setState(() {
        print('popped and updated');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    loadedTrip = arguments['loadedTrip'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Flights'),
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
      body: loadedTrip.countries[countryIndex].flights == null ||
              loadedTrip.countries[countryIndex].flights.length == 0
          ? Center(
              child: Text('No Flights Added'),
            )
          : SingleChildScrollView(
              child: Container(
                width: screenWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: screenHeight * 0.8,
                      padding: const EdgeInsets.only(
                        top: 35,
                      ),
                      child: ListView.builder(
                        itemCount: loadedTrip.countries[countryIndex].flights ==
                                null
                            ? 0
                            : loadedTrip.countries[countryIndex].flights.length,
                        itemBuilder: (BuildContext ctx, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                            child: Dismissible(
                              key: ValueKey(
                                  loadedTrip.countries[countryIndex].flights),
                              child: ListTile(
                                leading: Padding(
                                  padding: const EdgeInsets.only(right: 28.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Flight #:',
                                      ),
                                      Text(
                                        loadedTrip.countries[countryIndex]
                                            .flights[index].flightNumber,
                                      ),
                                    ],
                                  ),
                                ),
                                title: Text(loadedTrip.countries[countryIndex]
                                    .flights[index].airline),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${loadedTrip.countries[countryIndex].flights[index].departureAirport}'),
                                    Text(
                                      '${DateFormat.yMd().add_jm().format(loadedTrip.countries[countryIndex].flights[index].departureDateTime)}',
                                    ),
                                  ],
                                ),
                                onTap: () => addOrEditFlight(index),
                              ),
                              background: Container(
                                color: Colors.red,
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                User user = await Provider.of<UserProvider>(
                                        context,
                                        listen: false)
                                    .getCurrentUser();
                                return await showDialog<Null>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text(
                                      'Confirm',
                                    ),
                                    content: Text(
                                      'Are you sure you want to delete flight number ${loadedTrip.countries[countryIndex].flights[index].flightNumber}?',
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: const Text('Yes'),
                                        onPressed: () {
                                          setState(() {
                                            Provider.of<Flight>(context,
                                                    listen: false)
                                                .removeFlight(
                                              loadedTrip.id,
                                              user.uid,
                                              loadedTrip
                                                  .countries[countryIndex].id,
                                              loadedTrip.countries[countryIndex]
                                                  .flights[index].id,
                                            );
                                            loadedTrip
                                                .countries[countryIndex].flights
                                                .removeAt(index);
                                            List<TripProvider> trips =
                                                Provider.of<TripsProvider>(
                                                        context,
                                                        listen: false)
                                                    .trips;
                                            var tripIndex = trips.indexWhere(
                                                (trip) =>
                                                    trip.id == loadedTrip.id);
                                            trips[tripIndex]
                                                    .countries[countryIndex]
                                                    .flights =
                                                loadedTrip
                                                    .countries[countryIndex]
                                                    .flights;
                                            Provider.of<TripsProvider>(context,
                                                    listen: false)
                                                .setTripsList(trips);
                                          });
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      FlatButton(
                                        child: const Text('No'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => addOrEditFlight(-1),
        child: Icon(
          Icons.add,
          color: Theme.of(context).accentColor,
        ),
      ),
    );
  }
}
