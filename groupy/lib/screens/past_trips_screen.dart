import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../providers/trips_provider.dart';
import '../widgets/past_trip_card_list.dart';
import '../providers/auth.dart';

class PastTripsScreen extends StatefulWidget {
  static const routeName = '/past-trips';


  @override
  _PastTripsScreenState createState() => _PastTripsScreenState();
}

class _PastTripsScreenState extends State<PastTripsScreen> {
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
          : PastTripCardList(),
    );
  }
}
