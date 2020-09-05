import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/trips_provider.dart';
import './past_trip_item.dart';

class PastTripCardList extends StatelessWidget {
  Future<User> _getUser() async {
    final user = FirebaseAuth.instance.currentUser;
    return user;
  }
  @override
  Widget build(BuildContext context) {
    final user = _getUser();
    final tripsData = Provider.of<TripsProvider>(context);

    //get list of past trips based on trip end dates being before today's date.
    final tripsList = tripsData.trips.where((trip) => trip.endDate.isBefore(DateTime.now())).toList();
    //sort list by start date
    tripsList.sort((a, b) => a.startDate.compareTo(b.startDate));

    return tripsList.length == 0 ? AlertDialog(title: Text('No Trips Found'), content: Text('You have no past trips saved.'),) : ListView.builder(
      itemCount: tripsList.length,
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        value: tripsList[index],
        child: PastTripItem(),
      ),
    );
  }
}
