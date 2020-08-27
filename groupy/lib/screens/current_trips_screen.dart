import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/new_trip.dart';
import '../providers/trips_provider.dart';
import '../widgets/current_trip_card_list.dart';
import '../providers/auth.dart';

class CurrentTripsScreen extends StatefulWidget {
  static const routeName = '/current-trips';

  void _addNewTrip() {
    return;
  }

  void startAddNewTrip(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return NewTrip(_addNewTrip);
        });
  }

  @override
  _CurrentTripsScreenState createState() => _CurrentTripsScreenState();
}

class _CurrentTripsScreenState extends State<CurrentTripsScreen> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    final authData = Provider.of<Auth>(context, listen: false);
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<TripsProvider>(context).fetchAndSetTrips(authData.userId).then((_) {
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
