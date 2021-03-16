/* Author: Trevor Frame
 * Date: 12/07/2020
 * Description: screen for editing activity info
 */
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:groupy/providers/activity_provider.dart';
import 'package:groupy/providers/trips_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/user_provider.dart';
import './add_or_edit_activity_screen.dart';

class EditActivitiesScreen extends StatefulWidget {
  static const routeName = '/edit-activities-screen';
  @override
  _EditActivitiesScreenState createState() => _EditActivitiesScreenState();
}

class _EditActivitiesScreenState extends State<EditActivitiesScreen> {
  TripProvider loadedTrip;
  int countryIndex = 0;
  int cityIndex = 0;

  void addOrEditActivity(int editIndex) async {
    Navigator.of(context).pushNamed(
      AddOrEditActivityScreen.routeName,
      arguments: {
        'loadedTrip': loadedTrip,
        'editIndex': editIndex,
      },
    ).then((value) {
      setState(() {
        print('updated and popped');
      });
    });
  }

  //Removes swiped activity
  void removeActivity(int index) async {}

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    loadedTrip = arguments['loadedTrip'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Activities'),
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
      body: loadedTrip.countries[countryIndex].cities[cityIndex].activities ==
                  null ||
              loadedTrip.countries[countryIndex].cities[cityIndex].activities
                      .length ==
                  0
          ? Center(
              child: Text('No Activities Added'),
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
                                    .cities[cityIndex].activities ==
                                null
                            ? 0
                            : loadedTrip.countries[countryIndex]
                                .cities[cityIndex].activities.length,
                        itemBuilder: (BuildContext ctx, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                            child: Dismissible(
                              key: ValueKey(loadedTrip.countries[countryIndex]
                                  .cities[cityIndex].activities),
                              child: ListTile(
                                leading: Padding(
                                  padding: const EdgeInsets.only(right: 28.0),
                                  child: Icon(
                                    Icons.hotel,
                                  ),
                                ),
                                title: Text(loadedTrip.countries[countryIndex]
                                    .cities[cityIndex].activities[index].title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${loadedTrip.countries[countryIndex].cities[cityIndex].activities[index].title}'),
                                    Text(
                                      '${DateFormat.yMd().format(loadedTrip.countries[countryIndex].cities[cityIndex].activities[index].startingDateTime)} - ${DateFormat.yMd().format(loadedTrip.countries[countryIndex].cities[cityIndex].activities[index].endingDateTime)}',
                                    ),
                                  ],
                                ),
                                //TODO Navigate to the activity profile page
                                onTap: () => addOrEditActivity(index),
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
                                      'Are you sure you want to delete ${loadedTrip.countries[countryIndex].cities[cityIndex].activities[index].title}?',
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: const Text('Yes'),
                                        onPressed: () {
                                          setState(() {
                                            Provider.of<Activity>(context,
                                                    listen: false)
                                                .removeActivity(
                                              loadedTrip.id,
                                              user.uid,
                                              loadedTrip
                                                  .countries[countryIndex].id,
                                              loadedTrip.countries[countryIndex]
                                                  .cities[cityIndex].id,
                                              loadedTrip
                                                  .countries[countryIndex]
                                                  .cities[cityIndex]
                                                  .activities[index]
                                                  .id,
                                            );
                                            loadedTrip.countries[countryIndex]
                                                .cities[cityIndex].activities
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
                                                    .activities =
                                                loadedTrip
                                                    .countries[countryIndex]
                                                    .cities[cityIndex]
                                                    .activities;
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
        onPressed: () => addOrEditActivity(-1),
        child: Icon(
          Icons.add,
          color: Theme.of(context).accentColor,
        ),
      ),
    );
  }
}
