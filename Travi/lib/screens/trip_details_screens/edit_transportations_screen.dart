/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: screen for editing transportation info
 */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../providers/trips_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/transportation_provider.dart';
import '../../providers/user_provider.dart';
import './add_or_edit_transportation_screen.dart';

class EditTransportationsScreen extends StatefulWidget {
  static const routeName = '/edit-transportations-screen';
  @override
  _EditTransportationsScreenState createState() =>
      _EditTransportationsScreenState();
}

class _EditTransportationsScreenState extends State<EditTransportationsScreen> {
  TripProvider loadedTrip;
  int countryIndex = 0;
  int cityIndex = 0;

  void addOrEditTransportation(int editIndex) async {
    Navigator.of(context).pushNamed(
      AddOrEditTransportationScreen.routeName,
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
        title: Text('Edit Transportations'),
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
      body: loadedTrip.countries[countryIndex].cities[cityIndex]
                      .transportations ==
                  null ||
              loadedTrip.countries[countryIndex].cities[cityIndex]
                      .transportations.length ==
                  0
          ? Center(
              child: Text('No Transportations Added'),
            )
          : SingleChildScrollView(
              child: Container(
                width: screenWidth,
                child: Column(
                  children: [
                    Container(
                      height: screenHeight * 0.8,
                      padding: const EdgeInsets.only(
                        top: 35,
                      ),
                      child: ListView.builder(
                        itemCount: loadedTrip.countries[countryIndex]
                                    .cities[cityIndex].transportations ==
                                null
                            ? 0
                            : loadedTrip.countries[countryIndex]
                                .cities[cityIndex].transportations.length,
                        itemBuilder: (BuildContext ctx, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                            child: Dismissible(
                              key: ValueKey(loadedTrip.countries[countryIndex]
                                  .cities[cityIndex].transportations),
                              child: ListTile(
                                leading: Padding(
                                  padding: const EdgeInsets.only(right: 28.0),
                                  child: Icon(
                                    Icons.hotel,
                                  ),
                                ),
                                title: Text(loadedTrip
                                    .countries[countryIndex]
                                    .cities[cityIndex]
                                    .transportations[index]
                                    .company),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${loadedTrip.countries[countryIndex].cities[cityIndex].transportations[index].transportationType}'),
                                    Text(
                                      '${DateFormat.yMd().format(loadedTrip.countries[countryIndex].cities[cityIndex].transportations[index].startingDateTime)} - ${DateFormat.yMd().format(loadedTrip.countries[countryIndex].cities[cityIndex].transportations[index].endingDateTime)}',
                                    ),
                                  ],
                                ),
                                onTap: () => addOrEditTransportation(index),
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
                                      'Are you sure you want to delete ${loadedTrip.countries[countryIndex].cities[cityIndex].transportations[index].company}?',
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: const Text('Yes'),
                                        onPressed: () {
                                          setState(() {
                                            Provider.of<Transportation>(context,
                                                    listen: false)
                                                .removeTransportation(
                                              loadedTrip.id,
                                              user.uid,
                                              loadedTrip
                                                  .countries[countryIndex].id,
                                              loadedTrip.countries[countryIndex]
                                                  .cities[cityIndex].id,
                                              loadedTrip
                                                  .countries[countryIndex]
                                                  .cities[cityIndex]
                                                  .transportations[index]
                                                  .id,
                                            );
                                            loadedTrip
                                                .countries[countryIndex]
                                                .cities[cityIndex]
                                                .transportations
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
                                                    .cities[cityIndex]
                                                    .transportations =
                                                loadedTrip
                                                    .countries[countryIndex]
                                                    .cities[cityIndex]
                                                    .transportations;
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
        onPressed: () => addOrEditTransportation(-1),
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}
