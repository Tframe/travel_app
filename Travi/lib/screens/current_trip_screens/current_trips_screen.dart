import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/current_trip_card_list.dart';
import '../../providers/trips_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/country_provider.dart';
import '../../providers/city_provider.dart';
import '../../providers/user_provider.dart';
import '../../screens/add_trip_screens/add_trip_intro_screen.dart';

class CurrentTripsScreen extends StatefulWidget {
  static const routeName = '/current-trips';

  @override
  _CurrentTripsScreenState createState() => _CurrentTripsScreenState();
}

class _CurrentTripsScreenState extends State<CurrentTripsScreen> {
  UserProvider loggedInUser;
  User user;

  @override
  void initState() {
    loggedInUser =
        Provider.of<UserProvider>(context, listen: false).currentLoggedInUser;
    user = FirebaseAuth.instance.currentUser;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> fetchTripsData() async {
    await Provider.of<TripsProvider>(context, listen: false)
        .fetchAndSetTrips(user);
    for (int i = 0; i < loggedInUser.tripInvites.length; i++) {
      if (loggedInUser.tripInvites[i].status == 'Accepted') {
        await Provider.of<TripsProvider>(context, listen: false)
            .fetchAndSetInvitedTrip(
          loggedInUser.tripInvites[i].organizerUserId,
          loggedInUser.tripInvites[i].tripId,
        );
      }
    }
    await fetchTripsCountries();
    return null;
  }

  Future<void> fetchTripsCountries() async {
    List<TripProvider> tripsList = [];
    tripsList = Provider.of<TripsProvider>(context, listen: false).trips;
    //for each trip, fetch and set the countries list to that trip
    for (int i = 0; i < tripsList.length; i++) {
      await Provider.of<Country>(context, listen: false)
          .fetchAndSetCountries(tripsList[i].organizerId, tripsList[i].id);
      //set countryList
      tripsList[i].countries = Provider.of<Country>(context, listen: false)
          .getCountryListByTripId(tripsList[i].id);
      await Provider.of<TripsProvider>(context, listen: false)
          .setCountriesToTrip(tripsList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: fetchTripsData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return CurrentTripCardList();
          }),
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
