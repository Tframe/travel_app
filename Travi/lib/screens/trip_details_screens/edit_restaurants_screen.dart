import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../providers/trip_provider.dart';
import '../../providers/trips_provider.dart';
import '../../providers/user_provider.dart';
import './add_or_edit_restaurant_screen.dart';

class EditRestaurantsScreen extends StatefulWidget {
  static const routeName = '/edit-restaurants-screen';
  @override
  _EditRestaurantsScreenState createState() => _EditRestaurantsScreenState();
}

class _EditRestaurantsScreenState extends State<EditRestaurantsScreen> {
  TripProvider loadedTrip;

  //Add new loading
  //if editIndex == -1, then adding lodging,
  //if editIndex > -1, then editing lodging.
  void _addOrEditRestaurant(int editIndex) async {
    Navigator.of(context).pushNamed(
      AddOrEditRestaurantScreen.routeName,
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
        title: Text('Edit Restaurants'),
      ),
      body: loadedTrip.restaurants == null || loadedTrip.restaurants.length == 0
          ? Center(
              child: Text('No Restaurants Added'),
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
                        itemCount: loadedTrip.restaurants == null ? 0 : loadedTrip.restaurants.length,
                        itemBuilder: (BuildContext ctx, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18.0),
                            child: Dismissible(
                              key: ValueKey(loadedTrip.restaurants),
                              child: ListTile(
                                leading: Padding(
                                  padding: const EdgeInsets.only(right: 28.0),
                                  child: Icon(
                                    Icons.restaurant,
                                  ),
                                ),
                                title: Text(loadedTrip.restaurants[index].name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loadedTrip.restaurants[index].address != null
                                          ? '${loadedTrip.restaurants[index].address}'
                                          : '',
                                    ),
                                    Text(
                                      loadedTrip.restaurants[index]
                                                      .startingDateTime !=
                                                  null 
                                          ? '${DateFormat.yMd().format(loadedTrip.restaurants[index].startingDateTime)}'
                                          : '',
                                    ),
                                  ],
                                ),
                                //TODO Navigate to the lodging profile page
                                onTap: () => _addOrEditRestaurant(index),
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
                                      'Are you sure you want to delete ${loadedTrip.restaurants[index].name}?',
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: const Text('Yes'),
                                        onPressed: () {
                                          setState(() {
                                            Provider.of<TripsProvider>(context,
                                                    listen: false)
                                                .removeRestaurant(loadedTrip,
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
        onPressed: () => _addOrEditRestaurant(-1),
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}