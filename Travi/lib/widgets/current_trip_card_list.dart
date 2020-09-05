import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/trips_provider.dart';
import 'current_trip_item.dart';

class CurrentTripCardList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tripsData = Provider.of<TripsProvider>(context);

    //get list of current trips based on trip end dates being after today's date.
    final tripsList = tripsData.trips.where((trip) => trip.endDate.isAfter(DateTime.now())).toList();
    //sort list by start date
    tripsList.sort((a, b) => a.startDate.compareTo(b.startDate));

    return tripsList.length == 0 ? AlertDialog(title: Text('No Trips Found'), content: Text('You have no current trips. Try adding a trip.'),) : ListView.builder(
      itemCount: tripsList.length,
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        value: tripsList[index],
        child: CurrentTripItem(),
      ),
    );
  }
}
