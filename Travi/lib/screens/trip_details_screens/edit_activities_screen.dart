import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/trips_provider.dart';
import '../../providers/user_provider.dart';
import './add_or_edit_activity_screen.dart';

class EditActivitiesScreen extends StatefulWidget {
  static const routeName = '/edit-activities-screen';
  @override
  _EditActivitiesScreenState createState() => _EditActivitiesScreenState();
}

class _EditActivitiesScreenState extends State<EditActivitiesScreen> {
  TripProvider loadedTrip;

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
      ),
      body: loadedTrip.activities == null || loadedTrip.activities.length == 0
          ? Center(
              child: Text('No Activities Added'),
            )
          : SingleChildScrollView(
              child: Container(
                width: screenWidth * 0.9,
                child: Column(
                  children: [
                    Container(
                      height: screenHeight * 0.8,
                      width: screenWidth * 0.9,
                      padding: const EdgeInsets.only(
                        top: 35,
                      ),
                      child: ListView.builder(
                        itemCount: loadedTrip.activities == null ? 0 : loadedTrip.activities.length,
                        itemBuilder: (BuildContext ctx, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                            child: Dismissible(
                              key: ValueKey(loadedTrip.activities),
                              child: ListTile(
                                leading: Padding(
                                  padding: const EdgeInsets.only(right: 28.0),
                                  child: Icon(
                                    Icons.hotel,
                                  ),
                                ),
                                title: Text(loadedTrip.activities[index].title),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${loadedTrip.activities[index].title}'),
                                    Text(
                                      '${DateFormat.yMd().format(loadedTrip.activities[index].startingDateTime)} - ${DateFormat.yMd().format(loadedTrip.activities[index].endingDateTime)}',
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
                                      'Are you sure you want to delete ${loadedTrip.activities[index].title}?',
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: const Text('Yes'),
                                        onPressed: () {
                                          setState(() {
                                            Provider.of<TripsProvider>(context,
                                                    listen: false)
                                                .removeActivity(loadedTrip,
                                                    user.uid, index);
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
        ),
      ),
    );
  }
}
