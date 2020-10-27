import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../providers/trip_provider.dart';
import '../../providers/trips_provider.dart';
import '../../providers/user_provider.dart';
import './add_or_edit_flight_screen.dart';

class EditFlightsScreen extends StatefulWidget {
  static const routeName = '/edit-flights-screen';
  @override
  _EditFlightsScreenState createState() => _EditFlightsScreenState();
}

class _EditFlightsScreenState extends State<EditFlightsScreen> {
  TripProvider loadedTrip;

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
      ),
      body: loadedTrip.flights == null || loadedTrip.flights.length == 0
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
                      width: screenWidth * 0.9,
                      padding: const EdgeInsets.only(
                        top: 35,
                      ),
                      child: ListView.builder(
                        itemCount: loadedTrip.flights == null
                            ? 0
                            : loadedTrip.flights.length,
                        itemBuilder: (BuildContext ctx, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                            child: Dismissible(
                              key: ValueKey(loadedTrip.flights),
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
                                        loadedTrip.flights[index].flightNumber,
                                      ),
                                    ],
                                  ),
                                ),
                                title: Text(loadedTrip.flights[index].airline),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${loadedTrip.flights[index].departureAirport}'),
                                    Text(
                                      '${DateFormat.yMd().add_jm().format(loadedTrip.flights[index].departureDateTime)}',
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
                                      'Are you sure you want to delete flight number ${loadedTrip.flights[index].flightNumber}?',
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: const Text('Yes'),
                                        onPressed: () {
                                          setState(() {
                                            Provider.of<TripsProvider>(context,
                                                    listen: false)
                                                .removeFlight(
                                              loadedTrip,
                                              user.uid,
                                              index,
                                            );
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
        ),
      ),
    );
  }
}