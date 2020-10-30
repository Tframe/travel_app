import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../providers/trip_provider.dart';
import '../../providers/lodging_provider.dart';
import '../../providers/user_provider.dart';
import './add_or_edit_lodging_screen.dart';

class EditLodgingsScreen extends StatefulWidget {
  static const routeName = '/edit-lodgings-screen';
  @override
  _EditLodgingsScreenState createState() => _EditLodgingsScreenState();
}

class _EditLodgingsScreenState extends State<EditLodgingsScreen> {
  TripProvider loadedTrip;
  int countryIndex = 0;
  int cityIndex = 0;
  //Add new loading
  //if editIndex == -1, then adding lodging,
  //if editIndex > -1, then editing lodging.
  void _addOrEditLodging(int editIndex) async {
    Navigator.of(context).pushNamed(
      AddOrEditLodgingScreen.routeName,
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
        title: Text('Edit Lodgings'),
      ),
      body: loadedTrip.countries[countryIndex].cities[cityIndex].lodgings ==
                  null ||
              loadedTrip.countries[countryIndex].cities[cityIndex].lodgings
                      .length ==
                  0
          ? Center(
              child: Text('No Lodgings Added'),
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
                        itemCount: loadedTrip.countries[countryIndex]
                                    .cities[cityIndex].lodgings ==
                                null
                            ? 0
                            : loadedTrip.countries[countryIndex]
                                .cities[cityIndex].lodgings.length,
                        itemBuilder: (BuildContext ctx, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                            child: Dismissible(
                              key: ValueKey(loadedTrip.countries[countryIndex]
                                  .cities[cityIndex].lodgings),
                              child: ListTile(
                                leading: Padding(
                                  padding: const EdgeInsets.only(right: 28.0),
                                  child: Icon(
                                    Icons.hotel,
                                  ),
                                ),
                                title: Text(loadedTrip.countries[countryIndex]
                                    .cities[cityIndex].lodgings[index].name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loadedTrip
                                                  .countries[countryIndex]
                                                  .cities[cityIndex]
                                                  .lodgings[index]
                                                  .address !=
                                              null
                                          ? '${loadedTrip.countries[countryIndex].cities[cityIndex].lodgings[index].address}'
                                          : '',
                                    ),
                                    Text(
                                      loadedTrip
                                                      .countries[countryIndex]
                                                      .cities[cityIndex]
                                                      .lodgings[index]
                                                      .checkInDateTime !=
                                                  null &&
                                              loadedTrip
                                                      .countries[countryIndex]
                                                      .cities[cityIndex]
                                                      .lodgings[index]
                                                      .checkOutDateTime !=
                                                  null
                                          ? '${DateFormat.yMd().format(loadedTrip.countries[countryIndex].cities[cityIndex].lodgings[index].checkInDateTime)} - ${DateFormat.yMd().format(loadedTrip.countries[countryIndex].cities[cityIndex].lodgings[index].checkOutDateTime)}'
                                          : '',
                                    ),
                                  ],
                                ),

                                //TODO Navigate to the lodging profile page
                                onTap: () => _addOrEditLodging(index),
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
                                      'Are you sure you want to delete ${loadedTrip.countries[countryIndex].cities[cityIndex].lodgings[index].name}?',
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: const Text('Yes'),
                                        onPressed: () {
                                          setState(() {
                                            Provider.of<Lodging>(context,
                                                    listen: false)
                                                .removeLodging(
                                              loadedTrip.id,
                                              user.uid,
                                              loadedTrip
                                                  .countries[countryIndex].id,
                                              loadedTrip.countries[countryIndex]
                                                  .cities[cityIndex].id,
                                              loadedTrip
                                                  .countries[countryIndex]
                                                  .cities[cityIndex]
                                                  .lodgings[index]
                                                  .id,
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
        onPressed: () => _addOrEditLodging(-1),
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}
