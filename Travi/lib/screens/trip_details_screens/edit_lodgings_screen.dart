import 'package:flutter/material.dart';

import '../../providers/trip_provider.dart';
import './add_lodging_screen.dart';

class EditLodgingsScreen extends StatefulWidget {
  static const routeName = '/edit-lodgings-screen';
  @override
  _EditLodgingsScreenState createState() => _EditLodgingsScreenState();
}

class _EditLodgingsScreenState extends State<EditLodgingsScreen> {
  TripProvider loadedTrip;

  void addLodging() async {
    Navigator.of(context).pushNamed(
      AddLodgingScreen.routeName,
      arguments: {'loadedTrip': loadedTrip},
    );
  }

 

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    loadedTrip = arguments['loadedTrip'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Lodgings'),
      ),
      body: loadedTrip.lodgings.length == 0
          ? Center(
              child: Text('No Lodgings Added'),
            )
          : Center(
              child: Text('Found lodgings'),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: addLodging,
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}
