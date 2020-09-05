import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/new_trip.dart';
import '../widgets/current_trip_card_list.dart';
import '../providers/trips_provider.dart';

class CurrentTripsScreen extends StatefulWidget {
  static const routeName = '/current-trips';

  // void _addNewTrip() {
  //   return;
  // }

  // void startAddNewTrip(BuildContext ctx) {
  //   showModalBottomSheet(
  //       context: ctx,
  //       builder: (_) {
  //         return NewTrip(_addNewTrip);
  //       });
  // }

  @override
  _CurrentTripsScreenState createState() => _CurrentTripsScreenState();
}

class _CurrentTripsScreenState extends State<CurrentTripsScreen> {
  var _isInit = true;
  var _isLoading = false;

//DO I WANT TO SET PROVIDER HERE???

  @override
  void didChangeDependencies() {
    User user = FirebaseAuth.instance.currentUser;
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<TripsProvider>(context, listen: false).fetchAndSetTrips(user).then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : CurrentTripCardList(),
    );
  }
}
