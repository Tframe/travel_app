import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../providers/trip_provider.dart';
import '../../providers/trips_provider.dart';
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
      ),
      body: loadedTrip.transportations == null || loadedTrip.transportations.length == 0
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
                      width: screenWidth * 0.9,
                      padding: const EdgeInsets.only(
                        top: 35,
                      ),
                      child: ListView.builder(
                        itemCount: loadedTrip.transportations == null ? 0 : loadedTrip.transportations.length,
                        itemBuilder: (BuildContext ctx, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                            child: Dismissible(
                              key: ValueKey(loadedTrip.transportations),
                              child: ListTile(
                                leading: Padding(
                                  padding: const EdgeInsets.only(right: 28.0),
                                  child: Icon(
                                    Icons.hotel,
                                  ),
                                ),
                                title: Text(
                                    loadedTrip.transportations[index].company),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${loadedTrip.transportations[index].transportationType}'),
                                    Text(
                                      '${DateFormat.yMd().format(loadedTrip.transportations[index].startingDateTime)} - ${DateFormat.yMd().format(loadedTrip.transportations[index].endingDateTime)}',
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
                                      'Are you sure you want to delete ${loadedTrip.transportations[index].company}?',
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: const Text('Yes'),
                                        onPressed: () {
                                          setState(() {
                                            Provider.of<TripsProvider>(context,
                                                    listen: false)
                                                .removeTransportation(
                                                    loadedTrip,
                                                    user.uid,
                                                    index);
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
