import 'package:flutter/material.dart';


import '../providers/trips_provider.dart';
import '../widgets/past_trip_card_list.dart';

class PastTripsScreen extends StatefulWidget {
  static const routeName = '/past-trips';


  @override
  _PastTripsScreenState createState() => _PastTripsScreenState();
}

class _PastTripsScreenState extends State<PastTripsScreen> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : PastTripCardList(),
    );
  }
}
