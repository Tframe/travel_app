import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/current_trip_card_list.dart';
import '../../providers/trips_provider.dart';
import '../../providers/user_provider.dart';
import '../../screens/add_trip_screens/add_trip_intro_screen.dart';

class CurrentTripsScreen extends StatefulWidget {
  static const routeName = '/current-trips';

  @override
  _CurrentTripsScreenState createState() => _CurrentTripsScreenState();
}

class _CurrentTripsScreenState extends State<CurrentTripsScreen> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    UserProvider loggedInUser =
        Provider.of<UserProvider>(context, listen: false).currentLoggedInUser;
    User user = FirebaseAuth.instance.currentUser;
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<TripsProvider>(context, listen: false)
          .fetchAndSetTrips(user)
          .then((value) {
        for (int i = 0; i < loggedInUser.tripInvites.length; i++) {
          if (loggedInUser.tripInvites[i].status == 'Accepted') {
            Provider.of<TripsProvider>(context, listen: false)
                .fetchAndSetInvitedTrip(
              loggedInUser.tripInvites[i].organizerUserId,
              loggedInUser.tripInvites[i].tripId,
            );
          }
        }
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.initState();
  }

  @override
  void didChangeDependencies() {
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
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Theme.of(context).accentColor,
        ),
        onPressed: () {
          Navigator.of(context).pushNamed(AddTripIntroScreen.routeName);
        },
      ),
    );
  }
}
